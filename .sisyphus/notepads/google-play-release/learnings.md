## [2026-03-04] Codebase Intelligence — Pre-Wave-1

### Patch 4 Schema Adaptation (CRITICAL)
- Repo already has schemaVersion=16 (offline detection columns added)
- Patch 4 diff targets v15→v16. Must adapt: bump to v17, add `from16to17` migration block with the 3 indexes.
- Existing migration from15to16 adds offline detection columns — do NOT touch it.
- New migration: `from16to17` → 3 CREATE INDEX statements (user_haul, status, user_updated DESC).
- Also add the same indexes in `beforeOpen` for fresh databases.
- New Supabase migration file: `supabase/migrations/20260215060000_scan_items_indexes.sql` (only 2 indexes in cloud: status + user_updated; user_haul is local-only, possibly intentional).

### Patches 15 + 16 — Binary, use `git apply`
- patch15.diff contains binary PNG data (adaptive icons). Use `git apply Assets/LoppisFynd_All_Deliverables/patches/patch15.diff`.
- patch16.diff contains binary launch_image PNGs. Use `git apply Assets/LoppisFynd_All_Deliverables/patches/patch16.diff`.
- These CANNOT be applied manually.

### Patch 10 — ARB Keys Already Exist
- All 12+ l10n keys from patch 10 already exist in both `app_en.arb` and `app_sv.arb`.
- Task T15: Only update Dart usages. Do NOT re-add ARB keys. Run `flutter gen-l10n` after.

### Patch 1 Auth — Gotcha
- Edge function auth falls back to `{userId: "unknown"}` if SUPABASE_URL/SUPABASE_ANON_KEY not configured — allows anonymous access.
- Requires SUPABASE_URL and SUPABASE_ANON_KEY in edge function secrets for production.
- Health-check endpoint must NOT require auth (already preserved in patch design).

