# Requirements: LoppisFynd — Nature Distilled UI/UX Overhaul

**Defined:** 2026-02-18
**Core Value:** Users can reliably scan and manage finds offline, with on-device AI enabling fast identification without network.

## v1 Requirements

### Design System & Shared Primitives

- [ ] **DS-01**: App uses a stable token system for colors, spacing, radius (incl. board), shadows, motion, typography, and blur; screens derive styles from tokens (no ad-hoc constants).
- [ ] **DS-02**: Every blur is clipped (no full-screen `BackdropFilter`); shared glass primitives enforce this constraint.
- [ ] **DS-03**: App provides reusable primitives matching the reference pack: `NatureBackground`, `LogoMotifOverlay`, `GlassSurface`, `GlassBoard`, `StackedBackplates`, `CapsuleNavBar`.

### Navigation Contract (5 Tabs)

- [ ] **NAV-01**: Tabs remain exactly: Home, Scan, Haul, History, Profile (no navigation regression).
- [ ] **NAV-02**: App shell uses persistent Nature Distilled background + capsule nav and keeps tab state alive (e.g., `IndexedStack`).
- [ ] **NAV-03**: Capsule nav shows an explicit selected “bubble” state consistent with the Visual Reference Pack.

### Startup Flow (Screens 1–5)

- [ ] **ONB-01**: Onboarding screens 1–3 match the handoff/startup screenshots and use localized Swedish copy with correct diacritics.
- [ ] **ONB-02**: Onboarding screen #3 asks the user to download the on-device Gemma model and includes a clickable info link ("Varför?").
- [ ] **ONB-03**: If the user accepts, model download starts immediately and continues in the background while the user proceeds.

### Model Download & Install UX (Real State)

- [ ] **MDL-01**: Model download is gated behind persisted user consent (no silent auto-download on app start).
- [ ] **MDL-02**: Model download UI reflects real state (downloading/installing/ready/failed) and shows progress when available (no fake progress).
- [ ] **MDL-03**: On successful install, app shows a completion popup using the reference red color and explains what the model enables (offline AI scan/faster identify/better results).
- [ ] **MDL-04**: Failures are recoverable (retry) and do not block onboarding completion.

### Auth (Signup-First + Trouble Link)

- [ ] **AUTH-01**: Login experience is signup-first (primary/default mode is "Skapa konto") and matches the reference glass/motif layout.
- [ ] **AUTH-02**: Login includes an explicit "Lost password / Trouble signing in" affordance with OTP-friendly wording.

### Screen Visual Parity (Reference Pack Pages 4–8)

- [ ] **SCR-01**: Home screen matches reference layout (hero CTA + bento tiles + capsule nav), with placeholder copy replaced by real Swedish.
- [ ] **SCR-02**: Current Haul screen matches reference layout (summary with "Totalt värde:" and list rows; camera action styled per reference).
- [ ] **SCR-03**: History empty state matches reference (search bar + pebble filters + coffee-cup empty state + Swedish copy).
- [ ] **SCR-04**: Draft editor matches reference (stacked glass, preview, AI tags, fields incl. "Pris (SEK)", save/delete actions styled per reference).
- [ ] **SCR-05**: Profile/Settings matches reference (bento modules: "Molnsynk & Data", "AI & Modell", "Integritet"), clean by default.

### Localization & Copy Quality

- [ ] **L10N-01**: No new user-facing strings are hardcoded in widgets; all UI strings come from `AppLocalizations`.
- [ ] **L10N-02**: Swedish copy ships with correct spelling and diacritics (å, ä, ö), and known reference-pack typos/placeholders are fixed.
- [ ] **L10N-03**: Handwritten font is used only for accent typography (never for buttons, forms, or long paragraphs).

### Regression Safety (Goldens)

- [ ] **QA-01**: Golden tests exist/are updated for the most important Nature Distilled screens to prevent UI drift (at minimum: Login, Home, History empty, Draft editor).

### Offline-First Promise

- [ ] **OFF-01**: Offline flows remain functional for core product use; UI changes do not introduce online-only blockers (except existing price fetch behavior).

## v2 Requirements

### Additional Reskins

- **SCR-06**: Reskin remaining non-referenced screens (scanner overlay/details/drafts list/full history) to the same tokens/primitives without changing IA.

### Extra Polish

- **POL-01**: Add additional motion polish beyond the handoff only after v1 is visually locked and covered by goldens.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Changing the information architecture (routes/tabs) | Navigation must not regress; reference pack assumes 5-tab structure |
| Auto-downloading Gemma without consent | Explicitly disallowed by handoff v2 (user must be asked on onboarding #3) |
| Hardcoded strings in UI | Must be localized via `AppLocalizations` |
| Using handwritten font for body/forms/buttons | Explicitly prohibited (accent-only) |

## Traceability

Which phases cover which requirements. Populated/updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| DS-01 | Phase 1 | Verified |
| DS-02 | Phase 1 | Verified |
| DS-03 | Phase 1 | Verified |
| NAV-01 | Phase 2 | Verified |
| NAV-02 | Phase 2 | Verified |
| NAV-03 | Phase 2 | Verified |
| ONB-01 | Phase 3 | Pending |
| ONB-02 | Phase 3 | Pending |
| ONB-03 | Phase 3 | Pending |
| MDL-01 | Phase 3 | Pending |
| MDL-02 | Phase 3 | Pending |
| MDL-03 | Phase 3 | Pending |
| MDL-04 | Phase 3 | Pending |
| AUTH-01 | Phase 3 | Pending |
| AUTH-02 | Phase 3 | Pending |
| SCR-01 | Phase 4 | Pending |
| SCR-02 | Phase 4 | Pending |
| SCR-03 | Phase 4 | Pending |
| SCR-04 | Phase 4 | Pending |
| SCR-05 | Phase 4 | Pending |
| L10N-01 | Phase 1 | Verified |
| L10N-02 | Phase 1 | Verified |
| L10N-03 | Phase 1 | Verified |
| QA-01 | Phase 4 | Pending |
| OFF-01 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 25 total
- Mapped to phases: 25
- Unmapped: 0

## Spec References (Implementation Contract)

- `docs/LoppisFynd_Nature_Distilled_Visual_Reference_Pack.pdf` (visual source of truth)
- `docs/LoppisFynd_Nature_Distilled_Technical_Handoff_v2.md` (full technical contract; key areas include startup flow, model download, login, shared primitives, copy/l10n, QA)
- `docs/UiUxOverHaul/Technical_Handoff_Patch_v2.md` (copy fixes + required primitives deltas)

---
*Requirements defined: 2026-02-18*
