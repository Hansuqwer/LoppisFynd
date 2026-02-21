# Deep Link Gate Screen - Nature Distilled

## Purpose

- Handle deep links safely and visibly:
  - show a brief resolving state
  - route to the correct destination
  - recover gracefully when the link is invalid or requires login

## UX Rules

- Always show a visible "Resolving link..." gate if resolution takes > 150ms.
- If auth is required: route to login and keep the intent (continue after login).
- If link is invalid: show a simple error with a "Go to Dashboard" CTA.

## Layout

```
Full-screen glass card
  - Title: "Opening..."
  - One-line detail (domain/feature)
  - Optional: secondary action (Cancel)
```

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- background: neutral0
- surface: GlassCard (warm tint)
- text: ink0/ink1

Typography:
- title: headlineMedium
- detail: bodySmall
- CTA: labelLarge

## Asset Suggestions (roadmapv2/images)

- Background: `roadmapv2/images/ref2.jpg` (very subtle) or `roadmapv2/images/loppis_background.png`
