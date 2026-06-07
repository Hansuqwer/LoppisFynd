# Roadmap: FyndLoppis

## Overview

This delivery cycle removes the first-run AI download blocker by making cloud-first identification the default (with explicit privacy controls), keeps a lightweight opt-in offline fallback, hardens sold-price comps behavior, modernizes core dependencies to current stable, and finishes UI System v2 token adoption with dark mode parity.

**Release target added 2026-06-07:** Android first Play Store release (Phase 6) focusing on Swedish children's book coverage with enriched market data (ISBN, cover, sold prices).

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

- [x] **Phase 1: Dependency Modernization Baseline** - Update core packages and Flutter toolchain with tests passing. (completed 2026-02-22)
- [x] **Phase 2: Cloud AI + Privacy Controls** - Default Gemini identification via server proxy with no first-run blocker. (completed 2026-02-22)
- [x] **Phase 3: Sold-Price Comps Hardening** - Reliable on-demand/background comps with disable controls and proxy protection. (completed 2026-02-23)
- [ ] **Phase 4: Opt-In Offline Fallback** - Lightweight offline identification with evidence and safe licensing.
- [ ] **Phase 5: UI Tokens + Dark Mode Parity** - Token-driven theming across primitives plus golden coverage.
- [ ] **Phase 6: Android Release** - First Play Store release with Swedish children's book coverage, CI fixes, release signing, and enriched market data.

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
**Plans**: 5 plans

Plans:
- [x] 02-01-PLAN.md — Add server-proxied Gemini identification endpoint
- [x] 02-02-PLAN.md — Add first-use disclosure + Privacy & Data toggles + gating
- [x] 02-03-PLAN.md — Wire cloudGemini default backend + remove Gemma first-run prompts
- [x] 02-04-PLAN.md — Gap closure: Enforce scan-capture cloud upload gating (consent + toggle + online)
- [x] 02-05-PLAN.md — Gap closure: Restore scanner auto-capture + batch tray drag-to-delete

### Phase 3: Sold-Price Comps Hardening
**Goal**: Sold-price comps work reliably on demand and in background when enabled, with a true off switch and robust proxy protection.
**Depends on**: Phase 2
**Requirements**: MKT-01, MKT-02, MKT-03
**Success Criteria** (what must be TRUE):
  1. The user can fetch sold-price comps on demand for an item and see that results are associated with a last-updated time.
  2. When background comps are enabled, comps refresh attempts happen automatically (best-effort) and update items when successful.
  3. When the user disables sold-price comps, the app performs no comps network calls and the UI clearly indicates comps are disabled.
  4. When the proxy rate-limits/blocks/errors, the user sees a clear, actionable error state and core app flows still work.
**Plans**: 3 plans

Plans:
- [x] 03-01-PLAN.md — Wire comps enable/disable, background gating, and last-updated UI
- [x] 03-02-PLAN.md — Add proxy abuse protection + stable error contract + actionable client errors
- [x] 03-03-PLAN.md — Gap closure: Reschedule background work when comps toggle changes

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
**Plans**: 4 plans

Plans:
- [ ] 04-01-PLAN.md — Offline model catalog + download pipeline (pause/resume/cancel) with <10MB guardrails
- [ ] 04-02-PLAN.md — Offline detector runtime (evidence schema + confidence threshold + parsing + providers)
- [ ] 04-03-PLAN.md — Settings opt-in + one-time download suggestion + in-app offline licenses (OFF-04)
- [ ] 04-04-PLAN.md — Offline detection UX (split-view evidence + download card), entry points, and device checkpoint

### Phase 5: UI Tokens + Dark Mode Parity
**Goal**: UI System v2 tokens drive light/dark theming across shared primitives with regression protection.
**Depends on**: Phase 4
**Requirements**: UI-01, UI-02, UI-03, UI-04, UI-05
**Success Criteria** (what must be TRUE):
  1. The user can choose system/default or manual light/dark mode, and the preference persists.
  2. Shared primitives render with token-driven colors/assets in both light and dark modes (no new hardcoded UI colors in migrated components).
  3. Hero contexts in dark mode use the dedicated dark hero background token (not hardcoded images).
  4. Golden tests cover key primitives/screens for light/dark parity and pass in CI.
  5. Cards use a single clean layer (no stacked/overlapping card effect) to reduce visual clutter.
  6. Typography is legible on atmospheric backgrounds: default weights are regular/medium (not thin) and small labels have improved contrast.
