# Auth Gate Screen - Nature Distilled

## Purpose

- Decide what the user sees first:
  - Logged out: `roadmapv2/research/login_screen.md`
  - Logged in: dashboard
- Make transitions feel intentional (no blank flashes).

## UX Rules

- If a cached session exists: show a lightweight "restoring session" gate for < 500ms.
- If session restore takes longer: show a calm branded gate with a single line of status.
- If session restore fails: route to login with a non-alarming inline message.

## Layout

```
Full-screen
  - Atmospheric background (tint + blur)
  - Center: logo + small status line
```

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- background: neutral0 with subtle texture
- text: ink1 (muted)

Typography:
- status: bodySmall

## Motion

- Fade-in (150-250ms)
- Cross-fade to next screen; avoid slide animations to reduce perceived delay.

## Asset Suggestions (roadmapv2/images)

- Background: `roadmapv2/images/loppis_background.png`
- Logo: `roadmapv2/images/logo.jpg`
