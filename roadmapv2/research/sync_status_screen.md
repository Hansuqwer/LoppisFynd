# Sync Status Screen - Nature Distilled

## Purpose

- Give a compact, truthful view of sync state.
- Intended for Dev Mode / troubleshooting.

## Layout

```
GlassAppBar: Sync Status
Column
  - Status summary card (online, signed-in, last sync)
  - Recent sync events (list)
  - Actions (Sync now, Copy diagnostics)
```

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- success: sage
- warning: warning token
- error: dopamineRed
- neutral text: ink0/ink1

Typography:
- headline: headlineMedium
- status value: statMedium (Space Grotesk)
- labels: labelMedium

## Notes

- Use icons consistently (cloud, wifi, user, clock).

## Asset Suggestions (roadmapv2/images)

- Background: `roadmapv2/images/ref2.jpg` (very subtle) or `roadmapv2/images/loppis_background.png`

## References

- Dev-mode diagnostics pattern inspiration: https://www.behance.net/search/projects/system%20status%20screen
