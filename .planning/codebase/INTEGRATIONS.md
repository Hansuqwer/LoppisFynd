# External Integrations

**Analysis Date:** 2026-02-17

## APIs & External Services

**Market data:**
- Tradera Search API (SOAP)
  - Used for: fetching ended-auction comps for price stats
  - Called by: Supabase Edge Function `supabase/functions/tradera-proxy/index.ts`
  - Upstream endpoint: `https://api.tradera.com/v3/searchservice.asmx` (SOAP action `SearchAdvanced`)
  - Mobile entrypoint: `TRADERA_PROXY_URL` (`--dart-define`) consumed in `lib/core/config/app_config.dart` and used by `lib/services/market/tradera_client.dart`
  - Edge secrets/env:
    - `TRADERA_APP_ID`, `TRADERA_APP_KEY` (required)
    - `TRADERA_SANDBOX`, `TRADERA_MAX_RESULT_AGE` (optional)

**Error tracking / analytics:**
- Sentry
  - Used for: crash reporting + breadcrumb events (`lib/main.dart`, `lib/services/analytics/analytics_service.dart`)
  - Auth/config: `SENTRY_DSN` via `--dart-define` read in `lib/core/config/app_config.dart`
  - Environment tagging: `APP_ENV` via `--dart-define` (`lib/core/config/app_config.dart`)

**On-device model distribution:**
- Remote model file host (not vendor-specific; configured by URL)
  - Used for: downloading Gemma model artifact into app support dir (`lib/services/ai/model_manager.dart`)
  - Config: `GEMMA_MODEL_URL` via `--dart-define` (`lib/core/config/app_config.dart`, `lib/main.dart`)

## Data Storage

**Databases:**
- Local: SQLite via Drift
  - Location: `getApplicationDocumentsDirectory()/loppisfynd.sqlite` (`lib/core/database/app_database.dart`)
  - Client/ORM: `drift` (`lib/core/database/**`)
- Cloud: Supabase Postgres
  - Schema + RLS policies: `supabase/migrations/20260214230000_hauls_scan_items.sql`, `supabase/migrations/20260215051000_scan_items_condition_multiplier.sql`
  - Tables synced from mobile: `hauls`, `scan_items` (`lib/services/sync/cloud_metadata_sync_service.dart`)
  - Connection: `SUPABASE_URL` (`--dart-define`), client initialized in `lib/main.dart`

**File Storage:**
- Local filesystem
  - Used for: scan images + thumbnails (`lib/core/storage/scan_image_storage.dart`)
- Supabase Storage
  - Bucket: `scan-photos` (`supabase/migrations/20260215043000_storage_scan_photos.sql`)
  - Upload/download/remove flows: `lib/services/sync/cloud_photo_sync_service.dart`

**Caching:**
- Local SQLite caching for market stats
  - DAO: `lib/core/database/daos/market_stats_cache_dao.dart`
  - Used by: `lib/services/market/market_bridge.dart`

## Authentication & Identity

**Auth Provider:**
- Supabase Auth (Email OTP)
  - Implementation: `SupabaseClient.auth.signInWithOtp` + `verifyOTP` in `lib/features/auth/email_otp_auth.dart`
  - Client bootstrap: `Supabase.initialize(url: ..., anonKey: ...)` in `lib/main.dart`
  - Config: `SUPABASE_URL`, `SUPABASE_ANON_KEY` via `--dart-define` (`lib/core/config/app_config.dart`)

## Monitoring & Observability

**Error Tracking:**
- Sentry (`sentry_flutter`) gated by `SENTRY_DSN` (`lib/main.dart`, `lib/core/config/app_config.dart`)

**Logs:**
- No dedicated logging backend detected; app uses Sentry breadcrumbs for lightweight event trails (`lib/services/analytics/analytics_service.dart`)

## CI/CD & Deployment

**Hosting:**
- Mobile distribution targets: Android (AAB) and iOS (Xcode project under `ios/`)

**CI Pipeline:**
- GitHub Actions workflow `/.github/workflows/ci.yml`
  - Runs: `dart format`, `flutter analyze`, `flutter test`
  - Builds: `flutter build appbundle` for `staging` and `prod` flavors
  - Optional Android signing secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`

## Environment Configuration

**Required env vars:**
- App (compile-time `--dart-define`): `APP_ENV`, `TRADERA_PROXY_URL`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GEMMA_MODEL_URL`, `SENTRY_DSN`
- Feature flags (compile-time `--dart-define`): `FF_DISABLE_SYNC`, `FF_DISABLE_MARKET`, `FF_DISABLE_AI`, `FF_DISABLE_ANALYTICS`
- Supabase Edge Functions secrets/env (server-side):
  - `TRADERA_APP_ID`, `TRADERA_APP_KEY`, `TRADERA_SANDBOX`, `TRADERA_MAX_RESULT_AGE` (`supabase/functions/tradera-proxy/index.ts`)
  - `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` (`supabase/functions/account-delete/index.ts`)

**Secrets location:**
- Mobile: passed at build time via `--dart-define` (`lib/core/config/app_config.dart`)
- Supabase: configured as Supabase Edge Function secrets (referenced via `Deno.env.get(...)` in `supabase/functions/**`)
- Repo includes `.env.example` (present) for environment configuration examples; contents not analyzed

## Webhooks & Callbacks

**Incoming:**
- Not detected

**Outgoing:**
- Not detected

---

*Integration audit: 2026-02-17*
