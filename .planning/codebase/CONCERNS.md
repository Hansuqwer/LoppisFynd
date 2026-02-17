# Codebase Concerns

**Analysis Date:** 2026-02-17

## Tech Debt

**Cloud sync (no deletes / tombstones):**
- Issue: Cloud sync tracks only "dirty" upserts; local deletions are not propagated and dirty keys can be cleared without writing anything to the cloud.
- Files: `lib/services/sync/cloud_metadata_sync_service.dart`, `lib/core/database/tables/pending_cloud_sync_entities.dart`, `lib/core/database/daos/pending_cloud_sync_entities_dao.dart`, `lib/core/database/daos/scan_items_dao.dart`, `lib/core/database/daos/hauls_dao.dart`
- Impact: Cloud retains stale rows; devices diverge; "deleted" content can reappear after pull.
- Fix approach: Add explicit delete propagation (tombstones like `deleted_at` + `deleted_by`), keep pending rows for deletions, and implement server-side cleanup policies.

**Large widgets / mixed responsibilities:**
- Issue: Screens combine UI, state, and business logic in very large files.
- Files: `lib/features/analyzer/item_detail_screen.dart`, `lib/features/settings/settings_screen.dart`, `lib/features/summary/haul_summary_screen.dart`, `lib/features/history/history_screen.dart`, `lib/features/scanner/scanner_screen.dart`
- Impact: Harder to test, review, and refactor; higher regression risk; inconsistent localization (many hard-coded strings in `lib/features/analyzer/item_detail_screen.dart`).
- Fix approach: Extract feature-specific controllers/services, split widgets into smaller components, and move all user strings into `lib/l10n/`.

**Generated code committed (merge-conflict prone):**
- Issue: Large generated artifacts live in git and are easy to accidentally edit.
- Files: `lib/core/database/app_database.g.dart`, `lib/core/database/daos/*_dao.g.dart`, `lib/gen/app_localizations*.dart`, `lib/l10n/app_localizations*.dart`
- Impact: Noisy diffs and frequent merge conflicts; manual edits get overwritten.
- Fix approach: Treat as generated-only (document regen commands); consider minimizing committed generated files if build pipeline supports it.

**Silent error handling / best-effort swallowing:**
- Issue: Multiple places catch and ignore errors without logging or surfacing status.
- Files: `lib/services/sync/background/background_sync.dart`, `lib/services/sync/cloud/cloud_sync_coordinator.dart`, `lib/services/location/reverse_geocode_cache_service.dart`
- Impact: Failures become invisible; debugging production issues relies on guesswork.
- Fix approach: Record failures to `lib/core/database/tables/entity_sync_statuses.dart` and/or report to `package:sentry_flutter` when enabled.

## Known Bugs

**Cloud auto-sync throttle blocks retries after failure:**
- Symptoms: Auto-sync does not retry for `minInterval` even if the last run failed.
- Files: `lib/services/sync/cloud/cloud_sync_coordinator.dart`
- Trigger: Any exception during metadata/photo sync.
- Workaround: Force sync (`force: true`) or wait for `minInterval`.
- Fix approach: Write `_kAutoSyncLastMs` only after successful completion, or track `last_attempt_ms` separately from `last_success_ms`.

**Background sync reports success even on exceptions:**
- Symptoms: OS/workmanager sees background task as successful even when sync fails.
- Files: `lib/services/sync/background/background_sync.dart`
- Trigger: Exceptions in `SyncScheduler.syncOnce()` or initialization.
- Workaround: None (failures are currently suppressed).
- Fix approach: Return `false` on failure (or set a failure status) and report errors to `lib/core/database/tables/entity_sync_statuses.dart` and/or Sentry.

