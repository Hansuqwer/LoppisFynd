# Pitfalls Research

**Domain:** Flutter UI overhaul with strict visual spec (glass/blur), offline-first, Swedish localization
**Researched:** 2026-02-18
**Confidence:** MEDIUM

## Critical Pitfalls

### Pitfall 1: Unclipped blur blurs the whole screen

**What goes wrong:**
Glass cards/nav use `BackdropFilter` without a clip, so the blur expands to the nearest ancestor clip (often none) and effectively blurs the entire screen. Frame time spikes, scroll jank, and battery drain follow.

**Why it happens:**
`BackdropFilter` applies to "all the area within its parent or ancestor widget's clip"; when developers rely on rounded corners without explicitly clipping, the engine may blur far more pixels than intended.

**How to avoid:**
- Enforce a rule: every `BackdropFilter` must be wrapped in a clip that matches the intended region (`ClipRect`/`ClipRRect`).
- Put blur tokens in one place (e.g. `AppBlur`) and cap sigma values so designers don't "turn it up" per-screen.

**Warning signs:**
- FPS drops when any glass surface is visible, even if the glass region is small.
- DevTools shows raster/GPU time rising with screen size rather than glass size.

**Phase to address:**
Phase 2 (Shared Primitives + Perf Baseline)

---

### Pitfall 2: Too many independent blurs in lists

**What goes wrong:**
History/haul/drafts lists render each row as its own blurred surface; scrolling becomes expensive because each row triggers a separate backdrop blur.

**Why it happens:**
The design language encourages repeated glass tiles. Naively implementing each tile with its own `BackdropFilter` multiplies cost.

**How to avoid:**
- For repeated blurs (list rows), group backdrop filters using `BackdropGroup`/`BackdropFilter.grouped` so the engine can combine operations.
- Prefer non-backdrop effects where possible: use translucency + border + shadow, and reserve blur for hero surfaces.

**Warning signs:**
- Performance is fine on static screens but tanks on scroll.
- Disabling blur makes scrolling instantly smooth.

**Phase to address:**
Phase 2 (Shared Primitives + Perf Baseline)

---

### Pitfall 3: Blur + Opacity/saveLayer produces "wrong" glass

**What goes wrong:**
Glass surfaces look washed out, double-blended, or inconsistent across screens, especially when wrapped in `Opacity` or other widgets that create temporary buffers.

**Why it happens:**
`BackdropFilter` blending interacts with save layers; default `BlendMode.srcOver` is safest cross-platform but can look surprising in these compositions.

**How to avoid:**
- Avoid wrapping glass in `Opacity`/`AnimatedOpacity`; drive translucency via colors/gradients inside the glass widget.
- If a save layer is unavoidable, validate blend mode behavior (consider `BlendMode.src` for affected compositions, but test on both iOS/Android).

**Warning signs:**
- Glass looks correct on one screen but wrong on another with identical tokens.
- Visual differences between debug/release or between iOS/Android.

**Phase to address:**
Phase 2 (Shared Primitives + Perf Baseline)

---

### Pitfall 4: Platform-view/camera content doesn't blur as expected

**What goes wrong:**
Trying to blur the scanner camera preview (or other platform views) either fails visually, flickers, or performs poorly.

**Why it happens:**
Backdrop blurs have platform restrictions around certain underlying surfaces (especially with iOS platform views).

**How to avoid:**
- Don't design-critical blur over the camera preview; use scrims/gradients and translucent panels that don't depend on backdrop sampling.
- If blur is required, validate against Flutter's platform-view blur guidance early.

**Warning signs:**
- Blur works on Android but not iOS (or vice versa).
- Camera overlay compositing artifacts.

**Phase to address:**
Phase 4 (Screen-by-Screen Rewrite) for scanner overlay decisions, with a perf spike check in Phase 6

---

### Pitfall 5: Hardcoded strings creep in during "pixel-perfect" work

**What goes wrong:**
Screens ship with literal strings in widgets (or partially localized UI like button labels). This violates the non-negotiable "no hardcoded UI strings" requirement and makes later copy fixes painful.

**Why it happens:**
UI work is faster with literals, especially when copying from PDFs. Later cleanup is usually incomplete.

**How to avoid:**
- Make it impossible to miss: add a CI check that fails on common literal patterns in `lib/` (e.g. `Text('`, `labelText: '`, `SnackBar(content: Text('`) with an allowlist for debug-only strings.
- Require all new UI strings to be added to ARB first, then used via `AppLocalizations`.

