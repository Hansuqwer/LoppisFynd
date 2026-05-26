# AI & Offline Screen - Nature Distilled

## Purpose

- Provide a clear AI status view and let users control cloud/offline behavior.
- No multi-GB on-device model downloads (moving away from Gemma).
- Keep it out of the normal happy path; reachable from:
  - Dashboard preflight card
  - Settings > AI

## Layout

```
GlassAppBar: AI & Offline
Scroll
  - Status card (Cloud / Offline)
  - Toggles (cloud enabled, send crops only)
  - Offline fallback info (lightweight model, bundled)
  - Explain behavior: auto mode and what happens offline
```

## Components

- Cloud status card:
  - Title: "Cloud AI"
  - Badge: "Online" / "Offline"
  - Subtitle: "Uses cropped photos" (if enabled)
- Offline status card:
  - Title: "Offline quick ID"
  - Badge: "Ready"
  - Subtitle: "Lightweight model for no-network situations"
- Controls:
  - Cloud enabled toggle
  - Send crops only toggle
  - Offline fallback toggle (auto)

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- background: neutral0
- surfaces: GlassCard (warm tint)
- primary action: terracotta500
- success/ready: sage
- warning (cellular): warning token (keep subtle)

Typography:
- title: displayMedium
- section headers: headlineMedium
- progress numbers: statSmall (Space Grotesk)
- helper: bodySmall

## States

- Cloud unavailable: show offline is still available.
- Offline disabled: explain "offline results won't be available".
- Error: show a short reason (network/auth) and a retry.

## Accessibility

- Provide a reduced motion progress state.
- Ensure progress is also readable as text (not color-only).

## Asset Suggestions (roadmapv2/images)

- Background: `roadmapv2/images/loppis_background.png`

## References

- Settings/status patterns: https://www.behance.net/search/projects/app%20settings%20ui
