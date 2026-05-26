# Login Screen - Nature Distilled

## Purpose

- Let a user sign in quickly (email OTP), with clear privacy + AI messaging.
- Set the tone: tactile, calm, Scandinavian second-hand (warm neutrals + glass + texture).

## Layout

Suggested structure (mobile):

```
Stack
  - Atmospheric background (blur + tint)
  - Logo + brand line
  - GlassCard: sign-in form
  - Footer: privacy / terms
```

## Components

- GlassAppBar (optional): minimal, no back button for first entry.
- Brand header:
  - Logo image
  - Short tagline (1 line)
- Sign-in card:
  - Email field (GlassInput)
  - Primary CTA: "Send code" (GlassButton.primary)
  - OTP entry (inline step or second card)
  - Secondary: "Continue offline" (ghost) if supported
- Trust row:
  - "Cloud AI uses cropped photos" (small, muted)
  - Link to privacy

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color (light):
- background: neutral0/neutral1
- surface: neutral2 + glass (GlassCard)
- text: ink0 (primary), ink1 (secondary)
- primary CTA: terracotta500 (fill), terracotta700 (pressed)
- links: electricBlue (links only)

Typography:
- screen title: displayMedium (Outfit)
- tagline/body: bodyMedium (Outfit)
- field labels: labelMedium (Outfit)
- numeric OTP: statSmall (Space Grotesk)

## Motion

- Page load: fade up + slight blur settle (300-450ms) for the card only.
- OTP step: slide in from bottom, keep background stable.

## States

- Loading: button shows spinner; disable input; show "Sending..." as labelSmall.
- Error: inline error under field; use dopamineRed for destructive/error only.
- Offline: show "Continue offline" and explain limitations in 1 line.

## Accessibility

- Minimum touch targets: 44x44.
- Maintain readable contrast over imagery: increase tint opacity if needed.
- Provide reduced transparency fallback: higher fill opacity, lower blur.

## Asset Suggestions (roadmapv2/images)

- Background: `roadmapv2/images/antique_store.png` or `roadmapv2/images/loppis_background.png`
- Logo: `roadmapv2/images/logo.jpg`

## References

- Behance search (login UI patterns): https://www.behance.net/search/projects/login%20ui
- Glass layering patterns: https://glassmorphism.com/