### android/key.properties — Does NOT exist yet
- No keystore file exists. T11 task is to document the `keytool` generation steps (not create the keystore — that's a manual human step).

### docs/ Directory — Already exists
- Contains 34+ research files in `docs/Research/`. The privacy policy HTML goes into `docs/privacy_policy.html` (new file, top-level docs/).

### pubspec.yaml version
- Current: `1.0.0+1` — T12 bumps this to production value.

### l10n Flow
- After any ARB change: run `flutter gen-l10n` to regenerate `lib/gen/app_localizations*.dart`.
- After T15 (patch 10 Dart usages): `flutter gen-l10n` NOT needed (ARB not changed, only Dart usages updated).

### scan_capture_service.dart — Current structure
- Class: `ScanCaptureService`
- Uses `SerialTaskQueue` for CPU guardrail
- Privacy-gated AI: checks `kPrivacyCloudIdentificationEnabledKeyV1` before cloud AI
- Patch 7 adds: offline fallback + sync trigger when cloud AI fails

### app_nav_shell.dart — Current structure
- 5-tab bottom nav with CapsuleNavBar + IndexedStack
- Patches 8+11 add: reactive sync watcher (StreamSubscription for pendingSyncCount) + keyboard dismiss (GestureDetector wrapping Scaffold)

### scan_items_dao.dart — No `watchPendingSyncCount` yet
- Patch 8 adds: `Stream<int> watchPendingSyncCount({String? userId})`

### T12: Version Bump Complete
- Bumped pubspec.yaml from `1.0.0+1` → `1.0.0+2` for first production Google Play release
- Verified with `dart pub deps` - shows `fynd_loppis 1.0.0+2`
- Version name (1.0.0) unchanged, only build number incremented (+1 → +2)

### item_detail_screen.dart — Current structure
- Has manual sync button (GlassButton "Sync Now") — Patch 9 removes it
- No debounce on fields — Patch 12 adds 600ms debounce Timer
- Has hardcoded strings — Patch 10 localizes them

### scanner_screen.dart
- Has "Done Scanning" button — Patch 9 removes it

### batch_tray.dart
- Uses `Image.file()` — Patch 11 adds `errorBuilder` for broken images

### Dart format check
- Always run: `dart format --output=none --set-exit-if-changed lib test`
- Always run: `flutter analyze` after any Dart change

### Deno test note (from previous session)
- `deno test supabase/functions` on this repo needs Tradera proxy tests to stub both `rateLimit` AND `dailyQuota` when calling `handleRequest`, otherwise daily quota guard reads env secrets and fails.
- Replaced file-read SOAP fixtures with inline XML to keep tests permission-free and deterministic.


### Patch 14 — ProGuard/R8 Keep Rules
- Added extensive keep rules for native plugins used via reflection:
  - TFLite: `org.tensorflow.lite.**`, `org.tensorflow.lite.gpu.**`, `com.tfliteflutter.**`
  - ML Kit barcode: `com.google.mlkit.**`, `com.google.android.gms.internal.mlkit_vision_barcode.**`
  - Supabase: `io.supabase.**`, `com.supabase.**`, `io.flutterplugins.**`
  - Connectivity Plus: `dev.fluttercommunity.plus.connectivity.**`
  - Sentry: `io.sentry.**`
- Added Kotlin coroutines: `dontwarn kotlinx.coroutines.**`
- Added attribute preservation: `Signature`, `*Annotation*`, `EnclosingMethod`, `InnerClasses`, `Exceptions`
- Preserved existing MediaPipe `dontwarn` rules
- Without these rules, R8 can strip classes used by native plugins via reflection, causing runtime crashes in release builds that compile fine.
## [2026-03-05] Patch 2 — AbortController Timeout
- Applied 15s AbortController timeout to tradera-proxy SOAP fetch calls
- The index.ts file had duplicate/dead code from previous partial patch attempts
- Cleanup: Removed duplicate LIMITS export and old fetch block without AbortController
- Tests: 8/8 pass (`deno test supabase/functions/tradera-proxy`)
- Behavior: On AbortError, returns 502 with message "Tradera request timed out"

## [2026-03-05] T11: Keystore docs
- docs/keystore-setup.md created with keytool command and key.properties template
- android/key.properties already in .gitignore at line 62


## [2026-03-05] T10: Privacy Policy HTML + Markdown
- Created docs/privacy_policy.html (77 lines) from patch 20 content
- Created docs/privacy_policy.md (72 lines) from patch 20 content
- HTML verified: Python HTMLParser exits 0 without errors
- Content: Offline-first policy, cloud sync (optional), AI identification, crash reporting, permissions, data export/deletion, children policy, contact
- Contact email: privacy@fyndloppis.se
- Ready for hosting on GitHub Pages/Vercel/Netlify and linking from Google Play Console
## [2026-03-05] T6: Docs & config update (.env.example, README, .gitignore)
- Patch 6 content was already present in README.md and .gitignore
- Applied change: Removed TRADERA_PUBLIC_KEY from .env.example (patch removes this var)
- Verified no real secrets: grep -E '(eyJ|sk-|AIza)' .env.example returns no matches
- All values are empty placeholders or documented defaults
- Evidence saved to: .sisyphus/evidence/t6-env-no-secrets.txt

## [2026-03-06] T1 Repair + Verification
- `supabase/functions/cloud-ai-proxy/index.ts` had a half-applied auth patch: `verifyAuth` was referenced but the `AuthVerifier` type and `createSupabaseAuthVerifier()` helper were missing.
- Repaired the edge function by defining `AuthVerifier`, restoring `createSupabaseAuthVerifier()`, and removing the duplicate `env` declaration.
- Wired Flutter side to match: `lib/services/ai/cloud_ai_proxy_client.dart` now accepts `authTokenProvider`, and `lib/main.dart` injects `Supabase.instance.client.auth.currentSession?.accessToken` into `CloudAiProxyClient`.
- Added Android edge-to-edge setup in `lib/main.dart` with `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` and transparent system bars.
- Updated `supabase/functions/cloud-ai-proxy/tests/cloud_ai_proxy_test.ts` to stub auth for existing request-shape tests and added 401 coverage for missing/invalid bearer tokens.
- Verification: `deno test supabase/functions/cloud-ai-proxy` passes (8/8), `flutter analyze lib/main.dart lib/services/ai/cloud_ai_proxy_client.dart lib/services/ai/image_cropper.dart lib/core/database/app_database.dart` passes.

## [2026-03-06] T4 Correction — Index Columns
- The repo had drifted from the intended patch-4 adaptation: indexes were created on `haul_id` and `created_at`, but `scan_items` only has `updated_at` and the patch intended user-scoped indexes.
- Correct local Drift migration (`lib/core/database/app_database.dart`) is:
  - `idx_scan_items_user_haul` on `(user_id, haul_id)`
  - `idx_scan_items_status` on `(status)`
  - `idx_scan_items_user_updated` on `(user_id, updated_at DESC)`
- Correct cloud migration (`supabase/migrations/20260215060000_scan_items_indexes.sql`) keeps only the cloud-relevant indexes:
  - `idx_scan_items_status` on `(status)`
  - `idx_scan_items_user_updated` on `(user_id, updated_at desc)`
- Verification: `flutter test test/fl_010_database_test.dart` passes after correcting the column/index names.

## [2026-03-05] T2 Verification — Patch 2 (AbortController Timeout)
#JP- Task: Verify T2: tradera-proxy 15s AbortController timeout
#YQ- Status: ALREADY APPLIED (verified)
#QR- Verification: 8/8 deno tests pass
#BR- Evidence: .sisyphus/evidence/t2-tradera-timeout.txt, t2-tradera-regression.txt
#MX- Implementation confirmed:
#XH-   - LIMITS.traderaTimeoutMs = 15_000 at line 23
#YQ-   - AbortController with setTimeout at lines 240-244
#XW-   - AbortError handler returns 502 "Tradera request timed out" at lines 256-265
#BQ

## [2026-03-06] Wave 2 execution + release gate findings
- `lib/features/scanner/scan_capture_service.dart` now requests sync after online saves and again after AI results transition an item to `pendingSync`; cloud proxy failures now keep the item locally available and fall back to best-effort offline detection instead of marking the scan failed.
- `lib/core/database/daos/scan_items_dao.dart` now exposes `watchPendingSyncCount({String? userId})`, counting `pendingSync` + `syncing` rows for the reactive Dev Mode badge in `lib/core/navigation/app_nav_shell.dart`.
- `lib/core/navigation/app_nav_shell.dart` now wraps the shell in a global keyboard dismiss gesture and shows the pending-sync badge only when `dev_mode_enabled_v1` is on.
- `lib/features/analyzer/item_detail_screen.dart` now uses a Riverpod `AsyncValue` identify state, shows an AI-in-progress banner when identification is still pending, debounces all text-field saves at 600ms, removes the manual `Sync Now` path, and localizes the chart axis labels.
- `lib/features/scanner/scanner_screen.dart` no longer shows the `Done Scanning` CTA; scanner and dashboard/login goldens had to be updated to match the intended UI changes.
- `android/app/src/main/res/xml/data_extraction_rules.xml` had invalid `<exclude>` entries inside `<device-transfer>`; keeping only the shared-preferences include fixes Android backup lint during `flutter build appbundle`.
- Local release builds on this machine were unstable with `org.gradle.jvmargs=-Xmx8G ...`; reducing `android/gradle.properties` to `-Xmx4G -XX:MaxMetaspaceSize=2G -XX:ReservedCodeCacheSize=256m` stabilized the production AAB build.
- Verification after the above fixes: targeted scanner/login tests pass, full `flutter analyze` passes, `flutter pub run custom_lint` passes, full `flutter test` passes after a clean rebuild, and `flutter build appbundle --flavor prod --release --dart-define=APP_ENV=prod` succeeds.
