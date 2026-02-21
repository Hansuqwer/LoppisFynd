# FyndLoppis Flutter Roadmap 2026-2027

**Version:** 1.1  
**Date:** 2026-02-21  
**Status:** DRAFT for Review (updated after UI System v2 assets/tokens were added)  
**Goal:** Future-proof the Flutter app with modern tech stack and UI while maintaining iOS/Android support

---

## 1. Executive Summary

This roadmap outlines the technical evolution of FyndLoppis from Q1 2026 through Q4 2027. The primary focus remains removing the Gemma on-device model as a first-run dependency (critical blocker) and replacing it with a cloud-first AI architecture while adding an optional lightweight offline fallback.

**UI baseline update:** The UI System v2 asset pack and token scaffolding (Minimalistic Palette “New Light”, ramps, semantic tokens, logos/backgrounds/textures + tokenized asset registry) is now considered **already landed**, so it has been removed from future milestones. The remaining UI work is now about **adoption**, **dark mode wiring**, and **screen-by-screen migration**, not introducing assets/tokens.

**Key Principles:**
- Stay on Flutter (no native rewrite)
- Maintain offline-first capability
- Keep iOS and Android support
- Evolve UI toward 2027-2028 standards incrementally

---

## 2. OKRs (Objectives & Key Results)

### OKR 1: Remove First-Run Blocker
- **Objective:** Eliminate the 4GB Gemma download that blocks new users
- **Key Results:**
  - [ ] Cloud Gemini becomes primary AI (no download required)
  - [ ] User-togglable settings for cloud vs offline mode
  - [ ] App launches immediately without model download

### OKR 2: Modernize Tech Stack
- **Objective:** Update dependencies to 2026-2027 standards
- **Key Results:**
  - [ ] All critical packages updated to latest stable
  - [ ] No deprecated APIs in use
  - [ ] Build passes on latest Flutter stable

### OKR 3: UI Evolution (Token Adoption + Dark Mode + Responsiveness)
- **Objective:** Refine UI toward 2027-2028 standards using the already-landed UI System v2 tokens/assets as the baseline.
- **Key Results:**
  - [ ] Dark mode shipped using existing token set (no hardcoded colors/assets in screens)
  - [ ] 90%+ of shared primitives & top screens migrated to semantic + ramp tokens (golden tests passing)
  - [ ] Responsive layout support for foldables/tablets

---

## 3. Milestone Roadmap

### Milestone 1: Hybrid AI Enablement (Q1 2026)

**Goal:** Remove Gemma as startup dependency, add cloud AI as default

| Task | Description | Effort | Priority |
|------|-------------|--------|----------|
| M1.1 | Remove Gemma from first-run flow | M | CRITICAL |
| M1.2 | Add cloudGemini backend to AI abstraction | M | CRITICAL |
| M1.3 | Add first-run settings toggles | S | HIGH |
| M1.4 | Keep Gemma as opt-in "offline-ID mode" | M | HIGH |
| M1.5 | Update pubspec.yaml (remove flutter_gemma default) | S | HIGH |

**Settings Toggles:**
- "Send crops for cloud identification" (default: ON)
- "Fetch sold-price comps" (default: ON)

**Exit Criteria:**
- [ ] App works fully without any Gemma download
- [ ] AI becomes opt-in acceleration
- [ ] User can toggle between cloud and offline modes

---

### Milestone 2: Lightweight Offline Fallback (Q2 2026)

**Goal:** Add commercial-safe offline object detection

| Task | Description | Effort | Priority |
|------|-------------|--------|----------|
| M2.1 | Integrate flutter_yolo_open_kit | M | HIGH |
| M2.2 | Create YOLOX inference backend | M | HIGH |
| M2.3 | Fine-tune model on secondhand taxonomy | L | MEDIUM |
| M2.4 | Add evidence fields to JSON response | S | MEDIUM |
| M2.5 | Test offline detection accuracy | M | MEDIUM |

