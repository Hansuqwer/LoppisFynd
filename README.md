# Loppisfynd

Offline-first reseller OS: scan items in-store, identify locally, then (when online) fetch sold-price history via Tradera to decide if something is worth flipping.

North star: `docs/FyndLoppis_OpenCode_Roadmap.md`.

Platform setup notes: `docs/platform_setup.md`.

## Run

Required runtime config is provided via `--dart-define`:

```bash
flutter run \
  --dart-define=TRADERA_PROXY_URL=https://<your-supabase-project>.functions.supabase.co/tradera-proxy \
  --dart-define=SUPABASE_URL=https://<project>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key> \
  --dart-define=GEMMA_MODEL_URL=https://<your-cdn>/gemma_vision.task
```

Notes:
- Tradera credentials must never ship in the app; the app calls the Supabase Edge Function proxy.
- Background market sync uses `workmanager` and shows a local notification when finished.

## Test

```bash
flutter analyze
flutter test
```
