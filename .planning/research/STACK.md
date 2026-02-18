# Stack Research

**Domain:** Flutter UI/UX overhaul (pixel-accurate, offline-first, strict localization, golden tests)
**Researched:** 2026-02-18
**Confidence:** HIGH

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Flutter SDK (stable, pinned) | `stable @ .metadata revision 67323de285b00232883f53b84095eb72be97d35c` | Deterministic rendering + build tooling | Golden tests and text rasterization are sensitive to engine/Skia changes; pinning the exact Flutter revision (as CI already does) reduces golden churn and “works on my machine” failures. |
| Material 3 theming (`ThemeData`, `ColorScheme`) + `ThemeExtension` | SDK | Design tokens + semantic theming | Keep Material 3 plumbing (buttons, text scaling, accessibility), but put Nature Distilled tokens into `core/tokens/` and expose semantic groups via `ThemeExtension` for pixel-accurate, refactor-friendly UI. |
| Flutter localization toolchain (`gen_l10n` + ARB) | SDK | Strict localization (sv/en) with codegen | `l10n.yaml` is already present. Configure `gen_l10n` to require metadata and emit untranslated-message reports to keep “no hardcoded strings” enforceable and Swedish diacritics correct. |
| `flutter_test` golden testing (`matchesGoldenFile`) | SDK | Pixel-accurate regression tests | The SDK matcher supports golden updates via `flutter test --update-goldens` and provides a first-class path to load fonts in `flutter_test_config.dart` for deterministic output. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `google_fonts` | `^6.3.3` (already) | Typography wiring | Keep, but with `GoogleFonts.config.allowRuntimeFetching = false` (already) and vendored fonts in `Assets/fonts/` to preserve offline-first and make goldens stable. |
| `flutter_animate` | `^4.5.2` (already) | Motion primitives | Use for staggered/intentional motion where it matches the handoff; avoid “ambient” animations that create golden instability or perceived fake progress. |
| `integration_test` | SDK | Real-device screenshot/perf tests | Use only for a small set of “hero flows” (tabs, scan, onboarding) and for profiling glassmorphism (profile builds, device farm optional). |
| `intl` | (add explicitly; follow Flutter pin) | ICU message formatting | Recommended by Flutter i18n docs; required for plurals/selects/dates/currencies as UI copy grows. |
| `custom_lint` (optional) | latest (LOW confidence) | Enforce “no hardcoded UI strings” | Only if you want analyzer-enforced rules (e.g., ban `Text('...')` outside tests). Otherwise enforce via code review + targeted tests. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Flutter DevTools (Performance view) | Profile glassmorphism and repaint behavior | Use profile mode on physical devices; watch for raster/GPU red bars and investigate `saveLayer`, clipping, shadows, and large blurs. |
| GitHub Actions CI (existing) | Deterministic build/test | Current CI pins Flutter by reading `.metadata` and runs `dart format`, `flutter analyze`, `flutter test`. Add explicit golden + l10n checks as separate steps (see below). |
| `flutter_test_config.dart` | Test environment normalization | Use it to load app fonts once for all tests and to centralize golden settings (reduces per-test boilerplate and platform-dependent output). |

## Installation

```bash
# Add explicit intl (recommended for gen_l10n workflows)
flutter pub add intl

# Optional: analyzer-enforced “no hardcoded UI strings”
flutter pub add --dev custom_lint
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| SDK golden tests (`matchesGoldenFile`) + small local harness | Third-party golden harness packages | Use a package only if you need large, systematic golden matrices (many devices × themes × locales) and are willing to accept the maintenance surface. (Not recommended as a default for this repo’s “minimal additions” constraint.) |
| `ThemeExtension` + existing `core/tokens/` Dart constants | Token generators from Figma/Style Dictionary | Use generators only if design tokens are expected to change frequently from Figma Variables; otherwise keep tokens in Dart to avoid build complexity and drift. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Runtime font fetching | Breaks offline-first; makes goldens non-deterministic | Vendored fonts (already) + `allowRuntimeFetching = false` (already). |
| `BackdropFilter` without a tight clip | Applies to ancestor clip; if no clip it can blur the full screen and is “relatively expensive” | Wrap with `ClipRect` (or an exact clip) and prefer `ImageFiltered` when you only need to blur a single widget. |
| `Clip.antiAliasWithSaveLayer` / “big opacity groups” | Triggers expensive `saveLayer` usage and can push work to the raster/GPU thread | Prefer simpler clips, apply opacity on leaf widgets, and use `RepaintBoundary` where caching makes sense. |

## Stack Patterns by Variant

**If the design uses glassmorphism heavily (multiple blurred cards in a list):**
- Use `BackdropGroup` + `BackdropFilter.grouped` so the engine can combine multiple backdrop filters into a single rendering operation.
- Constrain blur to the exact area with `ClipRect`.
- Prefer bounded blur (`ImageFilter.blur(bounds: ...)`) for “frosted glass” effects to prevent color bleeding outside the intended region.

**If you need strict localization quality gates (no missing sv strings):**
- In `l10n.yaml`, set `untranslated-messages-file` to a tracked path (e.g. `.dart_tool/untranslated_messages.json`).
- Set `required-resource-attributes: true` so every message has metadata (translator context).
- In CI, run `flutter gen-l10n` and fail if the untranslated-messages JSON is non-empty.

**If you need stable goldens across machines:**
- Always run goldens on one OS in CI (Linux is already used) and keep Flutter pinned.
- Load the exact app fonts once via `flutter_test_config.dart` (SDK guidance) and avoid any network-dependent assets.

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| `flutter_test` goldens | Flutter engine/version | Golden output can change between OSes and between Flutter versions; pin Flutter and generate goldens on the same OS used by CI. |
| `BackdropFilter` blur | Scene composition | Blurs are expensive; avoid accidental full-screen blurs and expensive `saveLayer` patterns when combined with Opacity/clipping. |

## Sources

- Context7: `/llmstxt/flutter_dev_llms_txt` — localization wiring and testing primitives (material app delegates, `matchesGoldenFile` mention)
- https://docs.flutter.dev/ui/internationalization — `gen_l10n` + `l10n.yaml` options (`untranslated-messages-file`, `required-resource-attributes`, `synthetic-package`, etc.)
- https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html — golden creation/update (`flutter test --update-goldens`), font loading, `flutter_test_config.dart`
- https://api.flutter.dev/flutter/material/ThemeExtension-class.html — typed theme extensions for custom token groups
- https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html — performance notes, clipping guidance, `BackdropGroup`/`BackdropFilter.grouped`
- https://api.flutter.dev/flutter/dart-ui/ImageFilter/ImageFilter.blur.html — bounded blur via `bounds` for contained frosted-glass effects
- https://docs.flutter.dev/perf/ui-performance — `saveLayer` cost and how clipping/opacity/shadows can trigger it
- https://docs.flutter.dev/testing/integration-tests — `integration_test` positioning, running on devices/Firebase Test Lab

---
*Stack research for: LoppisFynd UI/UX overhaul*
*Researched: 2026-02-18*
