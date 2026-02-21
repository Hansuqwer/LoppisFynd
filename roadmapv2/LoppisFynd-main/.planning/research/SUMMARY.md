# Project Research Summary

**Project:** LoppisFynd — Nature Distilled UI/UX Overhaul
**Domain:** Contract-driven Flutter UI/UX retrofit (pixel-accurate “Nature Distilled”), offline-first, strict sv/en localization, golden-regression discipline
**Researched:** 2026-02-18
**Confidence:** HIGH

## Executive Summary

This project is a UI/UX overhaul of an existing offline-first Flutter app, with a strict visual contract (Nature Distilled reference pack + handoff docs). The safest “expert” approach is to treat it as a design-system retrofit: centralize design tokens and shared primitives (glass, boards, backgrounds, capsule nav) as a churn boundary, then reskin screens by composition while preserving existing Riverpod + Drift data flows.

The recommended implementation order is: guardrails (localization/no-hardcoded strings, pinned Flutter, golden harness) -> primitives + performance baseline (clipped blur, grouped blurs for lists) -> navigation shell swap (IndexedStack + consistent insets) -> startup/auth + tab screens -> model download UX/state machine (consent-gated, real progress, background continuation) -> release hardening (goldens + device sanity checks). This sequencing minimizes regressions while keeping pixel parity achievable.

Key risks are (1) blur performance and visual correctness (unclipped BackdropFilter, saveLayer/opacity interactions, too many list blurs), (2) localization/copy drift (hardcoded strings, Swedish diacritics regressions), and (3) navigation regressions when swapping the bottom nav. Mitigate by enforcing blur rules inside primitives, adding CI guardrails for string literals/typos, defining a nav contract + inset helper, and backing the overhaul with goldens for both primitives and key screens.

## Key Findings

### Recommended Stack

The current Flutter stack is already appropriate; the primary “stack” decisions are about determinism and enforcement. Pin Flutter (as CI already does) to reduce golden churn, keep Material 3 plumbing but express Nature Distilled through tokens + `ThemeExtension`, and make localization and golden testing first-class quality gates.

**Core technologies:**
- Flutter SDK (stable, pinned to repo revision) : deterministic rendering/tooling -- reduces golden churn and cross-machine drift.
- Material 3 (`ThemeData`, `ColorScheme`) + `ThemeExtension` : semantic theming -- maps Nature Distilled tokens cleanly without fighting widgets.
- `gen_l10n` + ARB : strict sv/en localization -- enforces “no hardcoded UI strings” with reports/metadata.
- `flutter_test` goldens : pixel-regression safety net -- stable output when fonts are loaded via `flutter_test_config.dart`.

### Expected Features

This milestone is effectively “implement the reference pack.” Table stakes are the tokens + shared atmosphere, glass primitives, capsule nav shell, startup/onboarding + signup-first auth, and reskins for the five core tabs. Differentiators are mostly “feel” (atmosphere layering, capsule motion) rather than new product surface.

**Must have (table stakes):**
- Nature Distilled tokens + theme consistency (including blur/opacity/radius/motion) -- coherence across every screen.
- Shared primitives: `NatureBackground`, `GlassSurface/GlassBoard/StackedBackplates`, capsule nav -- avoid per-screen one-offs.
- App shell: 5 tabs with `IndexedStack`, persistent background, preserved tab contract -- no nav regressions.
- Startup flow Screens 1-5 (Onboarding 1-3 + Login 4-5), incl. Onboarding #3 Gemma callout -- matches the provided screens.
- Consent-gated model download with real progress, retry, and completion popup; download continues while user proceeds -- mandatory v2 delta.
- Signup-first OTP login with “Problem att logga in?” affordance -- mandatory v2 delta.
- Localization + copy fixes (no hardcoded strings; correct Swedish diacritics) -- non-negotiable quality bar.
- UI drift prevention: goldens for key screens (at least Login/Home/History empty/Draft editor) -- prevents regressions during iteration.

