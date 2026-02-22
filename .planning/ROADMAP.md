# Roadmap: FyndLoppis

## Overview

This delivery cycle removes the first-run AI download blocker by making cloud-first identification the default (with explicit privacy controls), keeps a lightweight opt-in offline fallback, hardens sold-price comps behavior, modernizes core dependencies to current stable, and finishes UI System v2 token adoption with dark mode parity.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

- [x] **Phase 1: Dependency Modernization Baseline** - Update core packages and Flutter toolchain with tests passing. (completed 2026-02-22)
- [ ] **Phase 2: Cloud AI + Privacy Controls** - Default Gemini identification via server proxy with no first-run blocker.
- [ ] **Phase 3: Sold-Price Comps Hardening** - Reliable on-demand/background comps with disable controls and proxy protection.
- [ ] **Phase 4: Opt-In Offline Fallback** - Lightweight offline identification with evidence and safe licensing.
- [ ] **Phase 5: UI Tokens + Dark Mode Parity** - Token-driven theming across primitives plus golden coverage.

## Phase Details

### Phase 1: Dependency Modernization Baseline
**Goal**: The app runs on latest Flutter stable with updated Riverpod/Drift/camera/workmanager and no regressions.
**Depends on**: Nothing (first phase)
**Requirements**: DEP-01, DEP-02, DEP-03, DEP-04, DEP-05
**Success Criteria** (what must be TRUE):
  1. App builds, installs, and launches on iOS and Android using latest Flutter stable.
  2. Core capture + catalog flows work (camera scan, item create/edit, local persistence) without runtime errors.
  3. Existing local database migrations/queries continue to work with real user data.
  4. Full test suite passes (including CI) after dependency updates.
**Plans**: 2 plans

Plans:
- [x] 01-01-PLAN.md — Update core deps + platform baselines and fix breakages
- [x] 01-02-PLAN.md — Validate builds (Android flavors + iOS), goldens, and smoke tests

### Phase 2: Cloud AI + Privacy Controls
**Goal**: Users can identify items via cloud AI by default (when online and allowed) with clear, reversible privacy controls and no first-run model download.
**Depends on**: Phase 1
**Requirements**: AI-01, AI-02, AI-03, AI-04, PRIV-01, PRIV-02, PRIV-03
**Success Criteria** (what must be TRUE):
  1. On a fresh install, the user can complete core flows (scan/capture, save items, browse/edit) without downloading any on-device AI model.
  2. Before any cloud identification upload occurs, the user sees a first-use disclosure explaining what data is uploaded, and they can change this choice later.
  3. When online and cloud identification is enabled, the user can run identification and receive results; the mobile app ships no cloud AI API keys.
  4. When cloud identification is disabled, the app performs no cloud identification image uploads and the UI reflects that identification is disabled.
  5. The disclosure/settings make it explicit that only minimal image data is uploaded (e.g., crops) and metadata is stripped.
**Plans**: 3 plans

Plans:
- [ ] 02-01-PLAN.md — Add server-proxied Gemini identification endpoint
- [ ] 02-02-PLAN.md — Add first-use disclosure + Privacy & Data toggles + gating
- [ ] 02-03-PLAN.md — Wire cloudGemini default backend + remove Gemma first-run prompts

### Phase 3: Sold-Price Comps Hardening
**Goal**: Sold-price comps work reliably on demand and in background when enabled, with a true off switch and robust proxy protection.
**Depends on**: Phase 2
**Requirements**: MKT-01, MKT-02, MKT-03
**Success Criteria** (what must be TRUE):
  1. The user can fetch sold-price comps on demand for an item and see that results are associated with a last-updated time.
  2. When background comps are enabled, comps refresh attempts happen automatically (best-effort) and update items when successful.
  3. When the user disables sold-price comps, the app performs no comps network calls and the UI clearly indicates comps are disabled.
  4. When the proxy rate-limits/blocks/errors, the user sees a clear, actionable error state and core app flows still work.
**Plans**: TBD

Plans:
- [ ] 03-01: Wire comps enable/disable and background refresh behavior
- [ ] 03-02: Add proxy abuse protection and user-facing error handling

### Phase 4: Opt-In Offline Fallback
**Goal**: Users can optionally enable a lightweight offline identification mode that works without network connectivity and shows evidence.
**Depends on**: Phase 3
**Requirements**: AI-05, OFF-01, OFF-02, OFF-03, OFF-04
**Success Criteria** (what must be TRUE):
  1. The user can opt into offline identification mode in settings (and turn it back off) without any mandatory downloads.
  2. With no connectivity, the user can run offline fallback identification and receive results.
  3. Any offline model download is clearly presented as optional, shows its size up front, and stays under 10MB (excluding the app bundle).
  4. Offline results present evidence suitable for UI display (e.g., bounding boxes and confidence).
  5. The user can view offline model attribution/license information in-app.
**Plans**: TBD

Plans:
- [ ] 04-01: Implement opt-in offline backend and evidence UI
- [ ] 04-02: Validate size budget + licensing + packaging

### Phase 5: UI Tokens + Dark Mode Parity
**Goal**: UI System v2 tokens drive light/dark theming across shared primitives with regression protection.
**Depends on**: Phase 4
**Requirements**: UI-01, UI-02, UI-03, UI-04, UI-05
**Success Criteria** (what must be TRUE):
  1. The user can choose system/default or manual light/dark mode, and the preference persists.
  2. Shared primitives render with token-driven colors/assets in both light and dark modes (no new hardcoded UI colors in migrated components).
  3. Hero contexts in dark mode use the dedicated dark hero background token (not hardcoded images).
  4. Golden tests cover key primitives/screens for light/dark parity and pass in CI.
**Plans**: TBD

Plans:
- [ ] 05-01: Finish token adoption in primitives and wire dark mode toggle
- [ ] 05-02: Add/maintain goldens + CI enforcement to prevent regressions

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Dependency Modernization Baseline | 2/2 | Complete    | 2026-02-22 |
| 2. Cloud AI + Privacy Controls | 3/3 | In Progress | - |
| 3. Sold-Price Comps Hardening | 0/TBD | Not started | - |
| 4. Opt-In Offline Fallback | 0/TBD | Not started | - |
| 5. UI Tokens + Dark Mode Parity | 0/TBD | Not started | - |
