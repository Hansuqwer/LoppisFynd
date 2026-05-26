# Codebase Concerns

**Analysis Date:** 2026-02-21

## Tech Debt

**On-device Gemma path is expensive + duplicated install logic:**
- Issue: Inference code calls install on every run (likely re-initializes model/runtime repeatedly), while a separate controller also installs.
- Files: `lib/services/ai/inference/flutter_gemma_backend.dart`, `lib/services/ai/model_install_controller.dart`, `lib/main.dart`, `lib/features/model_manager/widgets/model_download_card.dart`
- Impact: Slow captures/inference, extra CPU/battery, increased crash risk on low-memory devices.
- Fix approach: Install once per app session (or persist a ready model), remove `installGemmaModel()` call from the hot path in `inferJsonWithFlutterGemma()`, and centralize “installed/ready” state behind `ModelInstallController`.

**Isolate-per-inference architecture adds overhead and complexity:**
- Issue: A new isolate is spawned and killed for each inference call.
- Files: `lib/services/ai/inference/inference_isolate_service.dart`
- Impact: Higher latency and power use; harder-to-debug cancellation/race behavior.
- Fix approach: Keep a long-lived worker isolate (or pool) for repeated inference, and surface structured error/cancel outcomes.

**Cloud sync is full-table pull + no incremental query:**
- Issue: Metadata sync always pulls *all* rows for hauls/items and uses `lastSync` only for conflict detection (not for query filtering).
- Files: `lib/services/sync/cloud_metadata_sync_service.dart`
- Impact: Sync cost grows linearly with user data; potential timeouts and slow startup after reconnect.
- Fix approach: Query by `updated_at > lastSync` (or paginate), and chunk upserts to stay within payload limits.

**Auto-sync throttling timestamp is written before work completes:**
- Issue: `cloud_auto_sync_last_ms` is set before metadata/photo sync runs.
- Files: `lib/services/sync/cloud/cloud_sync_coordinator.dart`
- Impact: A failing sync can suppress retries for `minInterval`, leaving the app unsynced.
- Fix approach: Write last-sync timestamp after successful completion (or track separate “attempted” vs “succeeded”).

**Tradera proxy call path is ambiguous (public proxy vs missing auth headers):**
- Issue: App calls Edge Function URL via raw HTTP and does not pass Supabase anon key or user JWT by default.
- Files: `lib/services/market/tradera_client.dart`, `lib/main.dart`, `lib/services/sync/background/background_sync.dart`
- Impact: Either the proxy is publicly callable (abuse/cost risk) or it is protected and the app intermittently fails in real deployments.
- Fix approach: Decide and enforce one mode:
  - Protected: pass `apikey` (anon) and `authorization` (user JWT) or use `Supabase.instance.client.functions.invoke()`.
  - Public: add explicit rate limiting and abuse controls in the function.

**Repo contains a second nested Flutter project that tooling scans:**
- Issue: `custom_lint` reports issues in both the main app and a nested copy.
- Files: `roadmapv2/LoppisFynd-main/pubspec.yaml`, `roadmapv2/LoppisFynd-main/lib/features/onboarding/onboarding_screen.dart`
- Impact: Longer analysis/lint runs, duplicated failures, higher cognitive load (two sources of truth).
- Fix approach: Remove/relocate the nested project outside the analyzed workspace, or exclude it from analysis/lint scopes.

**Node/Cloudflare upload script reference is broken:**
- Issue: `package.json` references a shell script path that is not present.
- Files: `package.json`, `Assets/`
- Impact: Broken developer workflows; confusion about model upload pipeline.
- Fix approach: Either add the missing script (and document it) or remove the script entry.

## Known Bugs

**Tradera HTTP client lifecycle has no explicit close:**
- Symptoms: Repeated background runs can accumulate open HTTP client resources.
- Files: `lib/services/market/tradera_client.dart`, `lib/services/sync/background/background_sync.dart`
- Trigger: Background job creates `TraderaClient()` repeatedly.
- Workaround: App restart clears process state.

**Cloud photo download writes temp files without cleanup:**
- Symptoms: Temp directory can accumulate `scan_<id>.jpg` files.
- Files: `lib/services/sync/cloud_photo_sync_service.dart`
- Trigger: `downloadMissingFromCloud()` imports many items over time.
- Workaround: OS temp cleanup (device-dependent).

**Hardcoded string lint is triggered by a string literal used only for spacing:**
- Symptoms: `custom_lint` flags a hardcoded UI string.
- Files: `lib/features/onboarding/onboarding_screen.dart`
- Trigger: Lint rule `no_hardcoded_ui_strings` detects `text: '$body '`.
- Workaround: None (lint noise) until refactor.

## Security Considerations

**Edge Function CORS is wide-open; auth expectations must be explicit:**
- Risk: If JWT verification is disabled at deploy time, `tradera-proxy` becomes an unauthenticated proxy to Tradera.
- Files: `supabase/functions/tradera-proxy/index.ts`, `lib/services/market/tradera_client.dart`
- Current mitigation: Input length constraints for `searchWords`.
- Recommendations: Require Supabase JWT verification (preferred) and/or enforce rate limits + abuse detection; avoid `access-control-allow-origin: *` unless necessary.

