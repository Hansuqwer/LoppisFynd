# Feature Research

**Domain:** Nature Distilled UI/UX overhaul milestone (existing Flutter app)
**Researched:** 2026-02-18
**Confidence:** HIGH

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Nature Distilled design tokens + theme consistency | Visual overhaul must feel coherent across screens | MEDIUM | Implement/complete token set used by the handoff: colors/spacing/radius/shadows/motion/typography plus blur tokens (`AppBlur`) and patch v2 additions (board radius + opacity helpers). |
| Shared atmosphere backgrounds | Background is part of the design language, not a per-screen afterthought | MEDIUM | Persistent `NatureBackground` (gradient + subtle topographic lines) and login motif overlay (repeating brand stamps) per handoff.
| Glass primitives (tile/board/backplates) | Glass panels are the primary container style in the reference pack | MEDIUM | Reusable `GlassSurface`, plus patch v2’s `GlassBoard` and `StackedBackplates` for the stacked-glass look.
| Capsule navigation shell (5 tabs) | Reference pack shows capsule nav; users expect consistent navigation | MEDIUM | Replace Material `NavigationBar` with capsule nav + `IndexedStack` to keep tab state; patch v2 requires selected “bubble” behavior and canonical 5-tab set.
| Startup flow Screens 1–5 (Onboarding 1–3 + Login 4–5) | App must match provided startup screenshots + reference pack login visual | HIGH | Screen 3 includes Gemma prompt + clickable “Varför?”; startup must be non-blocking and allow proceeding while downloads continue.
| Onboarding Screen 3: Gemma download callout | Mandatory v2 delta; user consent required before download | HIGH | Callout module: title/body, primary “Ladda ned” CTA, “Varför?” link to explainer sheet, progress + percent while downloading, installed/failed states, retry.
| Model download consent gating (no auto-download) | Prevents unexpected downloads; explicitly called out as requirement | MEDIUM | Remove/guard current startup best-effort auto-download; persist `gemma_download_consent=1` on user action and only then allow background download.
| Model download + install pipeline with progress + retry | Download must feel trustworthy and recoverable | HIGH | Riverpod state machine (`ModelInstallState`), `ModelManager.downloadFromUrlWithProgress`, install service (`GemmaInstallService`), failure messaging + retry.
| Model download completion feedback (popup) | Users need closure + understanding of what changed | MEDIUM | Mandatory delta: show a completion popup styled with the reference “dopamine red” and explain what the model enables (offline AI features). (Source: milestone requirements + design language.)
| Auth: signup-first OTP flow + trouble signing in | Mandatory v2 delta; fixes confusion in OTP/magic-link flows | HIGH | Default mode is “Skapa konto”; 2-step (send -> verify) with resend on code step; “Problem att logga in?” bottom sheet; glass + motif visuals match reference pack.
| Copy + localization (no hard-coded UI strings) | Handoff requires all UI strings be localizable and copy be clean | MEDIUM | All new strings must go through `AppLocalizations`; fix reference-pack typos/placeholders; add the required new l10n keys (model callout, auth, home, haul, draft).
| Home screen (ref pack page: Home) | Primary app entry must match the new language | MEDIUM | Hero CTA card + bento tiles; replace placeholder subtitle with real Swedish; capsule nav present.
| Current Haul screen (ref pack page: Current Haul) | Core workflow screen must match the new language | MEDIUM | Glass stack list + “Totalt värde:” summary; red camera action (in-board / FAB as per reference).
| History empty state (ref pack page: History Empty) | Empty state is part of onboarding into the product | MEDIUM | Search bar, pebble filters (Båda/Karta/Lista/Bäst marginal), coffee-cup illustration + copy.
| Draft editor (ref pack page: Draft Editor) | Drafting is a key workflow and must match layout language | MEDIUM | Stacked glass feel; preview + AI tag chips; fields (Rubrik/Beskrivning/Pris (SEK)); save (wide red pill) + delete (light pill + trash).
| Profile/Settings (ref pack page: Profile/Settings) | Users need a clean control center consistent with new UI | MEDIUM | Bento modules: “Molnsynk & Data”, “AI & Modell”, “Integritet”; toggles/buttons shown in reference; show model status in AI module.
| UI drift prevention (goldens + strictness rule) | Prevents regressions when iterating | MEDIUM | Add/update golden tests for at least: Login, Home, History empty, Draft editor (and any additional screens called out in patch v2). Document any deviations from the reference pack in PR + add a regression test.

### Differentiators (Competitive Advantage)

