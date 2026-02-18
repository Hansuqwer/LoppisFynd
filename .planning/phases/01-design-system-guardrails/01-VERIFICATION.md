---
phase: 01-design-system-guardrails
verified: 2026-02-18T13:25:18Z
status: gaps_found
score: 3/4 must-haves verified
gaps:
  - truth: "Nature Distilled surfaces share consistent spacing/radius/typography/blur because screens derive styling from tokens (not ad-hoc widget constants)."
    status: partial
    reason: "A Phase 1 shared primitive still contains ad-hoc design constants; custom_lint flags it in guardrail scope."
    artifacts:
      - path: lib/shared/widgets/logo_motif_overlay.dart
        issue: "Contains BoxShadow blur/offset/spread numeric literals; `flutter pub run custom_lint` reports 3 `no_ad_hoc_design_constants` findings."
    missing:
      - "Replace the ad-hoc BoxShadow constants with tokenized shadows (e.g., AppShadows.*) or explicitly allowlist/suppress with a documented reason."
      - "Ensure `flutter pub run custom_lint` completes cleanly in CI (no findings in Phase 1 primitives)."

human_verification:
  - test: "Glass blur performance/motion sanity"
    expected: "Glass surfaces (GlassSurface/GlassOverlay/CapsuleNavBar) blur only within bounds and look correct during scroll/animations on a physical device."
    why_human: "Perceptual performance and motion artifacts cannot be verified via static code checks."
    result: "approved"
    recorded_in: ".planning/phases/01-design-system-guardrails/01-05-SUMMARY.md"
---

# Phase 1: Design System + Guardrails Verification Report

