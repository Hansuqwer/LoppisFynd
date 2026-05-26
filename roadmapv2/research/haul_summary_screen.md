# Haul Summary Screen - Nature Distilled

## Purpose

- A focused analytics view for one haul.

## Layout

```
GlassAppBar: Summary
Scroll
  - KPI row (bento tiles)
  - Category breakdown (simple bars)
  - Top items (ranked list)
```

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- background: neutral0
- charts: terracotta500 + mutedTeal + slate600 (avoid using CTA color for all series)

Typography:
- KPIs: statLarge
- labels: labelMedium
- list: titleMedium + bodySmall

## Motion

- Count-up for KPIs (respect reduced motion).

## Asset Suggestions (roadmapv2/images)

- Background: `roadmapv2/images/generated_image_46bf928f-78a2-47f8-b959-2ace3da2b028.png` (tinted/blurred)

## References

- Mobile dashboard patterns (KPIs + lists): https://www.behance.net/search/projects/mobile%20dashboard
