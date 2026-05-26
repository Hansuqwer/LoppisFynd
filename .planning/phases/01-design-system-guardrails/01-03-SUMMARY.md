---
phase: 01-design-system-guardrails
plan: 03
subsystem: ui
tags: [flutter, custom_lint, l10n, arb, ci]

# Dependency graph
requires: []
provides:
  - Custom lint guardrails for hardcoded UI strings, raw BackdropFilter, and ad-hoc UI constants
  - Contract-required v2 localization keys (sv/en) regenerated into AppLocalizations
affects: [capsule-nav, onboarding, auth, home, haul, drafts]

# Tech tracking
tech-stack:
  added: [custom_lint, custom_lint_builder]
  patterns:
    - "Local custom_lint plugin under packages/ and enabled via analyzer plugins"
    - "Glass blur allowed only via shared glass_* primitives"
    - "User-facing strings in UI sinks must come from AppLocalizations"

key-files:
  created:
    - packages/fynd_loppis_lints/pubspec.yaml
    - packages/fynd_loppis_lints/lib/fynd_loppis_lints.dart
    - lib/core/tokens/app_capsule_nav.dart
  modified:
    - pubspec.yaml
    - analysis_options.yaml
    - .github/workflows/ci.yml
    - lib/l10n/app_sv.arb
    - lib/l10n/app_en.arb
    - lib/main.dart
    - lib/shared/widgets/error_banner.dart

key-decisions:
  - "Use custom_lint 0.8.x to stay compatible with the repo's analyzer constraints"
  - "Add AppCapsuleNav/AppShadows tokens to keep shared primitives free of ad-hoc numbers"

patterns-established:
  - "Guardrails run in CI: flutter pub run custom_lint"
  - "No hardcoded UI strings in Text/TextSpan/InputDecoration/Tooltip/Semantics"

requirements-completed: [DS-01, DS-02, L10N-01, L10N-02, L10N-03]

# Metrics
duration: 29 min
completed: 2026-02-18
---

# Phase 01 Plan 03: Design System Guardrails Summary

**Custom lint + CI enforcement for UI string/copy guardrails, plus v2 sv/en localization keys regenerated into AppLocalizations.**

## Performance

- **Duration:** 29 min
- **Started:** 2026-02-18T03:55:35Z
- **Completed:** 2026-02-18T04:24:52Z
- **Tasks:** 2
- **Files modified:** 25

## Accomplishments
- Added `custom_lint` + a local lint plugin package and wired it into analyzer + GitHub Actions CI.
- Implemented initial UI guardrails: no raw `BackdropFilter` in feature code, no hardcoded UI strings in common sinks, and no ad-hoc numeric constants in shared widgets.
- Added contract-required v2 localization keys (model/auth/home/haul/draft), removed shipped fallback strings, and regenerated `lib/gen/app_localizations*.dart`.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add custom_lint + lint plugin package (project guardrails)** - `f8e4864` (chore)
2. **Task 2: Apply contract-required localization keys and copy fixes (Swedish)** - `7011061` (feat)

**Plan metadata:** (pending)

## Files Created/Modified
- `packages/fynd_loppis_lints/` - Custom lint plugin implementing project UI constraints
- `analysis_options.yaml` - Enables `custom_lint` analyzer plugin
- `.github/workflows/ci.yml` - Runs `flutter pub run custom_lint` in CI
- `lib/l10n/app_sv.arb` - Swedish v2 keys + fixes
- `lib/l10n/app_en.arb` - English parity for v2 keys
- `lib/main.dart` - Removed title fallback + localized error widget
- `lib/shared/widgets/error_banner.dart` - Removed hardcoded retry fallback

## Decisions Made
- Used `custom_lint`/`custom_lint_builder` 0.8.x (older 0.7.x conflicted with analyzer constraints in this repo).
- Introduced `AppCapsuleNav` + `AppShadows.capsuleNav` tokens to keep capsule nav primitives token-driven and lint-clean.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Resolved custom_lint vs analyzer dependency conflict**
- **Found during:** Task 1
- **Issue:** `custom_lint` 0.7.x required analyzer ^7, conflicting with existing dev tooling.
- **Fix:** Bumped to `custom_lint` 0.8.x / `custom_lint_builder` 0.8.x.
- **Verification:** `flutter pub get` + `flutter pub run custom_lint` succeed.
- **Committed in:** `f8e4864`

**2. [Rule 3 - Blocking] Made lint plugin analyzable in-app**
- **Found during:** Task 2 verification
- **Issue:** Analyzer flagged missing `analyzer` dependency and deprecated reporter API, causing `flutter analyze` to fail.
- **Fix:** Added `analyzer` dependency and switched lint reporters to `DiagnosticReporter`.
- **Verification:** `flutter analyze` succeeds.
- **Committed in:** `7011061`

---

**Total deviations:** 2 auto-fixed (2 blocking)
**Impact on plan:** Both fixes were required for CI/verification to pass; no feature scope creep.

## Issues Encountered
- Dependency resolution required updating `custom_lint` versions to match analyzer constraints.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Guardrails are enforced in CI and IDE analyzer; ready to proceed with Phase 2 UI work without silently regressing localization/copy.

## Self-Check: PASSED

- FOUND: `.planning/phases/01-design-system-guardrails/01-03-SUMMARY.md`
- FOUND: `f8e4864`
- FOUND: `7011061`