**Technical Note:** Using YOLOX (Apache 2.0) instead of Ultralytics YOLO11 because:
- YOLO11 is AGPL-3.0 licensed (cannot ship on Google Play without Enterprise license)
- YOLOX is Apache 2.0 (commercial safe)
- Similar performance at comparable sizes (1.5-5MB)

**Exit Criteria:**
- [ ] Offline detection works without network
- [ ] Model size is under 10MB
- [ ] Detection provides evidence (bounding boxes)

---

### Milestone 3: Dependency Modernization (Q2–Q3 2026)

**Goal:** Update all packages to current stable versions

| Task | Description | Effort | Priority |
|------|-------------|--------|----------|
| M3.1 | Update Riverpod to 2.7+ | S | HIGH |
| M3.2 | Update Drift to 2.32+ | S | HIGH |
| M3.3 | Update camera package | S | MEDIUM |
| M3.4 | Update workmanager | S | MEDIUM |
| M3.5 | Run full test suite | M | HIGH |
| M3.6 | Fix any deprecation warnings | M | MEDIUM |

**Exit Criteria:**
- [ ] All packages at target versions
- [ ] No build warnings
- [ ] All tests pass

---

### Milestone 4: Dark Mode Wiring + Token Adoption Pass (Q3 2026)

**Goal:** Ship dark mode using the already-landed UI System v2 tokens/assets, and eliminate remaining hardcoded UI color/asset usage in shared primitives.

| Task | Description | Effort | Priority |
|------|-------------|--------|----------|
| M4.1 | Wire ThemeData (light + dark) to semantic + ramp tokens | S | HIGH |
| M4.2 | Add system/manual dark mode toggle + persist preference | S | MEDIUM |
| M4.3 | Ensure shared primitives fully respect tokens (GlassSurface/Overlay/Board, NatureBackground, LogoMotifOverlay, BentoCard) | M | HIGH |
| M4.4 | Use the dedicated dark hero background token (no hardcoded dark images) | S | HIGH |
| M4.5 | Golden tests: light/dark parity + contrast audit | M | HIGH |

**Dark Mode Guidance (token-driven):**
- Dark backgrounds should prefer the dark ramp + the dedicated dark hero background image token (for hero contexts).
- Semantic tokens are for *states only* (error/warn/link), not for normal surfaces.

**Exit Criteria:**
- [ ] Dark mode toggle works
- [ ] All screens readable in dark mode (contrast verified)
- [ ] No hardcoded UI colors/assets added in new code

---

### Milestone 5: Responsive Layout (Q3–Q4 2026)

**Goal:** Support foldables and tablets

| Task | Description | Effort | Priority |
|------|-------------|--------|----------|
| M5.1 | Add layout breakpoints | S | MEDIUM |
| M5.2 | Update BentoCard and key layout containers for responsive | M | MEDIUM |
| M5.3 | Add tablet/foldable layouts for top flows | L | MEDIUM |
| M5.4 | Test on foldable devices | L | MEDIUM |

**Exit Criteria:**
- [ ] UI adapts to different screen sizes
- [ ] Foldable devices work in both states
- [ ] No layout overflow issues

---

### Milestone 6: Token Governance + Export (Q4 2026)

**Goal:** Keep tokens stable long-term and make them portable.

> Note: Token documentation + component spec lives in the UI System v2 PDF. This milestone focuses on export, tooling, and enforcement.

| Task | Description | Effort | Priority |
|------|-------------|--------|----------|
| M6.1 | Export tokens to W3C Design Tokens JSON | M | MEDIUM |
| M6.2 | Add generator (JSON → Dart) and CI drift check | M | MEDIUM |
| M6.3 | Add enforcement: forbid new hardcoded colors/assets in UI layer (lint or CI check) | S | HIGH |
| M6.4 | Responsive typography audit across breakpoints (Outfit/Space Grotesk/Accent) | S | MEDIUM |

**Exit Criteria:**
- [ ] Tokens exported and versioned
- [ ] CI prevents token drift / hardcoded regressions
- [ ] Typography consistent across devices

---

### Milestone 7: Future-Proofing 2027 (Q1–Q2 2027)

**Goal:** Position for 2027-2028 UI trends

