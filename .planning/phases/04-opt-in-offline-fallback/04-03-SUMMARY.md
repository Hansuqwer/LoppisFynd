---
phase: 04-opt-in-offline-fallback
plan: 03
subsystem: ui
tags: [offline, settings, licensing, flutter]

# Dependency graph
requires:
  - phase: 04-opt-in-offline-fallback
    provides: 04-01 offline model catalog + 04-02 download controller
provides:
  - Offline identification opt-in toggle (default OFF) with one-time download suggestion
  - Legal screens for third-party licenses + offline model license summaries/full text
  - Offline license registration (runtime + weights + dataset) via LicenseRegistry
affects: [04-opt-in-offline-fallback-04]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Settings-gated capability with persisted keys (v1)
    - LicenseRegistry entries sourced from OfflineModelSpec

key-files:
  created:
    - lib/features/settings/legal_screen.dart
    - lib/services/offline_detection/offline_licenses.dart
  modified:
    - lib/features/settings/settings_screen.dart
    - lib/main.dart
    - lib/l10n/app_en.arb
    - lib/l10n/app_sv.arb
    - lib/gen/app_localizations.dart
    - lib/gen/app_localizations_en.dart
    - lib/gen/app_localizations_sv.dart

key-decisions:
  - "Use SnackBar action for the one-time download suggestion (non-modal)"
  - "Expose offline license summaries in a dedicated screen plus full-text viewer"

patterns-established:
  - "Offline attribution lives both in Settings and in a global Legal screen"

requirements-completed: [AI-05, OFF-04]

# Metrics
duration: 6 min
completed: 2026-02-24
---

# Phase 4 Plan 03: Opt-In + Attribution Foundation Summary

**Offline identification is now an explicit opt-in in Settings, with a one-time download suggestion and in-app offline license/attribution surfaces backed by LicenseRegistry full texts.**

## Performance

- **Duration:** 6 min
- **Started:** 2026-02-24T08:18:30Z
- **Completed:** 2026-02-24T08:24:23Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments
- Added Settings opt-in toggle (default OFF) for offline identification and a one-time non-blocking download suggestion.
- Added a global Legal screen with third-party licenses (showLicensePage) and offline model license summaries with full-text views.
- Registered offline license entries (runtime + weights + dataset) from OfflineModelSpec so showLicensePage includes verifiable full texts.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add Settings opt-in toggle + one-time download suggestion + offline attribution entry** - `065255e` (feat)
2. **Task 2: Register offline licenses (runtime + weights + dataset) with full texts** - `0ee10d4` (feat)

Follow-up fix:
- `87483d5` (fix): remove unused import to satisfy `flutter analyze`

## Files Created/Modified
- `lib/features/settings/settings_screen.dart` - Offline opt-in toggle, one-time download suggestion, and Legal entry.
- `lib/features/settings/legal_screen.dart` - Legal screen + offline license summaries and full text viewer.
- `lib/services/offline_detection/offline_licenses.dart` - LicenseRegistry registration for runtime/weights/dataset from OfflineModelSpec.
- `lib/main.dart` - Calls `registerOfflineLicenses()` before `runApp`.
- `lib/l10n/app_en.arb` - New strings for offline toggle, download suggestion, and legal screens.
- `lib/l10n/app_sv.arb` - Swedish translations for the above.

## Decisions Made
- Use a SnackBar action (not a modal dialog) for the one-time download suggestion to keep the opt-in flow non-blocking.
- Provide a dedicated offline license summaries screen with explicit "View full license text" actions, in addition to showLicensePage.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- `flutter analyze` flagged an unused import in `lib/services/offline_detection/offline_licenses.dart`; removed and re-verified.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for 04-04 to wire the download controller into UI surfaces and connect offline detection entry points; Legal + attribution foundation is in place.

## Self-Check: PASSED
