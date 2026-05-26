---
phase: 02-cloud-ai-privacy-controls
plan: 05
subsystem: ui
tags: [flutter, scanner, barcode, drag-drop, drift, l10n]

# Dependency graph
requires:
  - phase: 02-cloud-ai-privacy-controls
    provides: Scan capture pipeline + privacy gating from 02-04
provides:
  - Barcode-driven auto capture with debounce/cooldown
  - Batch tray drag-to-delete with local DB + file cleanup
  - Localized delete affordance + snackbar feedback (en/sv)
affects: [scanner, haul, ux]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Debounced, cooldown-gated triggers for camera actions"
    - "Local-only delete path clears sync metadata + best-effort media cleanup"

key-files:
  created: []
  modified:
    - lib/features/scanner/scanner_screen.dart
    - lib/features/scanner/widgets/batch_tray.dart
    - lib/core/database/daos/scan_items_dao.dart
    - lib/core/database/daos/scan_item_photos_dao.dart
    - lib/core/database/daos/scan_item_comps_dao.dart
    - lib/core/database/daos/entity_sync_statuses_dao.dart
    - lib/l10n/app_en.arb
    - lib/l10n/app_sv.arb
    - lib/gen/app_localizations.dart
    - lib/gen/app_localizations_en.dart
    - lib/gen/app_localizations_sv.dart

key-decisions:
  - "Auto-capture uses a stability debounce plus per-barcode cooldown to avoid repeated captures."
  - "Drag-to-delete is local-only (intended for newly captured session items); cloud deletion sync is out of scope."

patterns-established:
  - "Scanner UX: prefer rapid-fire defaults while keeping manual capture available"

requirements-completed: [AI-01]

# Metrics
duration: 14 min
completed: 2026-02-22
---

# Phase 2 Plan 5: Scanner UX Gap Closure Summary

**Scanner supports rapid-fire barcode-driven auto capture and fast correction via drag-to-delete from the batch tray.**

## Performance

- **Duration:** 14 min
- **Started:** 2026-02-22T19:10:04Z
- **Completed:** 2026-02-22T19:24:39Z
- **Tasks:** 3
- **Files modified:** 11

## Accomplishments

- Added barcode stability debounce + cooldown so scanning can auto-save without tapping Capture.
- Added long-press drag-to-delete in the batch tray with immediate local removal.
- Local delete clears pending sync/status rows and best-effort deletes image/thumb files.

## Task Commits

Each task was committed atomically:

1. **Task 1: Auto-capture on barcode detection** - `334d618` (feat)
2. **Task 2: Drag-to-delete in batch tray + local removal** - `884a509` (feat)
3. **Task 3: Localize new scanner strings** - `86a3158` (feat)

## Files Created/Modified

- `lib/features/scanner/scanner_screen.dart` - Barcode auto-capture trigger + local delete pipeline.
- `lib/features/scanner/widgets/batch_tray.dart` - Long-press drag-to-delete UI + trash drop target.
- `lib/core/database/daos/scan_items_dao.dart` - Adds `deleteById` helper.
- `lib/core/database/daos/scan_item_photos_dao.dart` - Adds `listByScanItemId` helper for media cleanup.
- `lib/core/database/daos/scan_item_comps_dao.dart` - Adds `clear` helper.
- `lib/core/database/daos/entity_sync_statuses_dao.dart` - Adds `deleteByKeys` helper.
- `lib/l10n/app_en.arb` - Scanner delete affordance strings.
- `lib/l10n/app_sv.arb` - Scanner delete affordance strings.
- `lib/gen/app_localizations.dart` - Regenerated localization outputs.
- `lib/gen/app_localizations_en.dart` - Regenerated localization outputs.
- `lib/gen/app_localizations_sv.dart` - Regenerated localization outputs.

## Decisions Made

- Auto-capture is gated by debounce + per-barcode cooldown to minimize accidental repeat captures.
- Local deletion clears sync metadata so the app does not keep retrying sync for deleted items.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- `flutter test` initially failed after adding new ARB keys until `flutter gen-l10n` regenerated `lib/gen/app_localizations*.dart`.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for on-device verification: scan a barcode to confirm auto-save; drag a newly captured scan to trash to confirm immediate removal.

## Self-Check: PASSED

- FOUND: `.planning/phases/02-cloud-ai-privacy-controls/02-05-SUMMARY.md`
- FOUND commits: `334d618`, `884a509`, `86a3158`