**Temporary files can accumulate during cloud photo downloads:**
- Symptoms: Files like `/tmp/scan_<id>.jpg` remain after successful import.
- Files: `lib/services/sync/cloud_photo_sync_service.dart`
- Trigger: `downloadMissingFromCloud()` imports images.
- Workaround: Restarting may clear some temp storage, but not guaranteed.
- Fix approach: Delete the temp file after `ScanImageStorage.importImage()` succeeds (and also delete on failure where possible).

**Crash UI leaks internal exception text to end users:**
- Symptoms: User-facing crash screen includes `details.exceptionAsString()`.
- Files: `lib/main.dart`
- Trigger: Any uncaught widget build/render exception.
- Workaround: None.
- Fix approach: Show a generic message in release builds and keep details for debug/dev only; rely on Sentry for diagnostics when enabled.

## Security Considerations

**Build-time config values are extractable from the app binary:**
- Risk: `SUPABASE_ANON_KEY` and other `--dart-define` values are not secrets once shipped.
- Files: `lib/core/config/app_config.dart`, `lib/main.dart`, `.env.example` (present)
- Current mitigation: Uses an anon key (intended to be public) and relies on Supabase RLS/storage policies.
- Recommendations: Treat anon keys as public; enforce strict RLS on `hauls`/`scan_items` and `scan-photos` storage policies; document required Supabase policies alongside app setup docs.

**Unencrypted local storage for sensitive user content:**
- Risk: Photos and SQLite DB contain potentially sensitive inventory, notes, and location; stored unencrypted on-device.
- Files: `lib/core/storage/scan_image_storage.dart`, `lib/core/database/app_database.dart`, `lib/services/privacy/data_export_service.dart`
- Current mitigation: Platform sandboxing only.
- Recommendations: Add optional encryption-at-rest (encrypted DB / protected files), and offer privacy-safe export (omit local file paths; consider redacting `lat`/`lng` and `aiJson` by default).

**Cloud photo operations rely on correct backend policies:**
- Risk: Misconfigured storage bucket policies could allow cross-user reads/writes.
- Files: `lib/services/sync/cloud_photo_sync_service.dart`, `lib/services/sync/cloud_photo_paths.dart`
- Current mitigation: Assumes Supabase storage/RLS is configured.
- Recommendations: Add integration checks (at least in docs) and fail fast with a clear message when bucket access is denied.

## Performance Bottlenecks

**AI inference overhead per request:**
- Problem: Each inference spawns a new isolate and re-initializes / (re)installs the model.
- Files: `lib/services/ai/inference/inference_isolate_service.dart`, `lib/services/ai/inference/flutter_gemma_backend.dart`
- Cause: `_runInIsolate()` spawns an isolate per call; `inferJsonWithFlutterGemma()` calls `FlutterGemma.initialize()` and `FlutterGemma.installModel(...).fromFile(...).install()` for each run.
- Improvement path: Keep a long-lived isolate and a warm model session; do one-time initialization and reuse the active model/chat.

**Cloud metadata sync is full-table, unpaged:**
- Problem: Pull queries fetch all rows every sync.
- Files: `lib/services/sync/cloud_metadata_sync_service.dart`
- Cause: `.select().eq('user_id', user.id).order('updated_at', ...)` without paging or `updated_at > lastSync` filtering.
- Improvement path: Incremental pull (`updated_at > lastSync`), pagination, and server-side indexes/filters.

**Cloud photo sync is O(N) downloads with no existence check:**
- Problem: For each local item missing a file, the client attempts a download and handles failures per item.
- Files: `lib/services/sync/cloud_photo_sync_service.dart`
- Cause: Iterates all scan items and calls `storage.download(...)` for each missing local file.
- Improvement path: Track per-item photo sync state, list objects first, and batch operations.

**Barcode scanning work inside image stream callback:**
- Problem: Frequent async work in camera stream can cause jank on low-end devices.
- Files: `lib/features/scanner/scanner_screen.dart`
- Cause: `BarcodeScanner.processImage()` runs every `_barcodeMinInterval` while streaming.
- Improvement path: Offload to an isolate, reduce scan rate dynamically, and drop frames aggressively when busy.