**Should have (competitive):**
- Layered atmosphere polish (topographic lines + glass inner highlights) -- tactile brand feel.
- Capsule nav selection-bubble motion tuned via tokens -- premium perceived performance.
- “Varfor?” explainer sheet for model download -- trust and clarity.

**Defer (v2+):**
- Extra motion polish beyond the handoff (avoid inventing an animation system) -- not essential for launch.

### Architecture Approach

Implement as a design-system layer inserted between existing feature screens and the domain/services layer. Preserve offline-first invariants (Drift is source of truth; “price fetch” remains the only online-only feature) while swapping visuals via tokens + shared widgets, and centralize long-running UX (model install) in a controller-driven state machine.

**Major components:**
1. `lib/core/tokens/**` + `lib/core/theme/**` : tokens + theme composition -- single source of truth for all visuals.
2. `lib/shared/widgets/**` (+ painters) : primitives for glass/background/nav/empty states -- enforce perf rules (clipped blur) and parity.
3. `lib/core/navigation/app_nav_shell.dart` (or equivalent) : 5-tab shell -- persistent background + capsule nav + consistent insets.
4. `lib/features/**` screens : composition layer -- reskin incrementally without rewriting services/DAOs.
5. `lib/features/*/controllers/**` : Riverpod state machines -- model download/install persists across navigation.
6. `lib/services/ai/model_manager.dart` + Drift `app_settings` : filesystem + persisted consent -- controller integration point.

### Critical Pitfalls

1. **Unclipped `BackdropFilter` blurs the whole screen** -- enforce “always clip” inside the shared glass primitives and cap blur tokens.
2. **Too many independent blurs in lists** -- use `BackdropGroup`/`BackdropFilter.grouped` or reduce blur usage for repeated tiles.
3. **Blur + Opacity/saveLayer causes visual artifacts** -- avoid `Opacity/AnimatedOpacity` around glass; drive translucency inside the primitive and validate cross-platform.
4. **Hardcoded strings + Swedish diacritics regress during pixel work** -- add CI guardrails (literal-string scan + known-bad spellings) and require ARB-first.
5. **Navigation regressions from custom capsule shell** -- define tab contract + inset helper; test back behavior and state retention.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Foundations & Guardrails
**Rationale:** Prevent the two easiest-to-ship regressions (strings/diacritics, golden instability) before screen work begins.
**Delivers:** Token scaffolding, l10n workflow gates, golden harness baseline.
**Addresses:** localization + copy fixes; UI drift prevention.
**Avoids:** hardcoded strings; Swedish diacritics regressions.

### Phase 2: Shared Primitives + Perf Baseline
**Rationale:** Pixel parity and performance depend on primitives (glass/background) being correct and reusable.
**Delivers:** `NatureBackground`, glass surfaces/boards/backplates, blur tokens, motion tokens; clipped + grouped blur patterns validated in DevTools.
**Addresses:** tokens + theme consistency; glass primitives; atmosphere backgrounds.
**Avoids:** unclipped blur; many independent blurs; saveLayer/opacity artifacts; visual-spec drift.

### Phase 3: Navigation Shell Swap (Capsule Nav)
**Rationale:** Navigation is cross-cutting; screens must be built against the final shell (persistent background + insets).
**Delivers:** Capsule nav + `IndexedStack` shell, explicit tab contract, shared inset helper to avoid overlap.
**Addresses:** capsule navigation shell (5 tabs), persistent background.
**Avoids:** tabs changing unintentionally; content hidden behind capsule nav.

### Phase 4: Startup + Auth (Screens 1-5)
**Rationale:** Startup flow is the acceptance gate and drives model-consent UX; doing it early validates the new primitives in “real” flows.
**Delivers:** Onboarding 1-3 + Login 4-5 visuals/copy, signup-first OTP flow, “Problem att logga in?” sheet, “Varfor?” sheet wiring.
**Addresses:** startup flow; auth UX; localization requirements.
**Avoids:** offline-first breaks (startup must be non-blocking); copy drift.

