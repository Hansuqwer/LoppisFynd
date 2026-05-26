# Onboarding Screen - Nature Distilled

## Purpose

- Explain the core flow in < 60 seconds.
- Make key promises explicit: offline-first, cloud AI optional, privacy.

## Layout

3-4 steps max, each a GlassCard with an icon + headline + 1 sentence.

```
Stack
  - Atmospheric background
  - Progress indicator (dots)
  - PageView of step cards
  - Bottom CTA row: Back / Next / Get started
```

## Recommended Steps

1) Scan
- "Scan items fast in the moment"

2) Price comps
- "Optional sold-price comps when online"

3) AI assist
- "Cloud by default; offline quick ID is lightweight (no multi-GB downloads)"

4) Privacy
- "Send crops only" + link to privacy

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- background: neutral0
- step cards: GlassCard (warm tint)
- progress dot active: terracotta500
- progress dot inactive: neutral4

Typography:
- step headline: headlineLarge
- step body: bodyMedium
- CTA: labelLarge

## Motion

- Step transition: horizontal slide; keep parallax minimal.
- Stagger reveal inside each card: icon -> headline -> body (100ms stagger).

## Accessibility

- Avoid long paragraphs.
- Provide "Skip" (top-right) with clear label.

## Asset Suggestions (roadmapv2/images)

- Background: `roadmapv2/images/loppis_background.png`
- Optional step visuals: `roadmapv2/images/vintage_sweaters.png`, `roadmapv2/images/furniture_items.png`

## References

- Behance search (onboarding UI): https://www.behance.net/search/projects/onboarding%20app
- Figma auto layout (cards + spacing): https://help.figma.com/hc/articles/360040451373
