---
phase: 03-startup-auth-model-download
plan: 03
subsystem: ai
tags: [riverpod, flutter_gemma, model-download, consent]

# Dependency graph
requires:
  - phase: 03-startup-auth-model-download
    provides: "Onboarding Gemma consent persistence via gemma_consent_v1"
provides:
  - "Consent-gated ModelInstallController for Gemma download+install with real progress"
  - "No startup auto-download; downloads only start after persisted consent"
  - "Dashboard/settings download entrypoints routed through controller"
affects: [03-startup-auth-model-download, phase-4-core-screens-goldens]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Riverpod StateNotifier controller owns download/install state machine"
    - "Persisted consent (gemma_consent_v1) hard-gated before any downloadFromUrl call"
    - "flutter_gemma install step extracted as reusable helper and used by controller"

key-files:
  created:
    - lib/services/ai/model_install_controller.dart
  modified:
    - lib/main.dart
    - lib/core/app/providers.dart
    - lib/services/ai/inference/flutter_gemma_backend.dart
    - lib/features/onboarding/onboarding_screen.dart
    - lib/features/dashboard/dashboard_screen.dart
    - lib/features/settings/settings_screen.dart
    - lib/features/model_manager/widgets/model_download_card.dart

key-decisions:
  - "Trigger controller start via an app-level Riverpod listener when consent flips to accepted, plus explicit onboarding trigger for immediate kickoff"
  - "Controller exposes stable failed state and manual retry (no automatic retries)"

patterns-established:
  - "All model download entrypoints go through ModelInstallController; UI never calls ModelManager.downloadFromUrl directly"

requirements-completed: [ONB-03, MDL-01, MDL-02]

# Metrics
duration: 19 min
completed: 2026-02-18
---

# Phase 3 Plan 3: Consent-Gated Model Download Controller Summary

**Model downloads are now strictly consent-gated and controller-driven, with real download/install states and progress surfaced to onboarding + dashboard UI.**

## Performance

- **Duration:** 19 min
- **Started:** 2026-02-18T22:13:51Z
- **Completed:** 2026-02-18T22:33:19Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments

- Added `ModelInstallController` Riverpod state machine (idle/not-consented/downloading/installing/ready/failed) with retry.
- Removed startup best-effort auto-download; model downloads only start after persisted consent (`gemma_consent_v1 == 1`).
- Refactored onboarding + dashboard + (dev-mode) settings download triggers to call controller methods only, using real progress and a real `flutter_gemma` install step.

## Task Commits

Each task was committed atomically:

1. **Task 1: Create ModelInstallController + consent gating and remove startup auto-download** - `4caa58c` (feat)
2. **Task 2: Refactor onboarding + dashboard download triggers to use ModelInstallController** - `ff1a3b8` (feat)

**Plan metadata:** pending

## Files Created/Modified

- `lib/services/ai/model_install_controller.dart` - Consent-gated download+install controller with real progress and retry.
- `lib/core/app/providers.dart` - Exposes `gemmaConsentProvider` and `modelInstallControllerProvider` for UI consumption.
- `lib/main.dart` - Removes startup auto-download; kicks off controller only when persisted consent is accepted.
- `lib/services/ai/inference/flutter_gemma_backend.dart` - Extracts reusable Gemma install helper.
- `lib/features/onboarding/onboarding_screen.dart` - On consent accept, persists consent then triggers controller start (non-blocking).
- `lib/features/dashboard/dashboard_screen.dart` - Dashboard preflight card uses controller state/actions (no direct downloads).
- `lib/features/settings/settings_screen.dart` - Dev-mode download button sets consent then runs controller (no direct downloads).
- `lib/features/model_manager/widgets/model_download_card.dart` - Status text is caller-provided (localized), no hardcoded English.

## Decisions Made

- App-level orchestration uses a Riverpod listener on `gemmaConsentProvider` to start model install automatically when consent becomes accepted during runtime.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Removed hardcoded English status strings from ModelDownloadCard**
- **Found during:** Task 2 (Dashboard preflight refactor)
- **Issue:** Download status text was hardcoded ("Downloading..." / "Ready to use"), violating the repo's localization constraint.
- **Fix:** Added `statusText` param so UI passes fully-localized status strings.
- **Files modified:** `lib/features/model_manager/widgets/model_download_card.dart`, `test/features/model_manager/widgets/model_download_card_test.dart`
- **Verification:** `flutter analyze`, `flutter test`
- **Committed in:** `ff1a3b8`

---

**Total deviations:** 1 auto-fixed (1 missing critical)
**Impact on plan:** Localization fix was required for correctness and did not expand scope beyond the planned UI refactor.

## Issues Encountered

- Riverpod 2.6.1 asserts that `ref.listen` cannot be called from `initState`; listener was moved into `build` and startup kickoff kept best-effort.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Consent gating + real-state controller is in place; Phase 03-04 can build the lightweight status chip + one-time completion popup on top of `ModelInstallControllerState.ready()`.

## Self-Check: PASSED

- FOUND: `.planning/phases/03-startup-auth-model-download/03-03-SUMMARY.md`
- FOUND: task commit `4caa58c`
- FOUND: task commit `ff1a3b8`
