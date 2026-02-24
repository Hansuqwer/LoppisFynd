---
phase: 04-opt-in-offline-fallback
plan: 02
subsystem: offline_detection
tags: [tflite_flutter, tflite, offline-detection, evidence, riverpod, isolate]

# Dependency graph
requires:
  - phase: 04-opt-in-offline-fallback
    provides: Offline model catalog + download pipeline from 04-01
provides:
  - Evidence-first offline detection schema with centralized confidence banding
  - Pure-Dart parser turning SSD/EfficientDet tensors into stable evidence objects
  - OfflineDetector service (no-network) wired through Riverpod
affects: [04-03, 04-04, offline-detection, settings]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Evidence-first: normalize model outputs into OfflineDetection + NormalizedRect
    - Pure parsing layer with unit tests for thresholding/sorting/clamping
    - Full detection pipeline runs off the UI isolate via Isolate.run

key-files:
  created:
    - lib/services/offline_detection/offline_detection_types.dart
    - lib/services/offline_detection/offline_detector_parser.dart
    - lib/services/offline_detection/offline_detector.dart
    - test/services_offline_detection/offline_detector_parser_test.dart
  modified:
    - lib/core/settings/app_settings_keys.dart
    - lib/core/app/providers.dart

key-decisions:
  - "Use a hard minimum detection score of 0.35 with centralized High/Med/Low banding for UI display"
  - "Run decode + preprocess + inference in a background isolate (Isolate.run) to avoid UI jank"

patterns-established:
  - "UI consumes OfflineDetection evidence and confidenceInfoForScore() (no UI-side re-implementation)"

requirements-completed: [OFF-01, OFF-03]

# Metrics
duration: 11 min
completed: 2026-02-24
---

# Phase 4 Plan 2: Offline Detector Runtime Summary

**Offline detector runtime that runs without network, produces evidence (boxes + confidence), and centralizes confidence thresholding/banding for UI rendering.**

## Performance

- **Duration:** 11 min
- **Started:** 2026-02-24T07:56:59Z
- **Completed:** 2026-02-24T08:08:34Z
- **Tasks:** 3
- **Files modified:** 6

## Accomplishments

- Added an evidence-first result schema (`OfflineDetection`, `NormalizedRect`) plus a shared confidence cutoff and High/Med/Low band mapping.
- Implemented and tested a parser that clamps/validates normalized boxes, filters low-confidence detections, and sorts by score.
- Implemented `OfflineDetector` that loads a locally installed TFLite model and runs the full pipeline off the UI isolate, exposed via Riverpod providers.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add offline evidence types + confidence banding with hard cutoff** - `7980859` (feat)
2. **Task 2: Implement offline detector parser + tests (evidence correctness)** - `d257e5f` (feat)
3. **Task 3: Implement OfflineDetector service + Riverpod wiring** - `4ff0067` (feat)

## Files Created/Modified

- `lib/services/offline_detection/offline_detection_types.dart` - Evidence schema + shared confidence cutoff and banding
- `lib/services/offline_detection/offline_detector_parser.dart` - Pure parsing for SSD/EfficientDet outputs into evidence
- `lib/services/offline_detection/offline_detector.dart` - TFLite inference runner (background isolate) returning parsed evidence
- `test/services_offline_detection/offline_detector_parser_test.dart` - Parser tests for filtering/sorting/clamping
- `lib/core/settings/app_settings_keys.dart` - Offline identification settings keys (enabled + suggestion shown)
- `lib/core/app/providers.dart` - `offlineIdentificationEnabledProvider` + `offlineDetectorProvider`

## Decisions Made

- Used a hard minimum score cutoff of `0.35` for offline detections, with centralized High/Med/Low band mapping for UI display.
- Implemented offline detection execution via `Isolate.run` so decode/preprocess/inference run off the UI isolate.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Runtime plumbing is in place for 04-03 Settings opt-in + one-time download suggestion UI.
- Evidence schema + parsing is ready for 04-04 split-view boxes + results UX.

---
*Phase: 04-opt-in-offline-fallback*
*Completed: 2026-02-24*

## Self-Check: PASSED

- FOUND: `.planning/phases/04-opt-in-offline-fallback/04-02-SUMMARY.md`
- FOUND commits: `7980859`, `d257e5f`, `4ff0067`
