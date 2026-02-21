# History Screen - Nature Distilled

## Purpose

- Browse past finds quickly.
- Filters should be fast and low-friction (chips + search).

## Layout

```
GlassAppBar: History
  - Search field (GlassInput)
  - Filter chips row
List
  - Item cards (compact list variant)
```

Optional: map view (pins) as a secondary tab.

## Components

- Filter chips: GlassChip.filter (category, distance, condition, date)
- List rows: ItemCard.compact (see `roadmapv2/research/item_cards.md`)
- Empty state: coffee-cup illustration (existing) on paper texture

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- background: neutral0
- search surface: GlassInput
- chips selected: terracotta50 background + terracotta700 text
- text: ink0/ink1

Typography:
- title: displayMedium
- list title: titleMedium
- meta: bodySmall
- numbers: statSmall (Space Grotesk)

## Motion

- Filter changes: subtle cross-fade of list, no heavy re-layout animations.

## Asset Suggestions (roadmapv2/images)

- Background: `roadmapv2/images/ref1.jpg` or `roadmapv2/images/loppis_background.png`

## References

- Behance search (activity/history lists): https://www.behance.net/search/projects/activity%20feed%20mobile
