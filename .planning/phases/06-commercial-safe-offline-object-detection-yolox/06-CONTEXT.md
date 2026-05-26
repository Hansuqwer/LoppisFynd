# Phase 6: Commercial-safe offline object detection (YOLOX) - Context

**Gathered:** 2026-02-24
**Status:** Ready for planning

<domain>
## Phase Boundary

Add a commercially safe offline object detection capability that can run on-device and provide evidence suitable for UI display. This phase clarifies the user-facing behavior (entry points, results presentation, download UX, and attribution surfaces). Model training pipelines and new multi-item draft creation are out of scope.

</domain>

<decisions>
## Implementation Decisions

### Evidence + results UI
- Use split view: image with boxes and a results list shown together.
- Primary selection works both ways: tapping a bounding box or selecting a list row; both stay in sync.
- Show confidence as percent plus a High/Med/Low label.
- Use a hard confidence threshold; do not show detections below it.

### Model availability UX
- If the offline model is not installed when the user triggers detection, show a non-blocking inline card in the detection panel/screen with a Download button.
- Proactively suggest downloading once (non-blocking) after the user enables offline mode in settings.
- Download is in-app with a progress bar and pause/cancel controls.
- If download fails, show an error but allow the user to continue (offline detection remains unavailable until fixed).

### Attribution + licensing UX
- Provide attribution/licenses in both places: an offline-specific entry in Settings and a global About/Legal third-party licenses screen.
- Default license view shows a short summary with a "View full license text" action.
- Attribution should cover model/weights, ML runtime/inference libs, and dataset/training attribution (where applicable).
- License policy: allow "commercial-safe" licenses (e.g., Apache/MIT/BSD style), but avoid AGPL.

### Claude's Discretion
- Exact entry-point wiring details (which screens/routes) as long as offline detection is reachable from both a post-capture path and item detail/edit.
- Exact wording/visual design of the inline download card and license summaries (must fit existing app tone).
- Exact threshold value(s) and how High/Med/Low maps to confidence, as long as there is a clear hard cutoff.

</decisions>

<specifics>
## Specific Ideas

- Suggested (not locked): YOLOX-Nano as the target model for budget-device performance and evidence-style detections.
- Suggested (not locked): best-effort auto-run after capture plus a manual "Detect objects" action on item detail/edit.
- Suggested (not locked): prefill suggested category/title in draft UI but do not auto-save or auto-apply.
- Suggested (not locked): run inference off the UI thread (e.g., isolate) with robust error handling and crash logging.

</specifics>

<deferred>
## Deferred Ideas

- Multi-select bounding boxes to generate multiple draft listings from one photo.
- Custom model training / fine-tuning pipeline and dataset workflow.

</deferred>

---

*Phase: 06-commercial-safe-offline-object-detection-yolox*
*Context gathered: 2026-02-24*
