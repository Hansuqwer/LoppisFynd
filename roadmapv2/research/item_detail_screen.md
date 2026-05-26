# Item Detail Screen - Nature Distilled

## Purpose

- Present the "evidence" and the financial outcome clearly.
- Make edit, compare, and share actions feel deliberate (not cluttered).

## Layout

```
Stack
  - Photo hero (image)
  - GlassAppBar over hero
  - Content (bento cards)
    - Title + category
    - Price + profit
    - AI evidence (if available)
    - Sold comps list
    - Notes
```

## Components

- Hero image: rounded bottom corners, subtle vignette
- Price block: large numbers (Space Grotesk) with profit badge
- Evidence card: bounding boxes thumbnail + confidence
- Comps: list rows with source + price + link

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- hero overlay: neutral0 tint + scrimOpacity
- primary action: terracotta500
- info accents: mutedTeal
- text: ink0

Typography:
- title: displayMedium
- category: labelLarge
- price: priceLarge
- stats: statMedium/statSmall
- comps meta: bodySmall

## Asset Suggestions (roadmapv2/images)

- Hero fallback (no photo): `roadmapv2/images/vintage_sweaters.png`

## References

- Card best practices (one primary action): https://polaris.shopify.com/components/layout-and-structure/card
