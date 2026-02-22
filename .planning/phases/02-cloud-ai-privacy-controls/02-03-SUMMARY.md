---
phase: 02-cloud-ai-privacy-controls
plan: 03
subsystem: ai
tags: [cloud-ai, privacy, gemini, supabase, proxy, image-crop]

# Dependency graph
requires:
  - phase: 02-01
    provides: cloud-ai-proxy edge function with request validation + no-store responses
  - phase: 02-02
    provides: first-use cloud disclosure + privacy toggles and Identify gating
provides:
  - Cloud-first Identify backend via Supabase-proxied Gemini (no API keys in app)
  - Crops-only JPEG uploads with metadata stripping + byte budget enforcement
  - Gemma removed from first-run UX; flutter_gemma dependency removed
affects: [phase-04-offline-ai, analyzer, settings, onboarding]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Proxy-backed cloud AI calls configured by CLOUD_AI_PROXY_URL
    - Client-side crop + resize + JPEG re-encode to guarantee EXIF stripping

key-files:
  created:
    - lib/services/ai/cloud_ai_proxy_client.dart
    - lib/services/ai/image_cropper.dart
  modified:
    - lib/services/ai/inference/inference_isolate_service.dart
    - lib/core/config/app_config.dart
    - lib/main.dart
    - lib/features/analyzer/item_detail_screen.dart
    - lib/features/settings/settings_screen.dart
    - lib/core/navigation/app_nav_shell.dart
    - lib/features/dashboard/dashboard_screen.dart

key-decisions:
  - "Cloud AI (proxy) is the default Identify path when CLOUD_AI_PROXY_URL is configured; no on-device model flows in first-run UX"
  - "Enforce PRIV-03 by sending only re-encoded crops (never original photo bytes) and failing if crop cannot fit upload budget"

patterns-established:
  - "Cloud AI contract: { prompt, maxTokens, imageBase64Jpeg } to cloud-ai-proxy"

requirements-completed: [AI-01, AI-02, PRIV-03]

# Metrics
duration: 24 min
completed: 2026-02-22
---

# Phase 2 Plan 3: Cloud AI Default + Gemma Removal Summary

**Cloud-first Identify via a server-proxied Gemini backend with crops-only uploads, plus removal of Gemma download/install from first-run UX.**

## Performance

- **Duration:** 24 min
- **Started:** 2026-02-22T12:50:55Z
- **Completed:** 2026-02-22T13:15:27Z
- **Tasks:** 2
- **Files modified:** 31

## Accomplishments

- Added `AiBackendKind.cloudGemini` backed by `CLOUD_AI_PROXY_URL` with a dedicated HTTP client and strict request contract.
- Implemented a crops-only pipeline (`ImageCropper`) that center-crops, resizes, JPEG re-encodes (metadata stripped), and enforces an upload byte budget.
- Removed Gemma download/install UI + providers from onboarding/dashboard/nav/settings and dropped the `flutter_gemma` dependency.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add cloudGemini backend with crops-only uploads** - `f6e6153` (feat)
2. **Task 2: Remove Gemma from first-run flow and remove flutter_gemma dependency** - `a0a6f55` (feat)

## Files Created/Modified

- `lib/services/ai/cloud_ai_proxy_client.dart` - Posts prompt + maxTokens + crop JPEG base64 to the cloud proxy.
- `lib/services/ai/image_cropper.dart` - Crop/resize/re-encode JPEG for PRIV-03 (crops-only + EXIF stripping) with a size budget.
- `lib/services/ai/inference/inference_isolate_service.dart` - Adds `cloudGemini` execution path + cancellation mapping.
- `lib/core/config/app_config.dart` - Adds `CLOUD_AI_PROXY_URL` config + removes unused Gemma config.
- `lib/features/analyzer/item_detail_screen.dart` - Runs Identify via AI service after disclosure/toggle/online gating.
- `lib/features/settings/settings_screen.dart` - Removes on-device model install surfaces; keeps AI mode + privacy toggles.
- `pubspec.yaml` - Drops `flutter_gemma` dependency.

## Decisions Made

- Removed Gemma from normal UX entirely (no first-run prompts, no status chips, no “AI ready” popups) to satisfy AI-01.
- Made the cloud backend depend only on `CLOUD_AI_PROXY_URL` so production builds can enable cloud Identify without embedding secrets.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Updated tests for new `AppConfig` fields and refreshed goldens after UI removal**
- **Found during:** Task 1 + Task 2
- **Issue:** Widget tests constructed `AppConfig` without the new `cloudAiProxyUrl` field; golden images changed after removing model UI.
- **Fix:** Updated test configs and re-recorded affected golden baselines.
- **Files modified:** `test/**/*.dart`, `test/goldens/*.png`
- **Verification:** `flutter test`
- **Committed in:** `f6e6153`, `a0a6f55`

---

**Total deviations:** 1 auto-fixed (Rule 3)
**Impact on plan:** Purely unblocked verification; no scope creep.

## Issues Encountered

- Golden mismatches after removing model UI (resolved by updating goldens with `flutter test --update-goldens`).

## User Setup Required

None - no new external service configuration required for this plan (cloud proxy URL is a build-time `--dart-define=CLOUD_AI_PROXY_URL=...`).

## Next Phase Readiness

- Cloud Identify path is wired end-to-end (client -> proxy) and respects the Phase 2 disclosure + privacy toggles.
- Manual emulator smoke test from the plan verification checklist is still recommended (fresh install + offline/disabled states), but was not run in this execution environment.

## Self-Check: PASSED

- SUMMARY file present
- Task commits present: f6e6153, a0a6f55
