# Roadmap: LoppisFynd - Nature Distilled UI/UX Overhaul

## Overview

Implement the Nature Distilled overhaul as a contract-driven retrofit: first lock in tokens/primitives and localization rules, then swap the shell to the capsule 5-tab navigation contract, deliver the full startup flow (onboarding + signup-first auth + consent-gated Gemma download with real state), and finally reskin the five core tabs with golden tests and offline-first regression safety.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

- [x] **Phase 1: Design System + Guardrails** - Tokens, clipped-blur glass primitives, and localization/copy rules. (completed 2026-02-18)
- [x] **Phase 2: Capsule Navigation Shell** - Persistent Nature background + capsule nav with the 5-tab contract and state retention. (completed 2026-02-18)
- [ ] **Phase 3: Startup + Auth + Model Download** - Onboarding 1-3 + signup-first login + consent-gated, real-state Gemma download.
- [ ] **Phase 4: Core Screens + Goldens** - Visual parity for core tabs/settings, offline-first safety, and golden regression coverage.

## Phase Details

### Phase 1: Design System + Guardrails
**Goal**: Users experience a consistent Nature Distilled visual language driven by tokens and reusable, performance-safe primitives (clipped blur), with localized copy conventions enforced.
**Depends on**: Nothing (first phase)
**Requirements**: DS-01, DS-02, DS-03, L10N-01, L10N-02, L10N-03
**Success Criteria** (what must be TRUE):
  1. Nature Distilled surfaces share consistent spacing/radius/typography/blur because screens derive styling from tokens (not ad-hoc widget constants).
  2. Any glass/blur surface is clipped to its bounds (no full-screen backdrop blur), and it looks correct in motion on-device.
  3. Swedish UI copy in the updated surfaces ships with correct spelling and diacritics (å, ä, ö), and known reference-pack placeholders/typos are not shipped.
  4. Handwritten accent typography is used only for brand accents (never for buttons, forms, or long paragraphs).
**Plans**: 5 plans

Plans:
- [x] 01-01: Tokens + theme wiring (colors/spacing/radius/blur/motion/typography)
- [x] 01-02: Shared primitives (NatureBackground, LogoMotifOverlay, GlassSurface, GlassBoard, StackedBackplates, CapsuleNavBar)
- [x] 01-03: Localization/copy guardrails (AppLocalizations-only + copy fix pass)
- [x] 01-04: Gap closure — tokenize LogoMotifOverlay shadows + clean custom_lint
- [x] 01-05: Gap closure — on-device glass blur motion/perf verification

### Phase 2: Capsule Navigation Shell
**Goal**: Users can navigate via the Nature Distilled capsule nav while keeping the 5-tab contract and preserving each tab's state.
**Depends on**: Phase 1
**Requirements**: NAV-01, NAV-02, NAV-03
**Success Criteria** (what must be TRUE):
  1. User can switch between exactly five tabs (Home, Scan, Haul, History, Profile) with no route/name regression.
  2. Capsule nav shows an explicit selected "bubble" state consistent with the Visual Reference Pack.
  3. Switching tabs preserves in-tab state (e.g., scroll positions/inputs) rather than rebuilding from scratch.
  4. Nature background persists behind all tabs and content is not obscured by the capsule (safe insets).
**Plans**: 2 plans

Plans:
- [x] 02-01: Replace app shell with persistent Nature background + IndexedStack state retention
- [x] 02-02: Capsule nav selected-bubble behavior + tab contract assertions

### Phase 3: Startup + Auth + Model Download
**Goal**: Users complete onboarding and access the app via a signup-first login, while optionally consenting to a real-state Gemma model download that continues in the background.
**Depends on**: Phase 2
**Requirements**: ONB-01, ONB-02, ONB-03, MDL-01, MDL-02, MDL-03, MDL-04, AUTH-01, AUTH-02
**Success Criteria** (what must be TRUE):
  1. User can swipe through onboarding screens 1-3 and see localized Swedish copy with correct diacritics.
  2. On onboarding screen #3, user is asked to download the on-device Gemma model and can tap a clickable info link ("Varför?") to learn more.
  3. Model download never starts without explicit user consent; if consent is given, download starts immediately and continues in the background while the user proceeds.
  4. Model download UI reflects real state (downloading/installing/ready/failed), shows progress when available (no fake progress), failures are recoverable via retry without blocking onboarding completion, and success triggers a completion popup using the reference red color.
  5. Login experience is signup-first (default "Skapa konto"), matches the glass/motif reference, and includes a "Lost password / Trouble signing in" affordance with OTP-friendly wording.
**Plans**: 4 plans

Plans:
- [ ] 03-01: Onboarding screens 1-3 with Gemma callout + "Varför?" explainer sheet
- [x] 03-02: Signup-first login UI + trouble-sign-in affordance
- [ ] 03-03: Consent-gated model download/install controller + refactor download entrypoints (no auto-download)
- [ ] 03-04: Model status chip + one-time red completion popup + Settings opt-in later (localized)

### Phase 4: Core Screens + Goldens
**Goal**: Users see the five core tabs/settings match the reference layouts and can use the app offline as before, with golden tests preventing future UI drift.
**Depends on**: Phase 3
**Requirements**: SCR-01, SCR-02, SCR-03, SCR-04, SCR-05, QA-01, OFF-01
**Success Criteria** (what must be TRUE):
  1. Home, Current Haul, History empty state, Draft editor, and Profile/Settings match the Visual Reference Pack layouts and show real Swedish copy (no placeholders).
  2. Profile/Settings is clean by default and presents the referenced bento modules ("Molnsynk & Data", "AI & Modell", "Integritet").
  3. Core offline workflows remain functional (save/manage finds) and UI changes do not introduce new online-only blockers.
  4. Golden tests exist/are updated for the minimum key screens (Login, Home, History empty, Draft editor) and pass in CI to prevent UI drift.
**Plans**: 3 plans

Plans:
- [ ] 04-01: Reskin core screens to parity (Home, Haul, History empty, Draft editor)
- [ ] 04-02: Reskin Profile/Settings modules to parity (clean default)
- [ ] 04-03: Golden coverage + offline-first regression sanity

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Design System + Guardrails | 5/5 | Complete    | 2026-02-18 |
| 2. Capsule Navigation Shell | 2/2 | Complete    | 2026-02-18 |
| 3. Startup + Auth + Model Download | 1/4 | In Progress | - |
| 4. Core Screens + Goldens | 0/3 | Not started | - |
