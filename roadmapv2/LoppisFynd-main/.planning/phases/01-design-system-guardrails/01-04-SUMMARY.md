---
phase: 01-design-system-guardrails
plan: 04
subsystem: ui
tags: [design-tokens, custom_lint, boxshadow, flutter]

# Dependency graph
requires:
  - phase: 01-design-system-guardrails
    provides: Design token barrels + guardrail lint baseline from Plans 02-03
provides:
  - Tokenized shadow stack for the Nature Distilled motif overlay
  - LogoMotifOverlay lint-clean under no_ad_hoc_design_constants
affects: [phase-01-verification, shared-widgets, design-system-guardrails]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Tokenize BoxShadow stacks in lib/core/tokens and reference from shared primitives

key-files:
  created: []
  modified:
    - lib/core/tokens/app_shadows.dart
    - lib/shared/widgets/logo_motif_overlay.dart

key-decisions:
  - "Keep motif overlay shadow appearance stable (golden-safe) while removing ad-hoc BoxShadow literals"

patterns-established:
  - "Guardrail scope widgets (lib/shared/widgets) must not construct BoxShadow with numeric literals; use AppShadows tokens"

requirements-completed:
  - DS-01

# Metrics
duration: 10 min
completed: 2026-02-18
---

# Phase 01 Plan 04: Gap Closure Summary

**Tokenized LogoMotifOverlay's BoxShadow stack (AppShadows.motifOverlay) so shared primitives stay custom_lint-clean without changing the login golden output.**

## Performance

- **Duration:** 10 min
- **Started:** 2026-02-18T13:08:04Z
- **Completed:** 2026-02-18T13:18:52Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added `AppShadows.motifOverlay` so the motif overlay glow/shadow is controlled by tokens.
- Updated `LogoMotifOverlay` to reference `AppShadows.motifOverlay`, removing the last guardrail-scope BoxShadow numeric literals.
- Verified `flutter pub run custom_lint`, `flutter analyze`, and `flutter test` all pass clean.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add a tokenized shadow for motif marks** - `556aa1a` (feat)
2. **Task 2: Replace LogoMotifOverlay ad-hoc BoxShadow with the token** - `06f356b` (fix)

## Files Created/Modified

- `lib/core/tokens/app_shadows.dart` - Adds `AppShadows.motifOverlay` token used by the motif overlay mark primitive.
- `lib/shared/widgets/logo_motif_overlay.dart` - Replaces inline BoxShadow list with `AppShadows.motifOverlay`.

## Decisions Made

- Kept the motif overlay shadow stack visually stable (golden-safe) by matching the prior inline BoxShadow values inside the token.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Prevented login screen golden drift from initial motifOverlay token values**
- **Found during:** Task 2 (verification: `flutter test`)
- **Issue:** Switching `LogoMotifOverlay` to the initial `AppShadows.motifOverlay` stack changed the login golden.
- **Fix:** Tuned `AppShadows.motifOverlay` to match the pre-token inline BoxShadow values so the UI stays stable while remaining lint-clean.
- **Files modified:** `lib/core/tokens/app_shadows.dart`
- **Verification:** `flutter test` passes (including goldens)
- **Committed in:** `06f356b`

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Kept the plan's intent (tokenize + lint-clean) while preventing unintended visual drift.

## Issues Encountered

None

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- DS-01 gap is closed: shared primitives in guardrail scope no longer contain ad-hoc BoxShadow numeric literals.
- Ready to continue with `01-05-PLAN.md`.

## Self-Check: PASSED
