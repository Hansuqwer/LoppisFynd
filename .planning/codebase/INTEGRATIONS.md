# External Integrations

**Analysis Date:** 2026-02-21

## APIs & External Services

**Market pricing (Tradera):**
- Tradera SearchService SOAP API - used via a server-side proxy
  - Server proxy implementation: `supabase/functions/tradera-proxy/index.ts`
  - Upstream endpoint: `https://api.tradera.com/v3/searchservice.asmx` (hardcoded in `supabase/functions/tradera-proxy/index.ts`)
  - Mobile client calls the proxy: `lib/services/market/tradera_client.dart` (posts JSON to `TRADERA_PROXY_URL`)
  - Mobile wiring: `lib/main.dart` (constructs `TraderaClient(functionUrl: Uri.parse(config.traderaProxyUrl))`)
  - Background sync depends on proxy presence: `lib/services/sync/background/background_sync.dart`

**Error tracking / analytics (Sentry):**
- Sentry - crash/error reporting and breadcrumb-based analytics
  - SDK: `sentry_flutter` in `pubspec.yaml`
  - Init and release/env wiring: `lib/main.dart`
  - Breadcrumb events/measurements: `lib/services/analytics/analytics_service.dart`

**Model hosting (on-device AI downloads):**
- HTTPS model file hosting for `GEMMA_MODEL_URL` (provider not hardcoded)
  - Download client: `lib/services/ai/model_manager.dart`
  - Config source: `lib/core/config/app_config.dart` (`GEMMA_MODEL_URL`)
  - Wrangler/Cloudflare R2 upload workflow documented in `.sisyphus/notepads/cloudflare-r2-model-upload.md` and tooling declared in `package.json`

## Data Storage

**Databases:**
- Local: SQLite via Drift
  - DB open/migrations: `lib/core/database/app_database.dart`
  - File path: `getApplicationDocumentsDirectory()` + `loppisfynd.sqlite` (`lib/core/database/app_database.dart`)

- Cloud: Supabase Postgres
  - Client use (queries/upserts): `lib/services/sync/cloud_metadata_sync_service.dart`
  - Tables/migrations + RLS policies:
    - `supabase/migrations/20260214230000_hauls_scan_items.sql`
    - `supabase/migrations/20260215051000_scan_items_condition_multiplier.sql`

**File Storage:**
- Supabase Storage bucket: `scan-photos`
  - Bucket + policies: `supabase/migrations/20260215043000_storage_scan_photos.sql`
  - Upload/download usage: `lib/services/sync/cloud_photo_sync_service.dart`
  - Deletion usage: `lib/services/privacy/cloud_data_deletion_service.dart`

**Caching:**
- Local persistence is the primary cache (Drift SQLite) - `lib/core/database/app_database.dart`
- No dedicated external cache detected (e.g. Redis)

## Authentication & Identity

**Auth Provider:**
- Supabase Auth
  - Mobile init: `lib/main.dart` (`Supabase.initialize(...)` gated by `AppConfig.hasSupabase`)
  - Email OTP flow: `lib/features/auth/email_otp_auth.dart` (`signInWithOtp`, `verifyOTP`)
  - Session/current user use: `lib/services/sync/cloud/cloud_sync_coordinator.dart`, `lib/services/sync/cloud_metadata_sync_service.dart`

## Monitoring & Observability

**Error Tracking:**
- Sentry (`sentry_flutter`) - `lib/main.dart`

**Logs:**
- No structured logging backend detected; Sentry breadcrumbs used when enabled - `lib/services/analytics/analytics_service.dart`

## CI/CD & Deployment

**Hosting:**
- Mobile apps (Android/iOS). Android build flavors configured in `android/app/build.gradle.kts`.
- Supabase (hosted DB/auth/storage + edge functions) config in `supabase/config.toml`.
- Optional model hosting via Cloudflare R2/Workers described in `.sisyphus/notepads/cloudflare-r2-model-upload.md`.

**CI Pipeline:**
- GitHub Actions - `.github/workflows/ci.yml`
  - Runs: `flutter analyze`, `flutter pub run custom_lint`, `flutter test`
  - Builds Android App Bundles for `staging` and `prod` flavors

## Environment Configuration

**Required env vars (compile-time `--dart-define`):**
- `APP_ENV` - read in `lib/core/config/app_config.dart` and used in `lib/main.dart` (Sentry environment)
- `TRADERA_PROXY_URL` - read in `lib/core/config/app_config.dart`, used by `lib/services/market/tradera_client.dart` and `lib/services/sync/background/background_sync.dart`
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` - read in `lib/core/config/app_config.dart`, used for `Supabase.initialize` in `lib/main.dart`
- `GEMMA_MODEL_URL` - read in `lib/core/config/app_config.dart`, downloaded by `lib/services/ai/model_manager.dart`
- `SENTRY_DSN` - read in `lib/core/config/app_config.dart`, used in `lib/main.dart`
- `FF_DISABLE_SYNC`, `FF_DISABLE_MARKET`, `FF_DISABLE_AI`, `FF_DISABLE_ANALYTICS` - read in `lib/core/config/feature_flags.dart`

**Required env vars (Supabase Edge Function secrets):**
- Tradera proxy: `TRADERA_APP_ID`, `TRADERA_APP_KEY` (required), `TRADERA_SANDBOX`, `TRADERA_MAX_RESULT_AGE` (optional) - `supabase/functions/tradera-proxy/index.ts`
- Account deletion: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` - `supabase/functions/account-delete/index.ts`

**Secrets location:**
- Mobile app runtime config uses `--dart-define` (documented in `docs/release_playstore.md`); treat values as non-secret once shipped.
- Server-side secrets are stored in Supabase secrets for Edge Functions - `supabase/functions/**`
- Android signing secrets are provided via GitHub Actions secrets or local `android/key.properties` - `.github/workflows/ci.yml`, `android/app/build.gradle.kts`, `docs/release_playstore.md`

## Webhooks & Callbacks

**Incoming:**
- Supabase Edge Function endpoints:
  - `tradera-proxy` - `supabase/functions/tradera-proxy/index.ts`
  - `account-delete` - `supabase/functions/account-delete/index.ts` (invoked by `lib/features/settings/account_deletion_screen.dart`)

**Outgoing:**
- Tradera SOAP request from edge function: `supabase/functions/tradera-proxy/index.ts`
- Model download via HTTPS from `GEMMA_MODEL_URL`: `lib/services/ai/model_manager.dart`
- Supabase REST/storage operations from mobile client: `lib/services/sync/cloud_metadata_sync_service.dart`, `lib/services/sync/cloud_photo_sync_service.dart`

---

*Integration audit: 2026-02-21*