| Task | Description | Effort | Priority |
|------|-------------|--------|----------|
| M7.1 | Evaluate Material 3 Expressive adoption | S | LOW |
| M7.2 | Add variable font support | S | LOW |
| M7.3 | Micro-interaction audit | M | LOW |
| M7.4 | Performance optimization | M | MEDIUM |

---

## 4. Technical Architecture

### AI Pipeline (After M1–M2)

```
┌─────────────────────────────────────────┐
│         User captures item photo         │
└─────────────────┬───────────────────────┘
                  │
         ┌────────▼────────┐
         │  Settings Check   │
         │  "Cloud ID" ON?  │
         └────────┬────────┘
                  │
         ┌────────┴────────┐
         │                 │
    YES  ▼                 ▼  NO
┌─────────────┐   ┌─────────────┐
│ Cloud Gemini │   │  YOLOX      │
│ (default)    │   │  (offline)  │
└─────────────┘   └─────────────┘
```

### State Management (Unchanged)

Keep Riverpod as-is. Current architecture is sound:
- Providers in `lib/core/app/providers.dart`
- Feature screens watch providers
- DAOs provide reactive streams

### Database (Unchanged)

Keep Drift as-is. Current schema is production-ready.

---

## 5. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| YOLOX accuracy insufficient | Medium | Medium | Fine-tune on custom dataset |
| Cloud API costs too high | Low | High | Set usage limits, monitor costs |
| Dark mode breaks existing UI | Medium | Medium | Comprehensive testing + golden tests |
| Package conflicts on update | Low | Medium | Incremental updates, test each |

---

## 6. Success Metrics

### Quantitative
- App first-run time: < 5 seconds (currently blocked by 4GB download)
- Offline detection accuracy: > 80%
- Package update coverage: 100%
- Dark mode adoption: TBD via analytics

### Qualitative
- User complaints about download blocking: 0
- UI feels "modern" in 2027 review
- Tokens prevent regressions (no new hardcoded colors/assets)

---

## 7. Out of Scope

The following are explicitly NOT in this roadmap:
- [ ] Migrating to native Android or iOS
- [ ] Major architecture changes (keep Riverpod/Drift)
- [ ] Adding new platforms (web, desktop)
- [ ] Revenue model changes (subscriptions, etc.)

---

## 8. Dependencies & Prerequisites

### Prerequisites
- Flutter 3.12+ stable
- Dart 3.12+
- iOS deployment target 12.0+
- Android minSdk 24+

### External Services (Unchanged)
- Supabase (optional cloud sync)
- Tradera API (price comps)
- Gemini API (cloud AI)

---

## 9. Review Notes

### Questions for Reviewers
1. Is the Q1 timeline realistic for Milestone 1?
2. Should YOLOX fine-tuning be prioritized higher?
3. Is dark mode critical enough for Q3, or can it slip?
4. Are there any compliance concerns with cloud AI?

### Assumptions
- Team has capacity to work on roadmap items
- No major scope changes during execution
- External APIs (Gemini, Tradera) remain available

---

## 10. Appendix

### Related Documents
- UI System v2 spec: `LoppisFynd_UI_System_v2_MinimalisticPalette.pdf`
- Current stack: `docs/Research/STACK.md`
- Architecture: `docs/Research/ARCHITECTURE.md`
- UI handover: `docs/UiUxOverHaul/UIUX_Handover_ScreenByScreen.md`
- Lightweight model research: `.planning/research/lightweight_model_replacement.md`
- Tech stack analysis: `.planning/research/flutter_vs_android_stack_analysis.md`
- Full recommendation: `.planning/research/tech_stack_ui_recommendation_2027_2028.md`

### Glossary
- **Drift:** Flutter SQLite database library
- **Riverpod:** Flutter state management
- **YOLOX:** Object detection model (Apache 2.0 licensed)
- **Gemini:** Google's cloud AI API
- **Design Tokens:** W3C-standardized design values

---

**Document Status:** DRAFT  
**Next Review:** [To be scheduled]  
**Owner:** [To be assigned]
