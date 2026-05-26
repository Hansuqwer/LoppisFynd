# Requirements: FyndLoppis

**Defined:** 2026-02-21
**Core Value:** The app launches immediately (no multi-GB downloads) and helps a user quickly identify and price a secondhand item from a photo, even with unreliable connectivity.

## v1 Requirements

Requirements for the next major delivery cycle (2026): remove first-run blockers, shift to cloud-first AI with clear user controls, keep an offline fallback path, modernize dependencies, and adopt token-driven theming (including dark mode).

### AI Modes + First-Run

- [ ] **AI-01**: App launches and core flows are usable on first run without downloading any on-device AI model
- [ ] **AI-02**: Cloud AI identification (Gemini) is the default identification path when online and allowed by user settings
- [ ] **AI-03**: Cloud AI requests are proxied server-side (no cloud AI API keys shipped in the mobile app)
- [ ] **AI-04**: User can disable cloud identification; when disabled, the app does not upload item images for AI identification
- [ ] **AI-05**: An offline identification mode exists as an opt-in path (no mandatory downloads); behavior is explicit in settings

### Offline Fallback (Lightweight)

- [ ] **OFF-01**: Offline fallback identification works without network connectivity
- [ ] **OFF-02**: Offline model size is under 10MB (excluding app bundle)
- [ ] **OFF-03**: Offline results include evidence fields (e.g., bounding boxes + confidence) suitable for UI display
- [ ] **OFF-04**: Offline ML stack and weights are commercially safe to distribute (no AGPL licensing chain)

### Pricing Comps (Tradera)

- [ ] **MKT-01**: Sold-price comps can be fetched on demand and in background when enabled
- [ ] **MKT-02**: User can disable sold-price comps; when disabled, the app performs no comps network calls
- [ ] **MKT-03**: Tradera proxy is protected against abuse (auth and/or rate limiting) and has clear error handling

### Controls + Privacy

- [ ] **PRIV-01**: First-use disclosure explains cloud identification and what image data is uploaded, with a reversible control
- [ ] **PRIV-02**: Settings include "Send crops for cloud identification" (default ON) and "Fetch sold-price comps" (default ON)
- [ ] **PRIV-03**: When cloud identification is enabled, only the minimum required image data is sent (e.g., crops), and metadata is stripped

### Dependency Modernization

- [x] **DEP-01**: Update Riverpod to the targeted current stable range and keep the app functional
- [x] **DEP-02**: Update Drift to the targeted current stable range and keep migrations/queries working
- [x] **DEP-03**: Update camera and workmanager packages without regressions
- [x] **DEP-04**: Build passes on latest Flutter stable; no deprecated APIs in use
- [x] **DEP-05**: Full test suite passes after dependency updates

### UI Tokens + Dark Mode (UI System v2 Adoption)

- [ ] **UI-01**: Light and dark themes are wired to semantic + ramp tokens (no hardcoded UI colors/assets in migrated UI)
- [ ] **UI-02**: System/manual dark mode toggle exists and persists user preference
- [ ] **UI-03**: Shared primitives fully respect tokens (e.g., GlassSurface/Overlay/Board, NatureBackground, LogoMotifOverlay, BentoCard)
- [ ] **UI-04**: Dedicated dark hero background token is used (no hardcoded dark images in hero contexts)
- [ ] **UI-05**: Golden tests cover key primitives/screens for light/dark parity and pass in CI

## v2 Requirements

Deferred (later 2026-2027): responsive layouts at scale, token governance tooling, and future-proofing exploration.

### Responsive Layout

- **RESP-01**: Define breakpoints and update key layout containers to adapt to tablets/foldables without overflow
- **RESP-02**: Add tablet/foldable layouts for top flows and validate on real devices/emulators

### Token Governance

- **GOV-01**: Export tokens to W3C Design Tokens JSON and version them
- **GOV-02**: Add generator (JSON -> Dart) and CI drift checks
- **GOV-03**: Enforce no new hardcoded colors/assets in UI layer (lint/CI)
- **GOV-04**: Responsive typography audit across breakpoints

### Future-Proofing (Low Priority)

- **FUT-01**: Evaluate Material 3 Expressive adoption
- **FUT-02**: Add variable font support (where beneficial)
- **FUT-03**: Micro-interaction audit and performance optimization pass

## Out of Scope

| Feature | Reason |
|---------|--------|
| Native Android/iOS rewrite | Stay on Flutter; focus on incremental evolution |
| Major architecture rewrite | Keep Riverpod + Drift; avoid destabilizing the offline-first core |
| New platforms (web/desktop) | Maintain iOS/Android support first |
| Revenue model changes (subscriptions, etc.) | Not part of this technical roadmap |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| AI-01 | Phase 2 | Pending |
| AI-02 | Phase 2 | Pending |
| AI-03 | Phase 2 | Pending |
| AI-04 | Phase 2 | Pending |
| AI-05 | Phase 4 | Pending |
| OFF-01 | Phase 4 | Pending |
| OFF-02 | Phase 4 | Pending |
| OFF-03 | Phase 4 | Pending |
| OFF-04 | Phase 4 | Pending |
| MKT-01 | Phase 3 | Pending |
| MKT-02 | Phase 3 | Pending |
| MKT-03 | Phase 3 | Pending |
| PRIV-01 | Phase 2 | Pending |
| PRIV-02 | Phase 2 | Pending |
| PRIV-03 | Phase 2 | Pending |
| DEP-01 | Phase 1 | Complete |
| DEP-02 | Phase 1 | Complete |
| DEP-03 | Phase 1 | Complete |
| DEP-04 | Phase 1 | Complete |
| DEP-05 | Phase 1 | Complete |
| UI-01 | Phase 5 | Pending |
| UI-02 | Phase 5 | Pending |
| UI-03 | Phase 5 | Pending |
| UI-04 | Phase 5 | Pending |
| UI-05 | Phase 5 | Pending |

**Coverage:**
- v1 requirements: 25 total
- Mapped to phases: 25
- Unmapped: 0

---
*Requirements defined: 2026-02-21*
*Last updated: 2026-02-21 after roadmap creation*