**Warning signs:**
- PRs include quotes around Swedish/English UI copy.
- Copy tweaks require code changes instead of ARB edits.

**Phase to address:**
Phase 1 (Foundations & Guardrails)

---

### Pitfall 6: Swedish diacritics regress (Valkommen/Anvandarnamn/etc.)

**What goes wrong:**
User-facing copy loses `åäö` (or ships with known typos from the reference pack), harming credibility and violating the non-negotiable "Swedish diacritics correct" requirement.

**Why it happens:**
Strings copied from older handoff code, filenames/assets, or quick typing during UI edits. Also easy to miss in review if the reviewer's editor font makes diacritics subtle.

**How to avoid:**
- Treat the patch doc's search/replace list as mandatory acceptance criteria.
- Add a lightweight "Swedish sanity" check in CI for known bad tokens (e.g. `Valkommen`, `Anvandarnamn`, `Losenord`, etc.).
- Verify custom fonts render Swedish glyphs for every text style used in production.

**Warning signs:**
- ARB contains ASCII-only Swedish.
- Screenshots show missing diacritics or tofu glyphs.

**Phase to address:**
Phase 1 (Foundations & Guardrails)

---

### Pitfall 7: Tabs "change" unintentionally during nav shell swap

**What goes wrong:**
Replacing the nav shell breaks the existing tab contract: order/meaning changes, tab state resets unexpectedly, back button behavior changes, or deep links land on the wrong screen. This violates "Tabs remain unchanged."

**Why it happens:**
Custom capsule nav + `IndexedStack` requires manually recreating behaviors that Material `NavigationBar` previously handled.

**How to avoid:**
- Write down a nav contract (tab order, initial tab, reselection behavior, back behavior per tab, how scanner is reached).
- Keep each tab's root in an `IndexedStack` (as specified) to preserve state.
- Add explicit back-gesture handling for nested navigators/screens using `PopScope`/`NavigatorPopHandler` (especially for Android predictive/system back).

**Warning signs:**
- Switching tabs resets scroll position or form state.
- Android back gesture exits the app unexpectedly or pops within the wrong navigator.

**Phase to address:**
Phase 3 (Navigation Shell Swap)

---

### Pitfall 8: Content gets hidden behind the capsule nav

**What goes wrong:**
Pages look correct in isolation but the bottom capsule overlaps scroll/content (especially on devices with larger bottom insets), making actions unreachable.

**Why it happens:**
Capsule nav is overlaid (Stack/Align), so screens must reserve bottom padding manually; relying on `Scaffold.bottomNavigationBar` behaviors no longer applies.

**How to avoid:**
- Define a single "nav height + padding" constant and expose it as an inset helper used by all tab roots.
- Add golden/integration tests on at least one iPhone-style inset and one Android gesture-nav inset.

**Warning signs:**
- Tappable controls near the bottom are partially obscured.
- Visual pack matches on emulator but fails on real device.

**Phase to address:**
Phase 3 (Navigation Shell Swap)

---

### Pitfall 9: Model download starts automatically (consent regression)

**What goes wrong:**
The app downloads the Gemma model on startup when missing (current behavior per handoff) even though v2 requires user-initiated download on onboarding screen 3.

**Why it happens:**
Existing best-effort startup download code is easy to forget, and new UI only adds another trigger.

**How to avoid:**
- Gate model download behind a persisted consent flag (as specified in handoff).
- Ensure there is exactly one entry point that starts downloads (controller/service), and all UI calls it.

**Warning signs:**
- Network activity occurs on first launch without user action.
- Model appears installed even if the user skipped the prompt.

**Phase to address:**
Phase 5 (Model Download & AI UX)

---

### Pitfall 10: "Fake" progress violates trust (download/install UX)

**What goes wrong:**
UI shows percentage that isn't backed by bytes downloaded, or shows an "install progress" percent that's just a timer. This violates "No fake progress."

**Why it happens:**
HTTP responses sometimes don't include `content-length`, and installation often has no measurable progress events.

**How to avoid:**
- Only show percent when total bytes are known; otherwise use an indeterminate progress indicator.
- During install, show an indeterminate "Installerar..." state; never invent a percent.
- Persist and display real state transitions: Not installed -> Downloading(progress or indeterminate) -> Installing(indeterminate) -> Ready/Failed.

**Warning signs:**
- Percent always advances smoothly even on slow networks.
- Percent hits 100% long before the file is ready.

**Phase to address:**
Phase 5 (Model Download & AI UX)

---

### Pitfall 11: Model download cancels when navigating away

