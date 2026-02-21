---
phase: 04-core-screens-goldens
plan: 03
subsystem: testing
tags: [flutter, goldens, drift, offline]

# Dependency graph
requires:
  - phase: 04-core-screens-goldens-01
    provides: Core screen reskins used as golden baselines
  - phase: 04-core-screens-goldens-02
    provides: Settings module parity + Dev Mode gating regression
provides:
  - Golden tests + PNG baselines for Dashboard, History empty, Draft editor
  - Offline smoke test for core tab rendering + draft save
affects: [ui, regression, ci, core-screens]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - ProviderScope overrides with AppDatabase.inMemory() seeding
    - Golden tests with deterministic surface size + runtime font fetching disabled

key-files:
  created:
    - test/features_dashboard/dashboard_screen_golden_test.dart
    - test/features_history/history_empty_golden_test.dart
    - test/features_drafts/draft_editor_golden_test.dart
    - test/fl_070_offline_core_screens_smoke_test.dart
    - test/goldens/dashboard_screen.png
    - test/goldens/history_empty.png
    - test/goldens/draft_editor.png
  modified:
    - test/features_auth/login_screen_golden_test.dart
    - lib/features/dashboard/dashboard_screen.dart
    - lib/main.dart
    - test/fl_065_nav_smoke_test.dart
    - test/widget_test.dart

key-decisions:
  - "Prefer keeping offline regression fast by pumping DraftEditorScreen directly instead of navigating via Dashboard tiles."

patterns-established:
  - "Golden tests should dispose the widget tree after expectLater to avoid pending Drift stream timers."

requirements-completed: [QA-01, OFF-01]

# Metrics
duration: 41m
completed: 2026-02-19
---

# Phase 04 Plan 03: Golden Coverage + Offline Regression Summary

**Golden baselines for key Nature Distilled screens (Home, History empty, Draft editor) plus an offline-first smoke test to catch online-only regressions.**

## Performance

- **Duration:** 41m
- **Started:** 2026-02-19T18:25:17Z
- **Completed:** 2026-02-19T19:06:41Z
- **Tasks:** 2
- **Files modified:** 12

## Accomplishments
- Added golden tests and committed PNG baselines for Dashboard, History empty state, and Draft editor.
- Added an offline smoke test that renders core tabs offline and verifies Draft save works without network.
- Stabilized test harness to avoid pending Drift timers and model filename mismatches.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add goldens for Home, History empty, and Draft editor (and keep Login golden up to date)** - `5d4c0a4` (test)
2. **Task 2: Add an offline-first regression smoke test for core flows/screens** - `9d3621d` (test)

## Files Created/Modified
- test/features_dashboard/dashboard_screen_golden_test.dart - Dashboard/Home golden harness using AppNavShell + in-memory DB.
- test/features_history/history_empty_golden_test.dart - History empty-state golden harness (navigates to History tab).
- test/features_drafts/draft_editor_golden_test.dart - Draft editor golden harness with seeded ScanItem + Draft.
- test/fl_070_offline_core_screens_smoke_test.dart - Offline regression smoke covering core tabs + offline draft save.
- test/goldens/dashboard_screen.png - Dashboard baseline.
- test/goldens/history_empty.png - History empty baseline.
- test/goldens/draft_editor.png - Draft editor baseline.

## Decisions Made
- Prefer direct screen pumping for offline save verification (DraftEditorScreen) to keep tests deterministic and avoid brittle UI navigation assumptions.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed dashboard tile RenderFlex overflow exposed by golden constraints**
- **Found during:** Task 1 (golden generation)
- **Issue:** Home bento tiles could overflow vertically in the constrained golden surface.
- **Fix:** Made value/subtitle areas flexible inside tiles to adapt to tight heights.
- **Files modified:** lib/features/dashboard/dashboard_screen.dart
- **Verification:** flutter test (goldens + full suite)
- **Committed in:** 86f0f43

**2. [Rule 1 - Bug] Standardized Gemma model filename to .litertlm**
- **Found during:** Task 1 (test harness consistency)
- **Issue:** App/test harness referenced gemma_vision.task while the project uses .litertlm for on-device models.
- **Fix:** Updated ModelSpec fileName to gemma_vision.litertlm in app bootstrap + key smoke tests.
- **Files modified:** lib/main.dart, test/fl_065_nav_smoke_test.dart, test/widget_test.dart
- **Verification:** flutter test
- **Committed in:** d18688b

---

**Total deviations:** 2 auto-fixed (Rule 1)
**Impact on plan:** Both fixes were required to make goldens stable and keep the on-device model path consistent.

## Issues Encountered
- Golden generation initially surfaced layout overflow + pending timers; resolved by layout flexibility and disposing test trees after snapshots.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 04 now has regression coverage (goldens + offline smoke) suitable for CI.

## Self-Check: PASSED

- FOUND: .planning/phases/04-core-screens-goldens/04-03-SUMMARY.md
- FOUND commits: 5d4c0a4, 9d3621d, 86f0f43, d18688b
