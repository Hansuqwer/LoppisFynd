---
phase: 04-core-screens-goldens
plan: 01
subsystem: ui
tags: [flutter, l10n, offline-first, nature-distilled]

# Dependency graph
requires: []
provides:
  - Home (Dashboard), Current Haul, History empty-state, and Draft editor reskinned to Visual Reference Pack parity
  - Deterministic History empty state for new users (excludes Current Haul)
affects: [goldens, core-screens, localization]

# Tech tracking
tech-stack:
  added: [intl]
  patterns:
    - Compose core screens with Nature Distilled primitives (GlassBoard/GlassSurface/BentoCard) and tokens
    - Keep offline-first actions intact (Drift-backed reads/writes; no online gating)
    - All user-facing copy via AppLocalizations (sv/en)

key-files:
  created: []
  modified:
    - lib/features/dashboard/dashboard_screen.dart
    - lib/features/hauls/haul_screen.dart
    - lib/features/history/history_screen.dart
    - lib/features/history/widgets/coffee_cup_empty_state.dart
    - lib/features/drafts/draft_editor_screen.dart
    - lib/l10n/app_sv.arb
    - lib/l10n/app_en.arb
    - lib/gen/app_localizations.dart
    - lib/gen/app_localizations_sv.dart
    - lib/gen/app_localizations_en.dart
    - lib/services/ai/inference/flutter_gemma_backend.dart
    - android/app/src/main/AndroidManifest.xml
    - pubspec.yaml
    - pubspec.lock

key-decisions: []

patterns-established:
  - "Reference-parity reskins should be implemented in-place on existing screens (avoid route/tab contract changes)"
  - "Prevent small-screen/text-scale overflows by adapting aspect ratio/padding/typography for tiles"

requirements-completed: [SCR-01, SCR-02, SCR-03, SCR-04]

# Metrics
duration: 6h 1m
completed: 2026-02-19
---

# Phase 04 Plan 01: Core Screens + Goldens Summary

**Reskinned Home, Current Haul, History empty state, and Draft editor to Visual Reference Pack parity with localized sv/en copy and offline-safe actions.**

## Performance

- **Duration:** 6h 1m
- **Started:** 2026-02-19T09:26:29Z
- **Completed:** 2026-02-19T15:28:07Z
- **Tasks:** 3
- **Files modified:** 14

## Accomplishments

- Home (Dashboard) hero CTA + bento tiles layout wired to Scan tab via `deepLinkTabIndexProvider`
- Current Haul summary/list rows reskinned, with localized "Totalt värde:" label and SEK formatting
- History empty state matches reference (search + pebble filters + coffee-cup), and is deterministic for new users
- Draft editor rebuilt into stacked-glass layout with localized fields (including "Pris (SEK)") and offline-safe save/delete

## Task Commits

1. **Task 1: Bring Home + Current Haul to reference parity (layout + copy + CTA wiring)**
   - `4e324a9` (feat)
   - `78750d2` (fix: narrow width/text-scale tile overflow)
2. **Task 2: Bring History empty state + Draft editor to reference parity (and keep offline actions intact)**
   - `8e4a78d` (feat)
3. **Task 3: Human verify core screen parity + offline sanity**
   - Approved (no code changes)

Additional follow-up fix included in this plan's execution record:
- `383ba0e` (fix: final tile overflow tweaks + prefer GPU backend with fallback)

## Files Created/Modified

- `lib/features/dashboard/dashboard_screen.dart` - Home reference layout + overflow-safe bento tiles
- `lib/features/hauls/haul_screen.dart` - Current Haul reference layout + SEK formatting + localized copy
- `lib/features/history/history_screen.dart` - Deterministic empty-state behavior (exclude Current Haul)
- `lib/features/history/widgets/coffee_cup_empty_state.dart` - Reference-style coffee-cup empty state
- `lib/features/drafts/draft_editor_screen.dart` - Stacked-glass draft studio layout and offline-safe actions
- `lib/l10n/app_sv.arb` - Swedish copy additions/updates
- `lib/l10n/app_en.arb` - English copy additions/updates
- `lib/gen/app_localizations.dart` - Regenerated localizations
- `lib/gen/app_localizations_sv.dart` - Regenerated localizations
- `lib/gen/app_localizations_en.dart` - Regenerated localizations
- `pubspec.yaml` - Add `intl` for currency/number formatting
- `pubspec.lock` - Lockfile update for new dependency
- `lib/services/ai/inference/flutter_gemma_backend.dart` - Prefer GPU backend for vision, with fallback by error text
- `android/app/src/main/AndroidManifest.xml` - Declare optional OpenCL native libs for GPU backend

## Decisions Made

None - followed plan as specified.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed dashboard bento tile overflows at narrow widths / larger text scale**
- **Found during:** Task 1 (Home + Current Haul reskin)
- **Issue:** Home bento tiles could overflow (RenderFlex) in compact layouts and with increased text scale.
- **Fix:** Adjusted tile aspect ratio/padding/typography to keep content within bounds.
- **Files modified:** `lib/features/dashboard/dashboard_screen.dart`
- **Verification:** Human verify checkpoint approval + overflow-specific fixes committed.
- **Committed in:** `78750d2`

**2. [Rule 1 - Bug] Preferred GPU backend for vision inference with safe fallback**
- **Found during:** Post-Task 1 follow-up validation
- **Issue:** LiteRT-LM backend constraints could mismatch (CPU vs GPU) for vision models and contribute to instability.
- **Fix:** Prefer GPU backend, fall back to CPU/GPU based on constraint mismatch error text; declare optional OpenCL libs.
- **Files modified:** `lib/services/ai/inference/flutter_gemma_backend.dart`, `android/app/src/main/AndroidManifest.xml`
- **Verification:** Compiles and remains backward-compatible (fallback preserves prior behavior).
- **Committed in:** `383ba0e`

---

**Total deviations:** 2 auto-fixed (2 bug fixes)
**Impact on plan:** Both fixes were directly related to correctness/stability of the reskinned Home experience; no scope creep beyond ensuring the planned screens work reliably.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 04-01 is complete and human-approved; ready to execute `04-02-PLAN.md`.

---
*Phase: 04-core-screens-goldens*
*Completed: 2026-02-19*

## Self-Check: PASSED

- Summary file exists on disk
- Referenced commits exist in git history (`4e324a9`, `8e4a78d`, `78750d2`, `383ba0e`)
