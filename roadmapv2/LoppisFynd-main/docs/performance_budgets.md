# Performance, battery, and size budgets (v1.0)

This app is offline-first and runs on low-end devices. These budgets are the release targets for v1.0.

## Targets

- Cold start (first frame): <= 1.5s on mid-range Android
- Navigation (tab switch / push route): <= 200ms perceived latency
- Scanner: no sustained jank during a 5-item rapid capture session
- Inference: isolate-based; UI thread stays responsive
- Battery: acceptable in a 30-minute scanning session (no runaway background loops)
- Size: keep the app bundle small; model is downloaded via `GEMMA_MODEL_URL` (not bundled)

## Guardrails already in code

- Inference warm-up on scanner entry:
  - `lib/features/scanner/scanner_screen.dart`
  - `lib/services/ai/inference/inference_isolate_service.dart` (`warmUp()`)

- Inference work is off the UI thread:
  - `lib/services/ai/inference/inference_isolate_service.dart` (spawn isolate)

- Inference/capture pipeline is serialized to reduce spikes on rapid capture:
  - `lib/core/utils/serial_task_queue.dart`
  - `lib/features/scanner/scan_capture_service.dart`

- Thumbnail generation runs in a background isolate + has size guardrails:
  - `lib/core/storage/scan_image_storage.dart`
  - Defaults: `thumbMaxEdgePx=320`, `thumbJpegQuality=75`, `maxDecodePixels=40MP`

- Market stats caching to reduce network churn:
  - `lib/services/market/market_bridge.dart` (default TTL 24h)

## QA (low-end)

Run the manual matrix in `docs/qa_manual_matrix.md` on a low-end Android device before release.
