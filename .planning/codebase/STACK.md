# Technology Stack

**Analysis Date:** 2026-02-21

## Languages

**Primary:**
- Dart (Flutter) - application code in `lib/` and tests in `test/`

**Secondary:**
- Kotlin/Gradle (Android build) - `android/app/build.gradle.kts`, `android/settings.gradle.kts`
- Swift/Objective-C (iOS project scaffolding) - `ios/Runner/` (e.g. `ios/Runner/Info.plist`)
- TypeScript (Supabase Edge Functions) - `supabase/functions/**/index.ts`
- SQL (Supabase schema/migrations) - `supabase/migrations/*.sql`
- YAML (tooling/config) - `.github/workflows/ci.yml`, `analysis_options.yaml`, `l10n.yaml`
- JavaScript/JSON (Node tooling) - `package.json`, `package-lock.json`

## Runtime

**Environment:**
- Flutter (stable channel, pinned by revision) - `.metadata`
- Dart SDK constraint: `^3.10.8` - `pubspec.yaml`
- Supabase Edge Functions runtime: Deno - `supabase/functions/**` and `supabase/config.toml` (`[edge_runtime] deno_version = 2`)

**Package Manager:**
- Flutter Pub - `pubspec.yaml`, lockfile `pubspec.lock`
- npm - `package.json`, lockfile `package-lock.json`

## Frameworks

**Core:**
- Flutter - mobile app framework, entrypoint `lib/main.dart`
- flutter_riverpod `^2.6.1` - state management/providers in `lib/core/app/providers.dart`

**Local Data:**
- drift `^2.31.0` + sqlite - local DB in `lib/core/database/app_database.dart` (SQLite file `loppisfynd.sqlite`)

**Cloud:**
- supabase_flutter `^2.12.0` - auth/storage/database client init in `lib/main.dart`
- Supabase Edge Functions - Deno handlers in `supabase/functions/tradera-proxy/index.ts` and `supabase/functions/account-delete/index.ts`

**AI / On-device ML:**
- flutter_gemma `^0.12.4` - inference backend in `lib/services/ai/inference/flutter_gemma_backend.dart`
- google_mlkit_barcode_scanning `^0.14.2` - barcode scanning in `lib/features/scanner/scanner_screen.dart`

**Background & Notifications:**
- workmanager `^0.9.0+3` - periodic background sync in `lib/services/sync/background/background_sync.dart`
- flutter_local_notifications `^20.1.0` - local notifications in `lib/services/notifications/app_notifications.dart`

**Observability:**
- sentry_flutter `^9.13.0` - initialization in `lib/main.dart`, breadcrumb analytics in `lib/services/analytics/analytics_service.dart`

**UI / UX:**
- google_fonts `^6.3.3` - bundled fonts (runtime fetching disabled) in `lib/main.dart`
- flutter_animate `^4.5.2` - UI animation usage across `lib/`
- fl_chart `^1.1.1` - charts usage across `lib/`

## Key Dependencies

**Critical:**
- `supabase_flutter` - user auth + cloud sync + edge function invocation (e.g. `lib/services/sync/cloud_metadata_sync_service.dart`, `lib/features/settings/account_deletion_screen.dart`)
- `drift` / `sqlite3_flutter_libs` - offline-first persistence (`lib/core/database/app_database.dart`)
- `http` - outbound HTTP for Tradera proxy calls and model downloads (`lib/services/market/tradera_client.dart`, `lib/services/ai/model_manager.dart`)

**Infrastructure / Device Capabilities:**
- `camera` - camera capture (`android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`)
- `geolocator` + `geocoding` - location + geocoding (`android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`)
- `connectivity_plus` - online/offline detection in sync flows (referenced by sync orchestration under `lib/services/sync/`)
- `permission_handler` - runtime permissions management (used across features under `lib/`)

## Configuration

**Environment:**
- Compile-time configuration via `--dart-define` parsed in `lib/core/config/app_config.dart`:
  - `APP_ENV`
  - `TRADERA_PROXY_URL`
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
  - `GEMMA_MODEL_URL`
  - `SENTRY_DSN`
- Feature flags via `--dart-define` in `lib/core/config/feature_flags.dart`:
  - `FF_DISABLE_SYNC`, `FF_DISABLE_MARKET`, `FF_DISABLE_AI`, `FF_DISABLE_ANALYTICS`
- Example build/run invocation (placeholders) documented in `docs/release_playstore.md`
- `.env.example` present for environment configuration (do not commit secrets)

**Build:**
- Android flavors: `dev`, `staging`, `prod` - `android/app/build.gradle.kts`
- Android toolchain:
  - Java 17 target/compile - `android/app/build.gradle.kts`, `.github/workflows/ci.yml`
  - Android Gradle Plugin `8.11.1` + Kotlin `2.2.20` - `android/settings.gradle.kts`
  - Gradle `8.14` - `android/gradle/wrapper/gradle-wrapper.properties`
- GitHub Actions CI (format/analyze/test/build) - `.github/workflows/ci.yml`
- Localization generation config - `l10n.yaml` (outputs to `lib/gen/`)

## Platform Requirements

**Development:**
- Flutter (stable) pinned by revision in `.metadata` (CI installs the exact revision in `.github/workflows/ci.yml`)
- Java 17 for Android builds - `.github/workflows/ci.yml`, `android/app/build.gradle.kts`
- npm (for Cloudflare Wrangler tooling) - `package.json`

**Production:**
- Android app bundle builds for `staging` and `prod` flavors - `.github/workflows/ci.yml`, `docs/release_playstore.md`
- Supabase project (database/auth/storage + edge functions) - `supabase/config.toml`, `supabase/migrations/*.sql`, `supabase/functions/**`

---

*Stack analysis: 2026-02-21*
