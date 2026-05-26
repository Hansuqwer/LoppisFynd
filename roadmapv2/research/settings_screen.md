# Settings Screen - Nature Distilled

## Purpose

- Present user-facing settings cleanly.
- Keep advanced sync controls hidden for normal users; expose only in existing Dev Mode.

## Layout

```
GlassAppBar: Settings
Scroll
  - Account
  - AI
  - Privacy
  - (Dev Mode only) Sync + diagnostics
  - Danger zone
```

## Sections

Account
- Email, sign out

AI
- Cloud AI toggle
- "Send crops only" toggle
- Offline quick ID (lightweight fallback) -> `roadmapv2/research/model_manager_screen.md`

Privacy
- Privacy summary
- Open privacy policy

Dev Mode only
- Sync interval, sync now, background sync status
- Diagnostics (network, last sync)

Danger zone
- Account deletion

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- background: neutral0
- list tiles: GlassCard.tight or GlassSurface.medium
- dividers: avoid heavy lines; use spacing + subtle border (neutral4)
- danger actions: dopamineRed

Typography:
- screen title: displayMedium
- section headers: headlineMedium
- tile title: titleMedium
- tile subtitle: bodySmall

## Interaction

- Use bottom sheets for complex settings (offline model management, sync details).
- Confirm destructive actions with a GlassModal + clear copy.

## Asset Suggestions (roadmapv2/images)

- Background: `roadmapv2/images/loppis_background.png`

## References

- Polaris layout principles (hierarchy via spacing): https://polaris.shopify.com/design/layout