**Service-role Edge Function (`account-delete`) must be treated as high-risk:**
- Risk: Any auth bypass becomes catastrophic (full-data delete + user deletion).
- Files: `supabase/functions/account-delete/index.ts`, `lib/features/settings/account_deletion_screen.dart`
- Current mitigation: Function validates bearer token via `admin.auth.getUser(jwt)`.
- Recommendations: Add explicit logging/auditing, avoid empty `catch {}` around storage removal, and consider requiring recent-auth / reauth UX before invoking.

**Data export includes sensitive fields and local paths:**
- Risk: Exported JSON/CSV contains `aiJson`, notes, and local file paths which may leak if shared.
- Files: `lib/services/privacy/data_export_service.dart`, `lib/features/settings/privacy_screen.dart`
- Current mitigation: User-triggered action only.
- Recommendations: Offer a “redacted export” mode (omit `imagePath`/`thumbPath` and raw `aiJson`) or add clear UX warnings.

**Environment config file exists in repo:**
- Risk: Accidental secret leakage if real values are added.
- Files: `.env.example`
- Current mitigation: `.gitignore` ignores `.env`/`.env.*` while allowing `.env.example`.
- Recommendations: Keep `.env.example` placeholders only; add CI secret scanning.

## Performance Bottlenecks

**Thumbnail generation decodes full images before size guard:**
- Problem: Pixel-count check happens after decode.
- Files: `lib/core/storage/scan_image_storage.dart`
- Cause: `img.decodeImage(bytes)` fully decodes into memory.
- Improvement path: Downsample during decode where possible or pre-validate image dimensions (if available) before full decode; cap capture resolution.

**Cloud metadata sync scales poorly with dataset size:**
- Problem: Full-table `select()` on each sync.
- Files: `lib/services/sync/cloud_metadata_sync_service.dart`
- Cause: No filtering by `updated_at` and no pagination.
- Improvement path: Incremental pull and chunked upserts.

**Gemma inference path does repeated initialization/installation:**
- Problem: Extra work performed for every inference.
- Files: `lib/services/ai/inference/flutter_gemma_backend.dart`
- Cause: `installGemmaModel()` is called inside `inferJsonWithFlutterGemma()`.
- Improvement path: Install once; keep a ready model/chat instance per session.

## Fragile Areas

**Background sync swallows all errors and always returns success:**
- Files: `lib/services/sync/background/background_sync.dart`
- Why fragile: Failures are silent; no backoff/visibility; debugging production issues is hard.
- Safe modification: Capture and report errors (e.g., via Sentry when configured) and record last-run status in DB.
- Test coverage: Policy is tested, but error reporting behavior is not.

**Cloud sync uses manual JSON mapping + loose runtime typing:**
- Files: `lib/services/sync/cloud_metadata_sync_service.dart`
- Why fragile: Shape changes in Supabase tables can throw `FormatException` and break sync.
- Safe modification: Add schema adapters and resilient parsing; version payloads; add contract tests.
- Test coverage: Conflict detection is tested, but end-to-end metadata sync mapping is not.

**Local scope cleanup mixes scoped items with unscoped photos:**
- Files: `lib/features/auth/auth_gate.dart`, `lib/core/database/daos/scan_item_photos_dao.dart`
- Why fragile: Cleanup behavior depends on all photo rows, not the active user scope.
- Safe modification: Scope photos via joins on `scan_items.userId` (or add `userId` to photo rows).
- Test coverage: Not detected.

## Scaling Limits

**Pending entity queues can grow without batching:**
- Current capacity: Upserts run on entire dirty sets.
- Files: `lib/services/sync/cloud_metadata_sync_service.dart`, `lib/core/database/daos/pending_cloud_sync_entities_dao.dart`
- Limit: Large dirty sets risk request payload limits/timeouts.
- Scaling path: Batch deletes and upserts; cap pending size; add retry windows.

## Dependencies at Risk

**`flutter_gemma` dependency implies heavy device/runtime constraints:**
- Risk: GPU/backend variability, large model files, and plugin/runtime stability issues.
- Files: `pubspec.yaml`, `lib/services/ai/inference/flutter_gemma_backend.dart`
- Impact: Higher crash/latency risk on lower-end devices; difficult support matrix.
- Migration plan: Cloud-first inference with a smaller offline fallback.

## Missing Critical Features

**No unified, user-visible error reporting for sync/inference failures:**
- Problem: Many failures are swallowed or only shown via transient SnackBars.
- Files: `lib/services/sync/background/background_sync.dart`, `lib/services/sync/cloud/cloud_sync_coordinator.dart`, `lib/features/settings/sync_status_screen.dart`
- Blocks: Reliable support/debug flows (users cannot easily provide actionable diagnostics).

## Test Coverage Gaps

**Edge Functions lack integration tests around auth + abuse controls:**
- What's not tested: JWT enforcement, rate limiting, and authorization boundaries.
- Files: `supabase/functions/tradera-proxy/index.ts`, `supabase/functions/account-delete/index.ts`
- Risk: Security regressions go unnoticed.
- Priority: High

**Cloud sync mapping is not covered end-to-end:**
- What's not tested: `CloudMetadataSyncService.pullCloudToLocal()` parsing and upsert behavior.
- Files: `lib/services/sync/cloud_metadata_sync_service.dart`
- Risk: Production schema drift breaks sync silently.
- Priority: Medium

---

*Concerns audit: 2026-02-21*
