---
phase: 02-cloud-ai-privacy-controls
plan: 02
subsystem: ui
tags: [flutter, drift, appsettings, privacy, cloud-ai, l10n]

# Dependency graph
requires:
  - phase: 01-dependency-modernization-baseline
    provides: Flutter/Riverpod/Drift baseline with passing tests
provides:
  - First-use cloud identification disclosure with Learn more details and preview placeholder
  - User-visible Privacy & Data toggles persisted in AppSettings
  - Runtime gating: no cloud Identify path without toggle + online + accepted disclosure; no comps network fetch when disabled
affects: [02-03-PLAN.md, phase-03-sold-price-comps-hardening]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - AppSettings-backed privacy toggles default to enabled when unset
    - Centralized AppSettings key constants in lib/core/settings/app_settings_keys.dart

key-files:
  created:
    - lib/core/settings/app_settings_keys.dart
    - lib/shared/widgets/cloud_identification_disclosure.dart
  modified:
    - lib/features/settings/settings_screen.dart
    - lib/services/market/market_bridge.dart
    - lib/features/onboarding/onboarding_screen.dart
    - lib/features/analyzer/item_detail_screen.dart
    - lib/l10n/app_en.arb
    - lib/l10n/app_sv.arb
    - lib/gen/app_localizations.dart
    - lib/gen/app_localizations_en.dart
    - lib/gen/app_localizations_sv.dart

key-decisions:
  - "Separate reversible toggle (enabled) from disclosure choice (accepted/not now)"
  - "Default privacy toggles to ON when unset to preserve existing behavior until user opts out"

patterns-established:
  - "Privacy settings: store ints in AppSettingsDao with *_v1 keys and expose as StreamProviders for reactive UI"

requirements-completed: [PRIV-01, PRIV-02, AI-04]

# Metrics
duration: 19 min
completed: 2026-02-22
---

# Phase 02 Plan 02: Cloud Disclosure + Privacy Toggles Summary

**First-use cloud identification disclosure + user-visible Privacy & Data toggles with hard gating for Identify and sold-price comps fetches**

## Performance

- **Duration:** 19 min
- **Started:** 2026-02-22T12:23:44Z
- **Completed:** 2026-02-22T12:42:47Z
- **Tasks:** 2
- **Files modified:** 12

## Accomplishments
- Added "Privacy & Data" toggles for cloud identification uploads and sold-price comps, persisted in AppSettings
- Enforced comps network gating in MarketBridge so disabling comps prevents Tradera proxy calls
- Replaced onboarding Gemma consent UI with a cloud identification disclosure and gated Identify behind toggle + online + accepted disclosure

## Task Commits

Each task was committed atomically:

1. **Task 1: Add Privacy & Data toggles and wire sold-price comps gating** - `5722652` (feat)
2. **Task 2: Implement first-use disclosure and Identify gating UI** - `2d1a07b` (feat)

**Plan metadata:** (docs commit created after summary)

## Files Created/Modified
- `lib/core/settings/app_settings_keys.dart` - Stable, versioned AppSettings keys for privacy toggles + disclosure choice
- `lib/features/settings/settings_screen.dart` - New Privacy & Data section with persisted toggles
- `lib/services/market/market_bridge.dart` - Early-return gating to prevent comps network calls when disabled
- `lib/features/onboarding/onboarding_screen.dart` - First-run cloud disclosure prompt (replaces Gemma consent module)
- `lib/features/analyzer/item_detail_screen.dart` - Identify UI gating (disabled state, offline sheet, consent re-prompt)
- `lib/shared/widgets/cloud_identification_disclosure.dart` - Reusable disclosure dialog + Learn more sheet with optional preview
- `lib/l10n/app_en.arb` - New privacy/disclosure strings (English)
- `lib/l10n/app_sv.arb` - New privacy/disclosure strings (Swedish)

## Decisions Made
- Kept disclosure acceptance as a separate persisted choice (0/1/2) from the reversible Settings toggle, so users can say "Not now" and still be re-prompted later.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Privacy controls and UI boundary gating are in place; Plan 02-03 can now wire the actual cloud backend call knowing uploads are gated.

## Self-Check: PASSED

- FOUND: `.planning/phases/02-cloud-ai-privacy-controls/02-02-SUMMARY.md`
- FOUND commits: `5722652`, `2d1a07b`