**Phase Goal:** Users experience a consistent Nature Distilled visual language driven by tokens and reusable, performance-safe primitives (clipped blur), with localized copy conventions enforced.
**Verified:** 2026-02-18T09:09:18Z
**Status:** gaps_found
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths (Success Criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Nature Distilled surfaces share consistent spacing/radius/typography/blur because screens derive styling from tokens (not ad-hoc widget constants). | ✗ PARTIAL | `flutter pub run custom_lint` reports `no_ad_hoc_design_constants` findings in `lib/shared/widgets/logo_motif_overlay.dart`; primitives are not fully token-driven yet. |
| 2 | Any glass/blur surface is clipped to its bounds (no full-screen backdrop blur), and it looks correct in motion on-device. | ✓ VERIFIED | Code-level: all `BackdropFilter` usage is inside shared widgets and wrapped by `ClipRRect` (`lib/shared/widgets/glass_surface.dart`, `lib/shared/widgets/glass_overlay.dart`, `lib/shared/widgets/capsule_nav_bar.dart`). On-device motion/perf sanity approved (01-05). |
| 3 | Swedish UI copy in the updated surfaces ships with correct spelling and diacritics (å, ä, ö), and known reference-pack placeholders/typos are not shipped. | ✓ VERIFIED | `lib/l10n/app_sv.arb` contains corrected copy (e.g. `historyViewBoth: "Båda"`, `onboardingWelcomeBody` includes "sålddata", `haulTitle: "Pågående fynd"`). |
| 4 | Handwritten accent typography is used only for brand accents (never for buttons, forms, or long paragraphs). | ✓ VERIFIED | `Homemade Apple` appears only as `AppTypography.accentFontFamily` in `lib/core/tokens/app_typography.dart`; no other occurrences in `lib/`. |

**Score:** 3/4 truths verified

### Required Artifacts (Existence + Substance + Wiring)

| Artifact | Expected | Status | Details |
|---------|----------|--------|---------|
| `lib/core/tokens/app_blur.dart` | Blur sigma tokens | ✓ VERIFIED | Exists; used by `GlassSurface`/`GlassOverlay`/`CapsuleNavBar` via `AppBlur.*`. |
| `lib/core/tokens/app_opacity.dart` | Opacity tokens for glass/motif/nav | ✓ VERIFIED | Exists; used by `GlassSurface`/`GlassBoard`/`CapsuleNavBar` via `AppOpacity.*`. |
| `lib/core/tokens/app_radius.dart` | Contract radii incl. board/capsule | ✓ VERIFIED | Exists; used across theme + shared widgets via `AppRadius.*`. |
| `lib/core/theme/app_theme.dart` | ThemeData wiring uses tokens | ✓ VERIFIED | Imports `lib/core/tokens/app_tokens.dart`; app uses it in `lib/main.dart` as the MaterialApp theme. |
| `lib/shared/widgets/glass_surface.dart` | Canonical clipped glass container | ✓ VERIFIED | `ClipRRect` wraps `BackdropFilter`; token-driven params/defaults. |
| `lib/shared/widgets/glass_board.dart` | GlassBoard + StackedBackplates | ⚠️ ORPHANED | Exists and composes `GlassSurface`; not referenced outside its own file yet. |
| `lib/shared/widgets/capsule_nav_bar.dart` | Capsule nav with clipped blur | ✓ VERIFIED | Used by `lib/core/navigation/app_nav_shell.dart`. |
| `lib/shared/widgets/logo_motif_overlay.dart` | Motif overlay primitive | ✓ VERIFIED (but linted) | Used by `lib/features/auth/login_motif_layer.dart`; currently triggers `no_ad_hoc_design_constants` findings. |
| `lib/shared/widgets/nature_background.dart` | Contract-named background entrypoint | ⚠️ ORPHANED | Exists as a wrapper over `AtmosphericBackground`; not referenced elsewhere yet. |
| `packages/fynd_loppis_lints/` | Custom lint plugin | ✓ VERIFIED | Plugin exists and runs; configured via app `dev_dependencies` + analyzer plugin. |
| `analysis_options.yaml` | Enables custom_lint | ✓ VERIFIED | Contains `analyzer.plugins: - custom_lint`. |
| `lib/l10n/app_sv.arb` | Swedish ARB strings | ✓ VERIFIED | Contains corrected Swedish copy and required keys; app reads via `AppLocalizations`. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `lib/core/tokens/app_tokens.dart` | `lib/core/tokens/app_blur.dart` | export barrel | ✓ WIRED | `export 'app_blur.dart';` present. |
| `lib/core/tokens/app_tokens.dart` | `lib/core/tokens/app_opacity.dart` | export barrel | ✓ WIRED | `export 'app_opacity.dart';` present. |
| `lib/core/theme/app_theme.dart` | `lib/core/tokens/app_tokens.dart` | imports | ✓ WIRED | `import '../tokens/app_tokens.dart';` present. |
| `lib/shared/widgets/glass_surface.dart` | `lib/core/tokens/app_tokens.dart` | imports | ✓ WIRED | `import '../../core/tokens/app_tokens.dart';` present. |
| `lib/shared/widgets/glass_surface.dart` | `BackdropFilter` | clipped usage | ✓ WIRED | `ClipRRect(... BackdropFilter(...))` present. |
| `analysis_options.yaml` | `custom_lint` | analyzer plugins | ✓ WIRED | `analyzer.plugins` includes `custom_lint`. |
| `pubspec.yaml` | `packages/fynd_loppis_lints` | path dev_dependency | ✓ WIRED | `fynd_loppis_lints: path: packages/fynd_loppis_lints` present. |

### Requirements Coverage

| Requirement | Source Plan(s) | Description | Status | Evidence |
|------------|----------------|-------------|--------|----------|
| DS-01 | 01-01, 01-02, 01-03 | Token system for colors/spacing/radius/shadows/motion/typography/blur; avoid ad-hoc constants | ✗ PARTIAL | Tokens exist + theme wiring present (`lib/core/tokens/*`, `lib/core/theme/app_theme.dart`), but `custom_lint` flags ad-hoc design constants in `lib/shared/widgets/logo_motif_overlay.dart`. |
| DS-02 | 01-02, 01-03 | Every blur clipped; glass primitives enforce | ✓ SATISFIED | `rg BackdropFilter` finds usage only in shared widgets; each is wrapped in `ClipRRect`. Lint rule `no_raw_backdrop_filter` exists. |
| DS-03 | 01-02 | Reusable primitives exist (NatureBackground, LogoMotifOverlay, GlassSurface, GlassBoard, StackedBackplates, CapsuleNavBar) | ✓ SATISFIED | All primitives exist at the specified paths; CapsuleNavBar is used in app shell; LogoMotifOverlay is used in login motif layer. |
| L10N-01 | 01-03 | No new hardcoded user-facing UI strings; AppLocalizations-only | ✓ SATISFIED | `analysis_options.yaml` enables `custom_lint`; rule `no_hardcoded_ui_strings` exists and runs; key touched UI entrypoints use `AppLocalizations` (e.g. `lib/main.dart`). |
| L10N-02 | 01-03 | Swedish copy correct; known typos/placeholders fixed | ✓ SATISFIED | `lib/l10n/app_sv.arb` includes corrected diacritics/strings (e.g., "Båda", "sålddata", "Pågående fynd"). |
| L10N-03 | 01-01, 01-03 | Handwritten font accent-only | ✓ SATISFIED | `Homemade Apple` declared only in `lib/core/tokens/app_typography.dart`; no other occurrences in `lib/`. |

### Anti-Patterns Found

| File | Pattern | Severity | Impact |
|------|---------|----------|--------|
| `lib/shared/widgets/logo_motif_overlay.dart` | Ad-hoc BoxShadow numeric literals flagged by `no_ad_hoc_design_constants` | 🛑 Blocker | Prevents DS-01 from being fully satisfied and breaks “primitives are lint-clean” guardrail expectation. |

### Human Verification Required

### 1. Glass Blur Performance/Motion Sanity

**Test:** Run on a physical device; navigate between tabs and scroll while `CapsuleNavBar` and at least one glass surface are visible.
**Expected:** Blur stays clipped to bounds; no visible full-screen blur, no jank spikes, and no edge artifacts during animation.
**Result:** Approved (01-05).
**Why human:** Performance/visual artifacts are device-dependent and not statically verifiable.

### Gaps Summary

Guardrails and primitives largely exist and are wired (tokens, theme, clipped blur, CI `custom_lint`, and localized copy updates). However, DS-01 is not fully achieved because a Phase 1 shared primitive (`LogoMotifOverlay`) still contains ad-hoc design constants that are actively flagged by the project guardrail lint.

---

_Verified: 2026-02-18T09:09:18Z_
_Verifier: Claude (gsd-verifier)_
