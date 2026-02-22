# Phase 2: Cloud AI + Privacy Controls - Context

**Gathered:** 2026-02-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver cloud AI item identification as the default online identification path, gated behind a first-use disclosure and backed by clear, reversible privacy controls. This phase must avoid any first-run on-device model download and must make the user-facing behavior explicit when cloud identification is disabled or unavailable.

Out of scope for this phase: opt-in offline identification fallback (planned Phase 4), and sold-price comps reliability/proxy hardening beyond adding the user-facing enable/disable control.

</domain>

<decisions>
## Implementation Decisions

### First-use disclosure flow
- Disclosure appears on first app launch.
- Presentation is a blocking full-screen/modal that requires an explicit choice.
- Choices are exactly: "Enable cloud identification" and "Not now".
- Detail level on the disclosure is short (2-4 bullets) with a "Learn more" link.
- If the user chose "Not now", the next attempt to use Identify re-prompts just-in-time with the same disclosure and requires "Enable" to proceed.

### Privacy controls in Settings
- Settings includes a new top-level section named "Privacy & Data".
- Controls are visible to all users by default.
- Cloud control is a single toggle labeled "Cloud identification".
- The cloud toggle has subtext that explicitly mentions the upload is minimal/crops-only.
- "Fetch sold-price comps" is a toggle in the same "Privacy & Data" section.

### What gets uploaded (user-facing transparency)
- Provider naming in UI is generic: "cloud AI" (do not name the provider).
- The "Learn more" path includes an optional preview of the image data that would be uploaded (the crop(s)).
- Minimal image data rule is strict: crops only; never upload the full photo.
- Retention statement: uploaded image data is not stored on our server (processed transiently).

### Disabled/offline behavior
- If "Cloud identification" is OFF in Settings, Identify appears disabled with a short hint to enable it in Settings.
- If the user is offline while cloud identification is ON, tapping Identify fails fast with an "You're offline" message and a Retry action (no queuing).
- Blocked states include an "Open Settings" shortcut (both disabled and offline cases).

### Claude's Discretion
None specified.

</decisions>

<specifics>
## Specific Ideas

- Keep first-use disclosure copy concise; "Learn more" is the place for the deeper explanation and crop preview.
- Use generic language ("cloud AI") in user-facing text even though implementation uses Gemini behind a proxy.

</specifics>

<deferred>
## Deferred Ideas

None - discussion stayed within Phase 2 scope.

</deferred>

---

*Phase: 02-cloud-ai-privacy-controls*
*Context gathered: 2026-02-22*
