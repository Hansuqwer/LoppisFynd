# Technology Stack

**Analysis Date:** 2026-02-17

## Languages

**Primary:**
- Dart (SDK constraint `^3.10.8`) - Flutter app code in `lib/**.dart`, tests in `test/**.dart`

**Secondary:**
- Kotlin - Android entrypoint in `android/app/src/main/kotlin/se/fyndloppis/fynd_loppis/MainActivity.kt`
- Swift - iOS entrypoint in `ios/Runner/AppDelegate.swift`
- TypeScript (Deno runtime) - Supabase Edge Functions in `supabase/functions/**.ts`
- SQL - Supabase Postgres schema migrations in `supabase/migrations/*.sql`
- YAML/TOML - Tooling + backend config in `pubspec.yaml`, `analysis_options.yaml`, `.github/workflows/ci.yml`, `supabase/config.toml`

## Runtime

**Environment:**
- Flutter (stable channel) pinned by revision in `.metadata` (revision `67323de285b00232883f53b84095eb72be97d35c`)
- Android: Gradle Kotlin DSL + Java 17 (`android/app/build.gradle.kts`), `minSdk = 24`, `compileSdk = 36`
- iOS: native host config in `ios/Runner/Info.plist` (camera + location usage strings; background fetch mode)

**Package Manager:**
- Flutter/Dart Pub
- Lockfile: `pubspec.lock` (present)

## Frameworks

**Core:**
- Flutter SDK - UI + platform integration
- `flutter_riverpod` - DI/state management (`lib/core/app/providers.dart`)
- Drift + SQLite (`drift`, `drift_flutter`, `sqlite3_flutter_libs`) - local offline-first database (`lib/core/database/app_database.dart`)

**Testing:**
- `flutter_test` - unit/widget tests (`test/**`)

**Build/Dev:**
- `build_runner` + `drift_dev` - code generation for Drift (`lib/core/database/app_database.g.dart`)
- GitHub Actions CI - format/analyze/test + AAB builds (`.github/workflows/ci.yml`)

## Key Dependencies

**Critical:**
- `drift` / `drift_flutter` - local persistence + migrations (`lib/core/database/app_database.dart`)
- `supabase_flutter` - optional cloud sync + auth (`lib/main.dart`, `lib/services/sync/**`)
- `flutter_gemma` - on-device model inference backend (`lib/services/ai/inference/flutter_gemma_backend.dart`)
- `workmanager` - background periodic market sync (`lib/services/sync/background/background_sync.dart`)
- `sentry_flutter` - crash reporting + breadcrumb-style analytics (`lib/main.dart`, `lib/services/analytics/analytics_service.dart`)

**Infrastructure:**
- `http` - model download + proxy calls (`lib/services/ai/model_manager.dart`, `lib/services/market/tradera_client.dart`)
- `camera` - capture flow (`lib/features/scanner/**`)
- `google_mlkit_barcode_scanning` - on-device barcode fallback scanning (`lib/features/scanner/scanner_screen.dart`)
- `connectivity_plus` - online/offline gating (used by sync flows in `lib/services/sync/**`)
- `flutter_local_notifications` - local notifications (`lib/services/notifications/app_notifications.dart`)
- `geolocator` / `geocoding` - location + reverse geocode (haul pinning features in `lib/features/history/**`)
- `permission_handler` - runtime permissions

## Configuration

**Environment:**
- Runtime configuration uses compile-time `--dart-define` values read in `lib/core/config/app_config.dart`:
  - `APP_ENV`
  - `TRADERA_PROXY_URL`
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
  - `GEMMA_MODEL_URL`
  - `SENTRY_DSN`
- Feature flags use compile-time booleans in `lib/core/config/feature_flags.dart`:
  - `FF_DISABLE_SYNC`, `FF_DISABLE_MARKET`, `FF_DISABLE_AI`, `FF_DISABLE_ANALYTICS`
- Android build flavors: `dev`, `staging`, `prod` (`android/app/build.gradle.kts`)

**Build:**
- Analyzer/lints: `analysis_options.yaml` (includes `package:flutter_lints/flutter.yaml`)
- Localization generation: `l10n.yaml` and generated files under `lib/gen/**`
- CI builds AABs for `staging` and `prod` with `--dart-define=APP_ENV=...` (`.github/workflows/ci.yml`)

## Platform Requirements

**Development:**
- Flutter SDK (stable) at the revision pinned in `.metadata`
- Android toolchain capable of Java 17 (`.github/workflows/ci.yml`, `android/app/build.gradle.kts`)
- Supabase local tooling (Supabase CLI) for backend work in `supabase/` (config in `supabase/config.toml`)

**Production:**
- Android App Bundle builds per flavor (`flutter build appbundle --flavor ...`) in `.github/workflows/ci.yml`
- iOS configuration in `ios/**` (native permissions in `ios/Runner/Info.plist`)

---

*Stack analysis: 2026-02-17*