**What goes wrong:**
User taps "Ladda ned", then proceeds; download silently stops because the controller/provider is disposed when onboarding is not visible. The spec requires background continuation while the user proceeds.

**Why it happens:**
Common Riverpod patterns use `autoDispose` or tie async work to widget lifetime.

**How to avoid:**
- Run downloads in a long-lived service (not tied to the onboarding page lifecycle).
- If using Riverpod, ensure the provider is not `autoDispose` (or uses `ref.keepAlive()`), and that concurrent calls are serialized.

**Warning signs:**
- Download progress resets when leaving/re-entering onboarding.
- Partial file exists but state returns to "Not installed."

**Phase to address:**
Phase 5 (Model Download & AI UX)

---

### Pitfall 12: Partial/corrupt model file is treated as installed

**What goes wrong:**
Interrupted downloads leave `.partial`/`.download` files; install attempts fail repeatedly or inference crashes, but UI shows "Installed."

**Why it happens:**
Install readiness is inferred from "file exists" instead of a verified install state (or the installer's own registry).

**How to avoid:**
- Use atomic rename for downloads; treat temp files as non-installed.
- Verify install success via the model runtime/installer (or an explicit DB flag only written after successful install).
- On failure, delete temp/corrupt artifacts before retry.

**Warning signs:**
- Repeated install failures without re-downloading.
- "Installed" state but runtime initialization fails.

**Phase to address:**
Phase 5 (Model Download & AI UX)

---

### Pitfall 13: Offline-first promise breaks during UI rewrite

**What goes wrong:**
New screens assume network availability (e.g. model download prompt blocks onboarding, or screens fetch remote data in build). Users in-store lose core functionality.

**Why it happens:**
UI rewrites often start from static/mock content and later wire to services that may be online-only unless guarded.

**How to avoid:**
- Make "offline by default" a UI acceptance criterion: every screen must render a reasonable state without network.
- Keep "price fetch" as the only online-only feature; everything else must read from Drift first.

**Warning signs:**
- Spinners that never resolve when airplane mode is on.
- Startup/onboarding blocked by connectivity.

**Phase to address:**
Phase 4 (Screen-by-Screen Rewrite) + Phase 6 (Release Hardening)

---

### Pitfall 14: Visual-spec drift across screens (tokens bypassed)

**What goes wrong:**
Teams reimplement spacing/radii/colors per screen to "match the PDF," and the UI slowly diverges (inconsistent glass opacity, inconsistent corner radii, mismatched text styles).

**Why it happens:**
Strict visuals create pressure to do one-off tweaks in the closest file rather than adjusting tokens/primitives.

**How to avoid:**
- A single source of truth: tokens + primitives must be the only way to express glass/background/capsule patterns.
- Add goldens for the shared primitives and key reference screens.

**Warning signs:**
- Multiple near-identical "glass card" implementations.
- Token files stop changing but per-screen styling keeps growing.

**Phase to address:**
Phase 2 (Shared Primitives + Perf Baseline)

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Hand-tuned per-screen colors/opacity instead of tokens | Fast visual matching | "Glass drift" and impossible global tweaks | Never |
| `BackdropFilter` everywhere because "glass" | Quick spec compliance | Jank + battery drain + hard-to-fix later | Only for the few hero surfaces; lists must be grouped/minimized |
| Copying Swedish strings directly from PDFs into Dart | Faster iteration | I18n regressions and diacritic bugs | Never |
| Ad-hoc bottom padding values per screen for capsule nav | Screens look right once | Breaks on devices/insets; expensive QA | Only as a temporary spike; replace with shared inset helper in Phase 3 |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| `flutter_gemma` model install | Treat install as a simple file copy | Use the runtime/installer API to install/verify; only mark ready after success |
| Model download over HTTP | Assume `content-length` always exists | Support indeterminate progress when unknown; never fabricate percent |
| Workmanager/background work | Expect OS background execution to be reliable on iOS | Treat background work as best-effort; UX must still be correct when work pauses |
| Supabase OTP login | Copy "magic link" flows but label as "code" | Keep copy/UX aligned with project OTP settings; provide retry + error localization |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Unclipped `BackdropFilter` | Whole-screen blur, GPU spikes | Always clip the blur region | Immediately on mid/low devices |
| Many independent blurs in a scroll | Scroll jank, high raster time | Use `BackdropGroup`/grouped blurs; minimize blur usage | Lists of ~10+ items |
| Blur + saveLayer compositions | Visual artifacts, inconsistent blending | Avoid `Opacity` around glass; validate blend modes | When combining overlays/animations |
| Overusing `ClipRRect` everywhere | Higher GPU cost | Clip only when necessary (blur region); prefer simpler shapes elsewhere | Complex screens with many tiles |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Downloading a large model without integrity checks | Corrupt model causes crashes or undefined behavior | Store and verify expected size/hash (if feasible), or verify via installer success + cleanup temp files |
| Logging model URLs/errors verbosely in release | Leaks internal endpoints/config | Gate verbose logs to debug/dev mode |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Blocking onboarding on model download | Users can't start using the app offline | Allow "Börja" immediately; download continues; surface state later |
| Fake progress bars | Trust breaks; support load increases | Only show measurable progress; otherwise indeterminate |
| Capsule nav has no semantics/labels | Accessibility regressions | Provide `Semantics` labels using localized tab names |

## "Looks Done But Isn't" Checklist

- [ ] **No hardcoded strings:** zero UI literals in `lib/` (except debug/dev-only allowlist) and all new copy in ARB
- [ ] **Swedish diacritics:** known-bad spellings (per patch doc) are absent; custom fonts render `åäö` in all used styles
- [ ] **Tabs unchanged:** tab order + meaning matches prior behavior; state persists across tab switches; Android back gesture behaves correctly
- [ ] **Capsule nav insets:** no content/actions are obscured on iPhone-style and Android gesture-nav insets
- [ ] **Model download honesty:** percent only when `content-length` known; install is indeterminate; state persists across navigation
- [ ] **Consent gating:** model download does not start before user action; consent flag is respected

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Blur perf/jank | MEDIUM | Reduce sigma tokens, remove blur from lists, add grouping, profile again on target devices |
| Localization regressions | LOW | Run string/typo scanners, fix ARB, regenerate l10n, add CI guardrails |
| Navigation regressions | MEDIUM | Reassert nav contract, add integration tests for tab/back flows, fix nested navigator pop handling |
| Model download UX incorrect | MEDIUM | Centralize state machine, ensure progress only from bytes, persist state, add retry/cleanup |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Unclipped blur blurs the whole screen | Phase 2 | DevTools shows blur cost proportional to glass region; no whole-screen GPU spikes |
| Too many independent blurs in lists | Phase 2 | Scroll performance stable on list-heavy screens; grouped blur used where repeated |
| Blur + saveLayer produces wrong glass | Phase 2 | Visual parity across iOS/Android in key reference screens |
| Platform-view/camera blur issues | Phase 4 | Scanner overlay design works on both platforms; no flicker/artifacts |
| Hardcoded strings creep in | Phase 1 | CI fails on new literals; all UI copy comes from `AppLocalizations` |
| Swedish diacritics regress | Phase 1 | CI rejects known bad spellings; manual spot-check screenshots match patch fixes |
| Tabs change during nav shell swap | Phase 3 | Integration test covers tab order/state + back gesture expectations |
| Capsule nav overlaps content | Phase 3 | Golden/integration tests validate safe-area insets; no obscured CTAs |
| Model download starts automatically | Phase 5 | First launch shows no network download until user taps "Ladda ned" |
| Fake progress | Phase 5 | Percent only when measurable; unknown total shows indeterminate |
| Download cancels when navigating away | Phase 5 | Start download on onboarding, navigate away, return: progress continued |
| Partial/corrupt file treated as installed | Phase 5 | Kill app mid-download then relaunch: state is consistent; retry recovers |
| Offline-first breaks during UI rewrite | Phase 4/6 | Airplane mode walkthrough succeeds for all core screens |
| Visual-spec drift across screens | Phase 2/6 | Goldens for primitives + key screens; token-only styling for shared patterns |

## Sources

- `docs/LoppisFynd_Nature_Distilled_Technical_Handoff_v2.md`
- `docs/UiUxOverHaul/Technical_Handoff_Patch_v2.md`
- `docs/LoppisFynd_Nature_Distilled_Visual_Reference_Pack.pdf`
- Flutter API: BackdropFilter (clip scope, cost, grouping) https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html
- Flutter API: PopScope (system back gesture handling) https://api.flutter.dev/flutter/widgets/PopScope-class.html
- Flutter docs: Internationalization (gen_l10n, intl, numbers/currencies) https://docs.flutter.dev/ui/internationalization
- Flutter docs: Impeller (default renderer + perf goals) https://docs.flutter.dev/perf/impeller

---
*Pitfalls research for: Nature Distilled UI overhaul*
*Researched: 2026-02-18*
