# Typography Tokens - Nature Distilled

## Current (Outfit + Space Grotesk + Homemade Apple)

| Token | Font | Size | Weight | Line Height | Letter Spacing |
|-------|------|------|--------|-------------|----------------|
| headlineLarge | Outfit | 32 | 700 | 1.1 | -0.6 |
| headlineSmall | Outfit | 24 | 700 | 1.15 | -0.3 |
| titleLarge | Outfit | 18 | 700 | 1.25 | -0.2 |
| bodyLarge | Outfit | 16 | 500 | 1.45 | - |
| bodyMedium | Outfit | 14 | 500 | 1.45 | - |
| labelLarge | Outfit | 14 | 700 | 1.2 | 0.2 |

### Font Roles

- **Outfit** - UI text (primary)
- **Space Grotesk** - Metrics/numbers/prices
- **Homemade Apple** - Accent branding (logo, hero)

---

## Proposed Typography System

### Font Families (Keep Same)

| Font | Role | Usage |
|------|------|-------|
| Outfit | Primary UI | All interface text |
| Space Grotesk | Metrics | Prices, numbers, stats |
| Homemade Apple | Accent | Brand moments only (sparingly) |

### Semantic Text Styles

| Token | Font | Size | Weight | Line Height | Usage |
|-------|------|------|--------|-------------|-------|
| displayLarge | Outfit | 40 | 700 | 1.1 | Hero headlines |
| displayMedium | Outfit | 32 | 700 | 1.1 | Screen titles |
| headlineLarge | Outfit | 28 | 600 | 1.15 | Section headers |
| headlineMedium | Outfit | 24 | 600 | 1.2 | Card titles |
| titleLarge | Outfit | 20 | 600 | 1.25 | List item titles |
| titleMedium | Outfit | 16 | 500 | 1.3 | Subtitles |
| bodyLarge | Outfit | 16 | 400 | 1.5 | Body text |
| bodyMedium | Outfit | 14 | 400 | 1.5 | Secondary body |
| bodySmall | Outfit | 12 | 400 | 1.4 | Captions |
| labelLarge | Outfit | 14 | 500 | 1.2 | Buttons |
| labelMedium | Outfit | 12 | 500 | 1.1 | Chips, tags |
| labelSmall | Outfit | 10 | 500 | 1.0 | Tiny labels |

### Metrics/Numbers (Space Grotesk)

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| priceLarge | 28 | 600 | Product prices |
| priceMedium | 20 | 500 | List prices |
| priceSmall | 14 | 500 | Small labels |
| statLarge | 32 | 600 | Dashboard stats |
| statMedium | 24 | 500 | Secondary stats |
| statSmall | 16 | 500 | Inline stats |

---

## Trend-Informed Adjustments (2026)

Reference notes: `roadmapv2/research/typography_trends_2026.md`.

- Prefer hierarchy via weight + size (not more font families).
- Keep headlines tight (LH ~1.05-1.15), body comfortable (LH ~1.45-1.6).
- Treat numbers/prices as a distinct system (consistent weight ladder + spacing).

## Variable Fonts (Future)

2027 considerations:
- Outfit Variable (weight axis 100-900): fewer files, more granular control
- Verify rendering parity + performance on low-end devices

### Motion Typography

- Text reveal animations (fade up, character stagger)
- Number counting animations for stats
- Price change animations (green/red flash)

---

## Dark Mode Typography

Same scale, but text colors use `AppColorsDark.textPrimary` (#F5F0E6) instead of grayGreen.

| Token | Light | Dark |
|-------|-------|------|
| textPrimary | grayGreen (#4E5C56) | softCream (#F5F0E6) |
| textSecondary | grayGreen.72 | softCream.72 |
| textMuted | grayGreen.54 | softCream.54 |

---

## Implementation Notes

1. Keep `uiFrom()`, `metricsFrom()`, `accentFrom()` helpers
2. Add `TextStyle` getters for each semantic token
3. Create `AppTypographyDark` with dark colors
4. Consider `GoogleFonts.variable` for Outfit to reduce font files
5. Use `TextTheme.withFontFamily()` to avoid repetition
