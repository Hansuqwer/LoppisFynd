# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-21)

**Core value:** The app launches immediately (no multi-GB downloads) and helps a user quickly identify and price a secondhand item from a photo, even with unreliable connectivity.
**Current focus:** Phase 4 - Opt-In Offline Fallback

## Current Position

**Phase:** 4 of 5 (Opt-In Offline Fallback)
**Current Plan:** 4
**Total Plans in Phase:** 4
**Status:** Ready to execute
**Last Activity:** 2026-02-24
**Progress:** [█████████░] 93%

## Performance Metrics

**Velocity:**
- **Total plans completed:** 8
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
| Phase 03 P01 | 10 min | 2 tasks | 5 files |
| Phase 03-sold-price-comps-hardening P02 | 26 min | 2 tasks | 8 files |
| Phase 03-sold-price-comps-hardening P03 | 2 min | 2 tasks | 1 files |
| Phase 04-opt-in-offline-fallback P01 | 30 min | 3 tasks | 12 files |
| Phase 04-opt-in-offline-fallback P02 | 11 min | 3 tasks | 6 files |
| Phase 04-opt-in-offline-fallback P03 | 6 min | 2 tasks | 9 files |

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
- [Phase 03]: Treat HTTP 429 as actionable (no tight client retry loop); surface retry-after to UX
- [Phase 03]: Rate limit key prefers JWT sub when present, else hashed bearer token, else IP
- [Phase 03]: Fail closed with server_not_configured when Upstash env vars are missing
- [Phase 04-opt-in-offline-fallback]: Select TensorFlow-hosted EfficientDet Lite0 detection metadata model (<10MiB) and pin expectedBytes + sha256
- [Phase 04-opt-in-offline-fallback]: Embed full Apache-2.0 and CC BY 4.0 legal texts in offline model catalog for OFF-04 attribution surfaces
- [Phase 04-opt-in-offline-fallback]: Use hard minimum score 0.35 with centralized High/Med/Low banding for offline detections
- [Phase 04-opt-in-offline-fallback]: Run offline detection decode/preprocess/inference in background isolate (Isolate.run) to avoid UI jank
- [Phase 04-opt-in-offline-fallback]: Use SnackBar action for the one-time download suggestion (non-modal)
- [Phase 04-opt-in-offline-fallback]: Expose offline license summaries in a dedicated screen plus full-text viewer

### Roadmap Evolution

- Phase 6 added: Commercial-safe offline object detection (YOLOX)
- Phase 6 merged into Phase 4 (Opt-In Offline Fallback) and removed from the roadmap

### Pending Todos

- Run iOS build + launch validation when macOS access is available (or via CI `ios-build`).
- Phase 3: On-device verify comps toggle OFF->ON immediately cancels/(re)schedules background work (03-03 checkpoint).

### Blockers/Concerns

- **Risk:** iOS runtime smoke test is unvalidated; validate on macOS before release.
- **Note:** Phase 2 cloud Identify was verified end-to-end on Android with deployed Supabase proxy; run iOS smoke test when macOS access is available.
- **Risk:** Phase 3 background Workmanager scheduling behavior is wired but needs device verification before marking Phase 3 fully verified.

## Session Continuity

**Last session:** 2026-02-24T08:25:33.655Z
**Stopped At:** Completed 04-opt-in-offline-fallback-03-PLAN.md
**Resume File:** None
