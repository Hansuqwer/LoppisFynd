# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-21)

**Core value:** The app launches immediately (no multi-GB downloads) and helps a user quickly identify and price a secondhand item from a photo, even with unreliable connectivity.
**Current focus:** Phase 2 - Cloud AI + Privacy Controls

## Current Position

**Phase:** 2 of 5 (Cloud AI + Privacy Controls)
**Current Plan:** 5
**Total Plans in Phase:** 5
**Status:** Phase complete — ready for verification
**Last Activity:** 2026-02-22
**Progress:** [██████████] 100%

## Performance Metrics

**Velocity:**
- **Total plans completed:** 7
- **Average duration:** 28 min
- **Total execution time:** 3.2 hours

| Phase | Duration | Tasks | Files |
|-------|----------|-------|-------|
| Phase 01-dependency-modernization-baseline P01 | 17 min | 3 tasks | 10 files |
| Phase 01-dependency-modernization-baseline P02 | 1h 47m | 3 tasks | 8 files |
| Phase 02 P01 | 6 min | 2 tasks | 7 files |
| Phase 02 P02 | 19 min | 2 tasks | 12 files |
| Phase 02 P03 | 24 min | 2 tasks | 31 files |
| Phase 02-cloud-ai-privacy-controls P04 | 7 min | 3 tasks | 3 files |
| Phase 02-cloud-ai-privacy-controls P05 | 14 min | 3 tasks | 11 files |

## Accumulated Context

### Decisions

- Closed Phase 01 Plan 02 verification checkpoint as approved, with iOS minimal smoke test explicitly deferred due to lack of macOS access.
- Proceed to Phase 2 even though Phase 1 verification remains incomplete on iOS; treat iOS validation as deferred risk.
- [Phase 02]: Default GEMINI_MODEL to gemini-2.5-flash when unset
- [Phase 02]: Enforce strict payload limits (413) and cache-control: no-store on cloud AI proxy responses
- [Phase 02]: Separate reversible toggle (enabled) from disclosure choice (accepted/not now)
- [Phase 02]: Default privacy toggles to ON when unset to preserve existing behavior until user opts out
- [Phase 02]: Cloud Identify defaults to cloudGemini when CLOUD_AI_PROXY_URL is configured; remove Gemma from first-run UX
- [Phase 02]: Enforce PRIV-03 with crops-only JPEG re-encode and strict upload byte budget
- [Phase 02-cloud-ai-privacy-controls]: [Phase 02]: Scanner auto-capture uses debounce + per-barcode cooldown
- [Phase 02-cloud-ai-privacy-controls]: [Phase 02]: Batch tray drag-to-delete is local-only (clears sync metadata + best-effort file cleanup)

### Pending Todos

- Run iOS build + launch validation when macOS access is available (or via CI `ios-build`).

### Blockers/Concerns

- **Risk:** iOS runtime smoke test is unvalidated; validate on macOS before release.
- **Note:** Re-run Phase 2 verification (truths #2 and #4) to confirm scan-capture background inference no longer triggers cloud calls without consent.

## Session Continuity

**Last session:** 2026-02-22T19:25:58.653Z
**Stopped At:** Completed 02-cloud-ai-privacy-controls-05-PLAN.md
**Resume File:** None