Features that set the product apart. Not required, but valuable.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Layered “Nature Distilled” atmosphere (topography + glass inner highlights) | Makes the UI feel tactile and brand-distinct vs standard Material | MEDIUM | Implemented via `NatureBackground` + updated `GlassSurface` (inner highlight/gradient) per patch v2.
| Capsule nav motion/feel (spring-like, selected bubble) | Feels premium and intentional; improves perceived performance | MEDIUM | Use existing motion tokens (`AppMotion`) and the selection bubble behavior from patch v2.
| Model “Why?” explainer sheet | Reduces fear about on-device model downloads + builds trust | LOW | Bottom sheet copy is specified in required localization keys; keep it short and clear.

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Auto-download Gemma on app start | “Make it seamless” | Violates v2 requirement; surprises users with large download/battery use | Ask on Onboarding #3; persist consent; download in background only after user action |
| Handwritten font used for body/inputs | “More personality” | Hurts readability/accessibility; explicitly prohibited | Use handwritten font only for accent wordmark/brand accents via `AppTypography.accentBrand` |
| Shipping reference-pack placeholder/typo copy | “It looks fine in mock” | Breaks credibility; spec explicitly calls these out | Fix strings per patch v2; enforce l10n usage |
| Unclipped / full-screen blur (`BackdropFilter`) | “More glass!” | Perf killer (Impeller); spec forbids | Clip every blur region (`ClipRRect/ClipRect`) and keep blur surfaces small |
| Adding extra settings toggles beyond the reference pack | “Expose everything” | Breaks “clean by default” settings intent | Keep to the bento modules/controls specified; hide advanced controls elsewhere (e.g., existing Dev Mode) |

## Feature Dependencies

```
[Tokens + Theme]
    └──requires──> [Shared Primitives: NatureBackground / GlassSurface / GlassBoard / CapsuleNavBar]
                       └──requires──> [App Shell (persistent background + capsule nav + IndexedStack)]
                                          └──enables──> [Screen Reskins (Home/Haul/History/Drafts/Profile/Auth)]

[Model download state + services]
    └──requires──> [Onboarding Screen 3 callout]
                       └──enhances──> [Profile AI & Modell module (model status)]

[Localization keys]
    └──requires──> [All new UI strings + copy fixes]

[Golden tests]
    └──requires──> [Screens stabilized to reference visuals]
```

### Dependency Notes

- **Tokens + Theme requires Shared Primitives:** primitives must be built on tokens to keep spacing/blur/radii consistent.
- **Shared Primitives require App Shell:** capsule nav + persistent background are cross-screen concerns.
- **Model download state requires Onboarding callout:** callout drives consent + starts download; state needs to persist while user continues into login.
- **Localization requires all new UI strings:** v2 explicitly forbids new hard-coded strings in UI.

## MVP Definition

### Launch With (v1)

Minimum viable product — what's needed to validate the concept.

- [ ] Startup flow matches Screens 1–5 (Onboarding 1–3 + Login 4–5)
- [ ] Onboarding #3 Gemma prompt: CTA + progress + retry + “Varför?” explainer; download continues in background
- [ ] No auto-download at startup; consent gating persisted (`gemma_download_consent`)
- [ ] Signup-first login + “Problem att logga in?” affordance; visuals match glass + motif
- [ ] Home, Current Haul, History (Empty), Draft Editor, Profile/Settings match the Visual Reference Pack layouts/copy
- [ ] All new strings localized; reference-pack typos/placeholders removed
- [ ] Model completion popup (reference red) explains what the model enables (offline AI)
- [ ] Golden tests added/updated for key screens (at least Login/Home/History empty/Draft editor)

### Add After Validation (v1.x)

Features to add once core is working.

- [ ] Reskin remaining non-referenced screens (e.g., full History list, Drafts list, Scanner overlay) to the same primitives/tokens, if not already covered by the milestone scope

### Future Consideration (v2+)

Features to defer until product-market fit is established.

- [ ] Additional motion polish beyond what the handoff calls for (avoid adding custom animation systems)

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Startup flow Screens 1–5 (incl. signup-first login) | HIGH | HIGH | P1 |
| Gemma download callout + background download + retry | HIGH | HIGH | P1 |
| Model completion popup (reference red + explanation) | MEDIUM | MEDIUM | P1 |
| App shell with capsule nav + persistent background | HIGH | MEDIUM | P1 |
| Home/Haul/History empty/Draft/Profile reskins | HIGH | MEDIUM | P1 |
| Localization + copy fixes (no hard-coded strings) | HIGH | MEDIUM | P1 |
| Goldens for key screens | MEDIUM | MEDIUM | P1 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

## Competitor Feature Analysis

Not applicable for this milestone: scope is implementing the provided Nature Distilled handoff + visual reference pack.

## Sources

- `docs/LoppisFynd_Nature_Distilled_Technical_Handoff_v2.md`
- `docs/UiUxOverHaul/Technical_Handoff_Patch_v2.md`
- `docs/LoppisFynd_Nature_Distilled_Visual_Reference_Pack.pdf`

---
*Feature research for: Nature Distilled UI/UX overhaul milestone*
*Researched: 2026-02-18*
