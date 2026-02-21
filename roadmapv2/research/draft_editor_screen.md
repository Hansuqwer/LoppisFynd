# Draft Editor Screen - Nature Distilled

## Purpose

- Edit a draft item without losing momentum.

## Layout

```
GlassAppBar: Edit draft
Scroll
  - Photo header
  - Title + category
  - Price section (buy -> comps -> profit)
  - Notes
Sticky footer
  - Save / Publish
```

## Components

- Photo header: image with a cream/ink gradient overlay
- Inputs: GlassInput
- Pickers: bottom sheets (GlassBottomSheet)
- Price metrics: Space Grotesk tokens (priceMedium/statMedium)

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- background: neutral0
- surface sections: GlassCard.bento
- primary: terracotta500
- success/profit: sage
- loss highlight: dustyRose

Typography:
- section headers: headlineMedium
- field labels: labelMedium
- body: bodyMedium
- prices: priceMedium (Space Grotesk)

## Motion

- Sticky footer appears after first scroll (fade in).

## Asset Suggestions (roadmapv2/images)

- Background: `roadmapv2/images/furniture_items.png` (heavily tinted/blurred)

## References

- Form layout with bottom actions: https://www.behance.net/search/projects/mobile%20form%20ui
