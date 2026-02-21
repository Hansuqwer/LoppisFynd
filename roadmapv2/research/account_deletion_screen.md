# Account Deletion Screen - Nature Distilled

## Purpose

- Make deletion irreversible and explicit.

## Layout

```
AppBar: Delete account
GlassCard
  - Warning headline
  - What will be deleted
  - Confirm step (type DELETE)
  - Destructive CTA
```

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- warning/danger: dopamineRed
- background: neutral0
- surface: neutral2 (opaque)

Typography:
- headline: headlineLarge
- body: bodyMedium
- destructive button: labelLarge

## Interaction

- Require a deliberate confirmation step (typed phrase or checkbox + delay).

## Asset Suggestions (roadmapv2/images)

- Prefer none (keep user focused). If needed: `roadmapv2/images/loppis_background.png` heavily tinted/blurred.

## References

- Destructive flow patterns: https://www.behance.net/search/projects/delete%20account%20ui