## Fragile Areas

**Queueing model can hide upstream errors:**
- Files: `lib/core/utils/serial_task_queue.dart`
- Why fragile: The queue tail swallows errors (`catchError((_) {})`), so task failures do not propagate and debugging ordering issues is harder.
- Safe modification: Keep swallowing for tail continuity but also surface errors to the caller and record failures when tasks are critical.
- Test coverage: Covered for basic behavior (`test/fl_022_serial_task_queue_test.dart`).

**Last-write-wins conflicts lose data:**
- Files: `lib/services/sync/cloud/conflict_detector.dart`, `lib/services/sync/cloud_metadata_sync_service.dart`
- Why fragile: Conflicts mark status as `conflict` but still overwrite local data; no dual-write preservation.
- Safe modification: Store both versions (or a change log) and provide a UI to resolve conflicts.
- Test coverage: Conflict predicate covered (`test/services_sync/fl_061_conflict_detector_test.dart`).

**AuthGate runs background maintenance unawaited during build:**
- Files: `lib/features/auth/auth_gate.dart`
- Why fragile: `_ensureScopedData(...)` runs on each auth state change/build; concurrent runs can overlap and increase DB load.
- Safe modification: Memoize per-scope maintenance in provider state (or gate by a single-flight lock).
- Test coverage: Not detected.

## Scaling Limits

**Market sync quota and scheduling are device-local only:**
- Current capacity: Hard cap of `maxCallsPerDay = 200` and a periodic background task interval stored as an int (hours).
- Limit: Multiple devices per user can exceed intended quota; background scheduling is best-effort and OS-dependent.
- Scaling path: Server-driven quotas, per-user accounting, and platform-specific scheduling strategies.
- Files: `lib/services/sync/sync_scheduler.dart`, `lib/services/sync/background/background_sync.dart`, `lib/features/settings/settings_screen.dart`

## Dependencies at Risk

**On-device AI plugin churn risk:**
- Risk: `flutter_gemma` API/behavior changes can break model install/inference (and runtime costs are high).
- Impact: Core "identify" flow becomes unreliable.
- Migration plan: Wrap backend behind `AiBackendKind` and add a second backend option.
- Files: `lib/services/ai/inference/flutter_gemma_backend.dart`, `lib/services/ai/inference/inference_isolate_service.dart`

## Missing Critical Features

**Reliable sync semantics across devices:**
- Problem: No delete propagation + full-table pull means cloud state cannot be made authoritative without losing intent.
- Blocks: Correct multi-device usage and "account delete" expectations.
- Files: `lib/services/sync/cloud_metadata_sync_service.dart`, `lib/core/database/tables/pending_cloud_sync_entities.dart`

## Test Coverage Gaps

**Cloud sync services lack direct unit/integration tests:**
- What's not tested: Metadata/photo sync success/failure flows, throttling behavior, and "delete" semantics.
- Files: `lib/services/sync/cloud_metadata_sync_service.dart`, `lib/services/sync/cloud_photo_sync_service.dart`, `lib/services/sync/cloud/cloud_sync_coordinator.dart`
- Risk: Sync regressions and data loss across versions.
- Priority: High

**AI backend behavior not covered:**
- What's not tested: `flutter_gemma` initialization/install cost, returned text completeness, and isolate lifecycle.
- Files: `lib/services/ai/inference/flutter_gemma_backend.dart`, `lib/services/ai/inference/inference_isolate_service.dart`
- Risk: Slow/unstable identify flow and hard-to-diagnose crashes.
- Priority: Medium

**Cloud account deletion not covered:**
- What's not tested: Deleting storage objects and rows under realistic policy failures.
- Files: `lib/services/privacy/cloud_data_deletion_service.dart`
- Risk: Users believe data is deleted when it is not.
- Priority: Medium

---

*Concerns audit: 2026-02-17*