**Plans**: TBD

Plans:
- [ ] 05-01: Finish token adoption in primitives; simplify card layering; improve typography weights/label contrast; wire dark mode toggle
- [ ] 05-02: Add/maintain goldens + CI enforcement to prevent regressions

### Phase 6: Android Release — First Play Store Release
**Goal**: Ship a production-quality Android release to the Play Store with solid Swedish children's book coverage, no CI blockers, release signing, enriched market data (ISBN, cover, sold prices), and adaptive launcher icon.
**Depends on**: Phase 3 (market data complete). Phase 4 + 5 can run in parallel or follow.
**Release target**: Android first; iOS follows
**Requirements**: REL-01 through REL-13
**Success Criteria** (what must be TRUE):
  1. CI passes end-to-end including all Deno Edge Function tests (no broken test step references).
  2. Production AAB is built with all `--dart-define` secrets injected and signed with release keystore.
  3. App has adaptive launcher icon and passes Play Store pre-launch checks.
  4. First-launch experience shows real book price data for at least 200 Swedish children's titles.
  5. ISBN and cover images are displayed for scraped book comps (Open Library enrichment).
  6. No crash from unimplemented providers (`offlineDetectorProvider`, `cloudAiProxy`).
  7. Privacy policy is accessible via a public URL from the Play Store listing.
  8. `fvm dart analyze` passes with only known 9 `TableMigration` experimental warnings.

**Package versions verified 2026-06-07 (update deps if needed before release):**
| Package | Current | Latest stable |
|---|---|---|
| `flutter_riverpod` | 3.2.1 | **3.3.1** |
| `drift` | 2.31.0 | **2.33.0** |
| `supabase_flutter` | ^2.12.0 | **2.14.1** |
| `sentry_flutter` | ^9.13.0 | **9.21.0** |
| `mobile_scanner` | ^7.2.0 | 7.2.0 (current) |

**Plans** (maps 1:1 to steps 0–13 in `PRODUCTION_READINESS_PROMPT.md`):
- [x] 06-01-PLAN.md — CI fixes + hardcoded string cleanup (steps 0.1, 0.2)
- [ ] 06-02-PLAN.md — Android release signing docs + ProGuard rules + adaptive icon (steps 1, 2)
- [ ] 06-03-PLAN.md — Play Store metadata + privacy policy URL + dart-define CI injection (steps 3, 4, 5)
- [ ] 06-04-PLAN.md — Dashboard real sold count + real weekly chart + Tradera noop rate-limit fallback (steps 6, 7)
- [ ] 06-05-PLAN.md — Swedish children's book seed (200+ titles) + Open Library ISBN fallback in `IsbnLookupService` (steps 8, 9)
- [ ] 06-06-PLAN.md — Crash guards: `offlineDetectorProvider` null stub + auth gate error logging + `PlatformDispatcher` Sentry hook (steps 10, 11, 12, 13)

## Progress

**Execution Order:**
Phases 1 → 2 → 3 complete. Phase 4 in progress (3/4 plans). Phase 6 (Android Release) is the immediate priority and can proceed without completing Phase 4 or 5. Phase 5 runs in parallel or after release.

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Dependency Modernization Baseline | 2/2 | Complete    | 2026-02-22 |
| 2. Cloud AI + Privacy Controls | 5/5 | Complete    | 2026-02-22 |
| 3. Sold-Price Comps Hardening | 3/3 | Complete    | 2026-02-23 |
| 4. Opt-In Offline Fallback | 3/4 | In Progress | - |
| 5. UI Tokens + Dark Mode Parity | 0/TBD | Not started | - |
| 6. Android Release | 0/6 | Not started | - |
