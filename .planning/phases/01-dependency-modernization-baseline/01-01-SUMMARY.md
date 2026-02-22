---
phase: 01-dependency-modernization-baseline
plan: 01
subsystem: infra
tags: [flutter, riverpod, camera, drift, workmanager, ios, cocoapods, custom_lint]

# Dependency graph
requires: []
provides:
  - Pinned Flutter baseline dependencies (Riverpod 3.2.1, camera 0.11.4, drift/workmanager exact pins)
  - iOS build baseline (iOS 14 deployment target + Flutter Podfile)
  - Green gates: flutter analyze (fatal), custom_lint, flutter test
affects: [01-dependency-modernization-baseline, 01-02-runtime-build-validation]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Exact pinning for baseline dependencies in pubspec.yaml
    - Riverpod 3 legacy providers imported via flutter_riverpod/legacy.dart
    - Analyzer exclude for archived code paths not part of the app

key-files:
  created:
    - ios/Podfile
  modified:
    - ios/Runner.xcodeproj/project.pbxproj
    - pubspec.yaml
    - pubspec.lock
    - lib/core/app/providers.dart
    - lib/services/ai/model_install_controller.dart
    - lib/main.dart
    - lib/core/navigation/app_nav_shell.dart
    - lib/features/onboarding/onboarding_screen.dart
    - analysis_options.yaml

key-decisions:
  - "Keep Riverpod legacy providers working by pinning Riverpod 3 and using flutter_riverpod/legacy.dart for StateProvider/StateNotifierProvider"

patterns-established:
  - "Baseline upgrades are verified via: dart format (check) + flutter analyze (fatal) + custom_lint + flutter test"

requirements-completed: [DEP-01, DEP-02, DEP-03, DEP-04]

# Metrics
duration: 17 min
completed: 2026-02-22
---

# Phase 1 Plan 01: Dependency Modernization Baseline Summary

**Upgraded Riverpod/camera baseline with exact pins, iOS 14.0 pod tooling, and a fully green analyze/lint/test gate.**

## Performance

- **Duration:** 17 min
- **Started:** 2026-02-21T23:51:31Z
- **Completed:** 2026-02-22T00:08:36Z
- **Tasks:** 3
- **Files modified:** 10

## Accomplishments

- Raised iOS deployment target to 14.0 and restored a Flutter-stable `ios/Podfile`
- Pinned baseline deps (Riverpod 3.2.1, camera 0.11.4, drift/workmanager exact pins) and migrated legacy providers
- Re-validated Drift codegen pipeline and DB/DAO tests after upgrades

## Task Commits

Each task was committed atomically:

1. **Task 1: Bump iOS deployment target and restore Podfile** - `3626d7f` (chore)
2. **Task 2: Upgrade Riverpod + camera with tight pins and fix forward compile issues** - `5e2baa9` (chore)
3. **Task 3: Validate Drift codegen + migrations/queries are still working** - `31bfbc4` (chore; allow-empty verification commit)

**Plan metadata:** (added after execution)

## Files Created/Modified

- `ios/Runner.xcodeproj/project.pbxproj` - iOS deployment target set to 14.0 for plugin compatibility
- `ios/Podfile` - Flutter-stable Podfile targeting iOS 14.0
- `pubspec.yaml` - Exact pins for baseline deps (Riverpod/camera/drift/workmanager)
- `pubspec.lock` - Resolved lockfile after upgrades
- `lib/core/app/providers.dart` - Legacy Riverpod providers moved to `flutter_riverpod/legacy.dart`
- `lib/services/ai/model_install_controller.dart` - StateNotifier import updated for Riverpod 3 legacy support
- `lib/core/navigation/app_nav_shell.dart` - AsyncValue API migration (remove `valueOrNull`)
- `lib/main.dart` - AsyncValue API migration (remove `valueOrNull`)
- `lib/features/onboarding/onboarding_screen.dart` - Remove lint-triggering hardcoded interpolation in rich text
- `analysis_options.yaml` - Exclude archived `roadmapv2/` tree from analyzer

## Decisions Made

None - followed plan as specified.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Excluded archived `roadmapv2/` code from analysis**
- **Found during:** Task 2 (flutter analyze)
- **Issue:** Analyzer picked up an archived copy of the app under `roadmapv2/`, causing unrelated Riverpod 3 errors.
- **Fix:** Added `roadmapv2/**` to `analysis_options.yaml` analyzer excludes.
- **Verification:** `flutter analyze --fatal-warnings --fatal-infos` is clean.
- **Committed in:** `5e2baa9`

**2. [Rule 3 - Blocking] Migrated removed `AsyncValue.valueOrNull` usage**
- **Found during:** Task 2 (flutter analyze)
- **Issue:** Riverpod 3 removed/changed the `valueOrNull` extension used in app navigation and startup listeners.
- **Fix:** Switched to `asData?.value` reads where safe.
- **Verification:** `flutter analyze --fatal-warnings --fatal-infos` and `flutter test` pass.
- **Committed in:** `5e2baa9`

**3. [Rule 3 - Blocking] Fixed custom_lint failure on rich text interpolation**
- **Found during:** Task 2 (custom_lint)
- **Issue:** Lint flagged interpolated `TextSpan` as a hardcoded UI string.
- **Fix:** Use `text: body` and add spacing via `WidgetSpan`.
- **Verification:** `flutter pub run custom_lint` is clean.
- **Committed in:** `5e2baa9`

---

**Total deviations:** 3 auto-fixed (3 blocking)
**Impact on plan:** All fixes were required to keep the dependency baseline gate green; no scope creep.

## Issues Encountered

- `flutter pub run custom_lint` initially failed with an INFO-level hardcoded string warning; resolved by adjusting the rich text span composition.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Baseline dependency/tooling upgrade is complete and verified; ready for `01-02-PLAN.md` runtime/build validation.

## Self-Check: PASSED

- FOUND: `.planning/phases/01-dependency-modernization-baseline/01-01-SUMMARY.md`
- FOUND: task commits `3626d7f`, `5e2baa9`, `31bfbc4`
