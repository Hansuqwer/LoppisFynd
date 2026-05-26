---
phase: 04-opt-in-offline-fallback
plan: 01
subsystem: offline_detection
tags: [tflite_flutter, tflite, http-range, pause-resume, sha256, licensing]

# Dependency graph
requires:
  - phase: 03-sold-price-comps-hardening
    provides: Existing `ModelManager` with HTTP Range-based resume plumbing
provides:
  - Offline model catalog with <10MiB budget guard and license full texts
  - Range-resumable download pipeline with pause/cancel semantics
  - UI-friendly offline model download controller (state + commands)
affects: [04-02, 04-03, 04-04, offline-detection, settings, licensing]

# Tech tracking
tech-stack:
  added: [tflite_flutter, crypto]
  patterns: [OfflineModelSpec catalog, pause-keeps-partial/cancel-deletes-partial, sha256 post-download verification]

key-files:
  created:
    - lib/services/offline_detection/offline_model_catalog.dart
    - lib/services/offline_detection/offline_model_download_controller.dart
    - test/services_offline_detection/offline_model_download_controller_test.dart
  modified:
    - lib/services/ai/model_manager.dart
    - test/services_ai/fl_030_model_manager_test.dart
    - pubspec.yaml
    - pubspec.lock

key-decisions:
  - "Select TensorFlow-hosted EfficientDet Lite0 detection metadata model (<10MiB) and pin expectedBytes + sha256"
  - "Ship full Apache-2.0 and CC BY 4.0 legal texts in catalog for OFF-04 attribution surfaces"

patterns-established:
  - "Pause vs cancel semantics: pause preserves .partial for HTTP Range resume; cancel deletes .partial"
  - "Controller state is a small sealed model to drive UI without leaking ModelManager details"

requirements-completed: [OFF-02, OFF-04]

# Metrics
duration: 30 min
completed: 2026-02-24
---

# Phase 4 Plan 1: Offline Model Catalog + Download Pipeline Summary

**Offline model catalog + download foundation: <10MiB guardrails, full license texts, and pause/resume/cancel downloads backed by HTTP Range.**

## Performance

- **Duration:** 30 min
- **Started:** 2026-02-24T06:22:06Z
- **Completed:** 2026-02-24T06:52:46Z
- **Tasks:** 3
- **Files modified:** 12

## Accomplishments
- Added `OfflineModelSpec` catalog entry pinned to an exact remote `.tflite` artifact with `expectedBytes` + `sha256Hex`, and enforced a hard 10MiB cap.
- Extended `ModelManager.downloadFromUrl` with true pause semantics (preserve `.partial`) distinct from cancel/error cleanup.
- Implemented `OfflineModelDownloadController` with a small state model and `startOrResume/pause/cancel` API including optional sha256 verification.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add offline model catalog with size + license metadata** - `4b67088` (feat)
2. **Task 2: Extend ModelManager download to support true Pause vs Cancel** - `b5aa2ec` (feat)
3. **Task 3: Implement offline model download controller with pause/resume/cancel API** - `60724a2` (feat)

Additional verification fix:
- `cca45e6` (fix) - remove an unnecessary test import so `flutter analyze` stays clean

## Files Created/Modified
- `lib/services/offline_detection/offline_model_catalog.dart` - offline model source-of-truth (size/sha/url + full license texts)
- `lib/services/ai/model_manager.dart` - paused download keeps `.partial` while cancel/error still cleans up
- `lib/services/offline_detection/offline_model_download_controller.dart` - UI-friendly wrapper with state + commands, size guard, sha verification
- `test/services_ai/fl_030_model_manager_test.dart` - pause/resume coverage using a local HttpServer + Range
- `test/services_offline_detection/offline_model_download_controller_test.dart` - controller progress, pause/resume, cancel cleanup
- `pubspec.yaml` / `pubspec.lock` - add `tflite_flutter` and `crypto`

## Decisions Made
- Chose TensorFlow-hosted EfficientDet Lite0 detection metadata weights for the initial offline model (pinned by bytes + sha256).
- Embedded full Apache-2.0 and CC BY 4.0 legal texts in the catalog for OFF-04 (runtime + weights + dataset attribution).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed pre-existing analyzer issues so `flutter analyze` can be used as a verification gate**
- **Found during:** Task 1 verification (`flutter analyze`)
- **Issue:** Repo had existing lints that made `flutter analyze` fail, blocking plan verification
- **Fix:** Removed/adjusted unused imports and lint violations in a handful of UI files (no behavior change intended)
- **Files modified:**
  - `lib/core/navigation/app_nav_shell.dart`
  - `lib/core/settings/app_settings_keys.dart`
  - `lib/features/analyzer/item_detail_screen.dart`
  - `lib/features/onboarding/onboarding_screen.dart`
  - `lib/services/ai/cloud_ai_proxy_client.dart`
- **Verification:** `flutter analyze` passes
- **Committed in:** `4b67088`

**2. [Rule 1 - Bug] Removed an unnecessary test import discovered by plan-wide verification**
- **Found during:** Final `<verification>` (`flutter analyze`)
- **Issue:** `test/services_offline_detection/offline_model_download_controller_test.dart` had an unnecessary import flagged by analyzer
- **Fix:** Removed the unused import
- **Files modified:** `test/services_offline_detection/offline_model_download_controller_test.dart`
- **Verification:** `flutter analyze` passes
- **Committed in:** `cca45e6`

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 bug)
**Impact on plan:** Both fixes were required to keep verification gates green; no scope creep.

## Issues Encountered
- `flutter analyze` initially failed due to unrelated pre-existing lints; resolved as a blocking verification issue.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Plan 04-02 can now focus on the offline detector runtime (parsing + evidence schema) while using this catalog/controller foundation.

---
*Phase: 04-opt-in-offline-fallback*
*Completed: 2026-02-24*

## Self-Check: PASSED

- FOUND: `.planning/phases/04-opt-in-offline-fallback/04-01-SUMMARY.md`
- FOUND commits: `4b67088`, `b5aa2ec`, `60724a2`, `cca45e6`
