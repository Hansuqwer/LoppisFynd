# Play Store release

This repo uses Android product flavors to separate environments.

## Flavors

- `dev`
- `staging`
- `prod`

Android flavor config lives in `android/app/build.gradle.kts`.

Examples:

```bash
flutter run --flavor dev
flutter run --flavor staging
flutter run --flavor prod
```

Runtime config is provided via `--dart-define` (never commit secrets):

```bash
flutter run --flavor staging \
  --dart-define=APP_ENV=staging \
  --dart-define=TRADERA_PROXY_URL=https://<project>.functions.supabase.co/tradera-proxy \
  --dart-define=SUPABASE_URL=https://<project>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key> \
  --dart-define=GEMMA_MODEL_URL=https://<cdn>/gemma_vision.task \
  --dart-define=SENTRY_DSN=<dsn>
```

Notes:
- If `SENTRY_DSN` is empty/unset, Sentry is disabled (no-op) and the app runs normally.

Build an AAB:

```bash
flutter build appbundle --flavor staging --release
flutter build appbundle --flavor prod --release
```

## Android signing (required for Play uploads)

Release builds will use `android/key.properties` if it exists; otherwise they
fall back to the debug keystore (useful for local `--release` runs, not for Play
uploads).

Keep these out of git:
- `android/key.properties`
- `android/app/*.jks`

Expected `android/key.properties` shape:

```properties
storePassword=...
keyPassword=...
keyAlias=...
storeFile=app/upload-keystore.jks
```

## CI

GitHub Actions workflow: `.github/workflows/ci.yml`
- Runs: `flutter analyze`, `flutter test`, and builds `staging` + `prod` AAB.
- Optional signing via secrets:
  - `ANDROID_KEYSTORE_BASE64`
  - `ANDROID_KEYSTORE_PASSWORD`
  - `ANDROID_KEY_ALIAS`
  - `ANDROID_KEY_PASSWORD`

## Versioning

Project version lives in `pubspec.yaml` as `x.y.z+build`.
- `x.y.z` (SemVer): user-visible version
- `build`: monotonically increasing integer for stores/CI

Examples:
- `1.0.0+1`
- `1.0.1+2`

## Account deletion (Supabase Edge Function)

The app can call the `account-delete` Edge Function for in-app account deletion.

- Function source: `supabase/functions/account-delete/index.ts`
- Required Supabase secret:
  - `SUPABASE_SERVICE_ROLE_KEY`

The function deletes user-owned rows in:
- `hauls`
- `scan_items`

And attempts to remove scan photos from Storage bucket:
- `scan-photos` (paths under `{userId}/scan_items/...`)