### Phase 5: Model Download & AI UX (Consent-Gated)
**Rationale:** This is the most failure-prone integration (long-running work, progress honesty, background continuation) and must be centralized.
**Delivers:** Single controller-owned state machine; consent flag persisted; real download progress (only when measurable), retry, completion popup; shared status surfaces (Onboarding/Dashboard/Settings) render the same state.
**Addresses:** onboarding #3 callout; consent gating; progress + retry; completion popup; settings AI module status.
**Avoids:** auto-download regressions; fake progress; download cancel on navigation; partial/corrupt file treated as installed.

### Phase 6: Screen Reskins + Release Hardening
**Rationale:** Once primitives/shell/startup/model UX are stable, remaining screens can be converted quickly and verified.
**Delivers:** Home, Current Haul, History empty, Draft editor, Profile/Settings parity; goldens for primitives + key screens; inset coverage on representative devices.
**Addresses:** the referenced 5 core tabs; UI drift prevention.
**Avoids:** offline-first regressions; visual drift; nav overlap edge cases.

### Phase Ordering Rationale

- Guardrails first because they prevent irreversible “cleanup debt” (hardcoded strings and unstable goldens).
- Primitives before screens to keep all “numbers” in tokens and to enforce blur/perf rules once.
- Shell before reskins so padding/insets and tab contract are stable and testable.
- Model download centralized as a controller/service integration to ensure consent gating and background continuation across onboarding/dashboard/settings.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 5 (Model Download & AI UX):** integrity/verification approach (hash/size vs installer verification), background-resume expectations, and failure recovery UX details.
- **Phase 6 (Release Hardening):** scanner overlay compositing (platform-view/camera blur constraints) and cross-device inset coverage strategy.

Phases with standard patterns (skip research-phase):
- **Phase 1-3:** tokens + `ThemeExtension`, `gen_l10n` gates, goldens, and a custom tab shell are well-documented and already aligned to repo conventions.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Direct Flutter docs/API + matches existing repo constraints (pinned Flutter, offline-first, goldens). |
| Features | HIGH | Derived from project’s handoff + reference pack (contract-driven, not speculative). |
| Architecture | HIGH | Aligns with existing feature-first/Riverpod/Drift layering; minimizes churn and regression risk. |
| Pitfalls | MEDIUM | Mostly confirmed by Flutter blur/nav/i18n behaviors; some items (platform-view blur, model integrity strategy) require validation on target devices. |

**Overall confidence:** HIGH

### Gaps to Address

- Platform-view/camera overlay effects: confirm scanner overlay design avoids relying on backdrop blur over camera on both iOS/Android.
- Model integrity verification: decide whether to implement hash/size checks (if a trusted manifest exists) vs relying on installer success + cleanup/atomic rename.
- CI enforcement level: choose between a simple string-literal scan vs analyzer-based enforcement (`custom_lint`) for “no hardcoded UI strings.”

## Sources

### Primary (HIGH confidence)
- `docs/LoppisFynd_Nature_Distilled_Technical_Handoff_v2.md` -- required primitives, startup/auth/model UX requirements.
- `docs/UiUxOverHaul/Technical_Handoff_Patch_v2.md` -- v2 deltas (copy fixes, new primitives, consent gating).
- `docs/LoppisFynd_Nature_Distilled_Visual_Reference_Pack.pdf` -- pixel parity contract.
- Flutter docs: https://docs.flutter.dev/ui/internationalization -- `gen_l10n` quality gates and ARB workflow.
- Flutter API: https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html -- golden testing primitives and update flow.
- Flutter API: https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html -- clip scope, performance notes, `BackdropGroup`/grouped usage.
- Flutter docs: https://docs.flutter.dev/perf/ui-performance -- `saveLayer` performance traps relevant to blur/opacity/clipping.

### Secondary (MEDIUM confidence)
- Context7: `/llmstxt/flutter_dev_llms_txt` -- consolidated Flutter testing/i18n references.
- Flutter API: https://api.flutter.dev/flutter/widgets/PopScope-class.html -- back gesture handling considerations for custom shells.

---
*Research completed: 2026-02-18*
*Ready for roadmap: yes*
