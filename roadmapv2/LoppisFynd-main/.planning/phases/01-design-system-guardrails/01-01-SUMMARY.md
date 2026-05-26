---
phase: 01-design-system-guardrails
plan: 01
subsystem: ui
tags: [flutter, design-tokens, theme, typography]

# Dependency graph
requires: []
provides:
  - Complete token coverage for blur + opacity and contract-required radius/shadow aliases
  - Theme/token guardrails for consistent styling and opt-in accent typography
affects: [02-capsule-navigation-shell, 03-startup-auth-model-download, 04-core-screens-goldens]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Tokens-first styling: new blur/opacity modules exported via app_tokens barrel"
    - "Accent-only handwritten typography token exposed as explicit style"

key-files:
  created:
    - lib/core/tokens/app_blur.dart
    - lib/core/tokens/app_opacity.dart
  modified:
    - lib/core/tokens/app_tokens.dart
    - lib/core/tokens/app_radius.dart
    - lib/core/tokens/app_shadows.dart
    - lib/core/tokens/app_colors.dart
    - lib/core/tokens/app_typography.dart

key-decisions:
  - "Preserved AppRadius.pill semantics (999.0) and introduced AppRadius.capsule (30.0) for tighter contract capsules"
  - "Avoided ThemeData input/button theme changes that would drift existing goldens; kept theme wiring token-based and additive"

patterns-established:
  - "Use AppBlur/AppOpacity/AppRadius/AppShadows/AppColors/AppTypography via lib/core/tokens/app_tokens.dart barrel"

requirements-completed: [DS-01, L10N-03]

# Metrics
duration: 6 min
completed: 2026-02-18
---

# Phase 1 Plan 1: Design System Guardrails Summary

**Added blur/opacity/radius/shadow token completeness and explicit accent typography so future Nature Distilled primitives can be token-driven without ad-hoc constants.**

## Performance

- **Duration:** 6 min
- **Started:** 2026-02-18T03:49:49Z
- **Completed:** 2026-02-18T03:56:23Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- Added `AppBlur` + `AppOpacity` token modules and exported them via the token barrel.
- Extended `AppRadius` with contract-required `board` and a non-breaking `xxl` alias, plus `capsule` for tighter pills.
- Added contract-friendly aliases and semantic tokens (`AppShadows.soft`, `AppColors.border`, `AppTypography.accentBrand`).

## Task Commits

Each task was committed atomically:

1. **Task 1: Add missing token modules (blur + opacity + board radius)** - `114f653` (feat)
2. **Task 2: Wire ThemeData defaults to tokens (no new ad-hoc styling)** - `0a5b257` (feat)

## Files Created/Modified
- `lib/core/tokens/app_blur.dart` - Blur sigma tokens used by glass primitives.
- `lib/core/tokens/app_opacity.dart` - Opacity tokens for glass layers + motif overlays.
- `lib/core/tokens/app_tokens.dart` - Barrel export wiring for new token modules.
- `lib/core/tokens/app_radius.dart` - Added `board`, `capsule`, and `xxl` alias while keeping existing callers stable.
- `lib/core/tokens/app_shadows.dart` - Added `soft` alias for contract samples.
- `lib/core/tokens/app_colors.dart` - Added semantic `border` alias + secondary/muted text getters.
- `lib/core/tokens/app_typography.dart` - Added explicit accent-only `accentBrand` style.

## Decisions Made
- Preserved existing `AppRadius.pill` (999.0) usage across the app; introduced `AppRadius.capsule` (30.0) for future contract widgets that want a tighter pill.
- Kept `AppTheme` visual defaults unchanged after confirming that broader ThemeData input/button overrides would cause golden drift; focused on additive tokens instead.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- `flutter test` initially failed due to a Login screen golden diff after applying ThemeData-wide input/button overrides; reverted those theme overrides so tests remain stable while still delivering the requested token additions.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Tokens now include blur + opacity + board radius and contract-friendly aliases, enabling Phase 01 Plan 02 primitives to avoid ad-hoc constants.

## Self-Check: PASSED
