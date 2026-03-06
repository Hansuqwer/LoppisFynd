# LoppisFynd

Offline-first Flutter app for resellers at flea markets (loppis). Scan items, get AI-powered identification and market price estimates, track hauls, and sync to the cloud.

## Architecture

- **Flutter/Dart** – Riverpod for state, Drift/SQLite for offline-first local DB.
- **Supabase** – Auth, Postgres (cloud sync), Storage (photos), Edge Functions.
- **Edge Functions** (Deno/TypeScript):
  - `cloud-ai-proxy` – Proxies image+prompt to Gemini for item identification.
  - `tradera-proxy` – Proxies search requests to Tradera SOAP API with rate limiting (Upstash Redis).
  - `account-delete` – GDPR account + data deletion.

## Prerequisites

- Flutter SDK (revision pinned in `.metadata` – CI extracts it automatically)
- Dart SDK ^3.10.8
- Java 17 (for Android builds)
- Deno v2+ (for edge function development/testing)
- Supabase CLI (for local Supabase dev and deploying edge functions)

## Setup

```bash
cp .env.example .env          # fill in your secrets
flutter pub get
```

### Supabase (local)

```bash
supabase start                # runs local Supabase stack
supabase db push              # applies migrations
supabase functions serve      # starts edge functions locally
```

### Edge Function Secrets (production)

```bash
supabase secrets set GEMINI_API_KEY=... GEMINI_MODEL=gemini-2.5-flash
supabase secrets set TRADERA_APP_ID=... TRADERA_APP_KEY=...
supabase secrets set UPSTASH_REDIS_REST_URL=... UPSTASH_REDIS_REST_TOKEN=...
```

## Run

```bash
# Dev (default)
flutter run --dart-define=APP_ENV=dev

# With all config
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=SUPABASE_URL=http://localhost:54321 \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=CLOUD_AI_PROXY_URL=http://localhost:54321/functions/v1/cloud-ai-proxy \
  --dart-define=TRADERA_PROXY_URL=http://localhost:54321/functions/v1/tradera-proxy
```

## Test

```bash
# Flutter
flutter test

# Dart format + analyze
dart format --output=none --set-exit-if-changed lib test
flutter analyze

# Edge functions (Deno)
deno test --allow-env supabase/functions/cloud-ai-proxy/tests/
deno test --allow-env --allow-net supabase/functions/tradera-proxy/tests/
```

## Build

```bash
flutter build appbundle --flavor staging --release --dart-define=APP_ENV=staging
flutter build appbundle --flavor prod --release --dart-define=APP_ENV=prod
```

## Deploy Edge Functions

```bash
supabase functions deploy cloud-ai-proxy
supabase functions deploy tradera-proxy
supabase functions deploy account-delete
```

## Project Structure

```
lib/
  core/         # Database, config, theme, navigation, tokens
  features/     # Screen-level features (scanner, history, settings, …)
  services/     # AI, market, sync, analytics, privacy
  shared/       # Reusable widgets
supabase/
  functions/    # Edge functions (Deno/TypeScript)
  migrations/   # Postgres migrations
test/           # Flutter unit + widget tests
.planning/      # Internal planning docs
docs/           # User-facing docs (privacy policy, QA matrix, …)
```