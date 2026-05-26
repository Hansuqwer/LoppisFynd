# Color Palette Tokens - Nature Distilled

## Old Palette (Current)

| Token | Hex | Usage |
|-------|-----|-------|
| cloudDancer | #F0EEE9 | background |
| clay | #E8E4DE | surface |
| deepSapphire | #1E2B3C | text / ink |
| eucalyptus | #8AA399 | success |
| terracottaClay | #CB8573 | accent |
| copperOak | #935233 | textWarm |
| atmosphericFog | #5B6C8F | fog |
| dopamineRed | #FF3131 | primaryAction |
| neonPink | #FF1493 | highlight |
| electricBlue | #00E5FF | activeVoiceGps |

---

## New Palette - Light Mode

| Token | Hex | Role |
|-------|-----|------|
| cream | #F3EEE6 | background |
| warmIvory | #F3EEDC | surface / overlay tint |
| sage | #7A9B76 | success / secondary |
| mutedTeal | #5A8C88 | info / tertiary |
| terracotta | #C58A73 | primaryCTA / accent |
| dustyRose | #B77B87 | highlight |
| grayGreen | #4E5C56 | text / ink |

### Semantic Tokens (Light)

| Token | Value | Usage |
|-------|-------|-------|
| background | cream | app background |
| surface | warmIvory | cards, dialogs |
| textPrimary | grayGreen | headings, body |
| textSecondary | grayGreen.72 | captions |
| textMuted | grayGreen.54 | hints |
| primaryAction | terracotta | buttons, CTAs |
| accent | terracotta | accents |
| success | sage | positive states |
| error | #FF3131 | errors |
| warning | #E8A84C | warnings |
| info | mutedTeal | informational |
| link | #00E5FF | links (keep electric blue) |

---

## Dark Mode

| Token | Hex | Role |
|-------|-----|------|
| charcoal | #121212 | background |
| deepCharcoal | #1A1A1A | surface |
| slate | #2D3436 | elevated surfaces |
| warmCharcoal | #1E1C1B | warm-tinted surface |

| Token | Hex | Role |
|-------|-----|------|
| softCream | #F5F0E6 | text on dark |
| mutedSage | #9BB89F | success |
| softTerracotta | #D9A08E | primaryCTA |
| mutedDustyRose | #C9959A | highlight |
| lightGrayGreen | #8BA39D | info |

### Semantic Tokens (Dark)

| Token | Value | Usage |
|-------|-------|-------|
| background | charcoal | app background |
| surface | deepCharcoal | cards, dialogs |
| surfaceElevated | slate | modals, bottom sheets |
| textPrimary | softCream | headings, body |
| textSecondary | softCream.72 | captions |
| textMuted | softCream.54 | hints |
| primaryAction | softTerracotta | buttons, CTAs |
| accent | softTerracotta | accents |
| success | mutedSage | positive states |
| error | #FF6B6B | errors |
| warning | #F5C842 | warnings |
| info | lightGrayGreen | informational |
| link | #64B5F6 | links |

---

## Dark Mode Reference Palette (Night Teal)

We have a visual reference palette image (night landscape + swatches) intended specifically for dark mode.

How it maps to our tokens:

- Swatch 1 (off-white) -> `softCream` (text on dark)
- Swatch 2 (cool gray) -> `slate` (secondary surfaces)
- Swatch 3 (blue-gray) -> use as an optional deep accent (charts, dividers) aligned with `slate600`
- Swatch 4 (deep teal) -> use as the "cool counterweight" accent (focus rings, info accents)
- Swatch 5 (near-black) -> `charcoal` / `deepCharcoal` (background + surface)

Rules:

- Use this palette only for dark mode; do not replace the warm Nature Distilled light palette.
- Keep CTAs terracotta (softTerracotta) even in dark mode; the night-teal accents are supporting color, not the primary action color.

---

## Keep from Old Palette (Specific States Only)

- `dopamineRed` / `error` - destructive actions, validation errors
- `electricBlue` / `link` - URLs, interactive links
- `neonPink` / `alertProfit` - profit highlights, special alerts
- `atmosphericFog` - legacy charts/graphs (if needed)

---

## Migration Mapping

| Old Token | New Token | Notes |
|-----------|-----------|-------|
| cloudDancer | cream | background |
| clay | warmIvory | surface |
| deepSapphire | grayGreen | text/ink |
| eucalyptus | sage | success |
| terracottaClay | terracotta | accent |
| copperOak | textWarm | (keep as-is) |
| dopamineRed | error | keep red for errors |
| neonPink | dustyRose | highlight |
| electricBlue | link | keep blue for links |

---

## Trend-Informed Improvements (Palette v2)

Notes from current palette trend scan: `roadmapv2/research/color_trends_2026.md`

### Why v2

- v1 is directionally right (warm neutrals + terracotta + sage), but it needs ramps for real UI states.
- Current palette trends (Figma/Behance) strongly favor: warm neutrals + one cool counterweight + a real dark anchor.

### Add Ramps (Keep Names, Add Steps)

#### Neutrals

| Token | Hex | Usage |
|------|-----|-------|
| neutral0 | #FAF6EF | background alt |
| neutral1 | #F3EEE6 | cream |
| neutral2 | #F3EEDC | warmIvory |
| neutral3 | #E9E0D3 | surface alt |
| neutral4 | #D7CFC3 | borders on light |

#### Ink (missing in v1)

| Token | Hex | Usage |
|------|-----|-------|
| ink0 | #2F3A34 | primary text/icons |
| ink1 | #4E5C56 | secondary text |
| ink2 | #6E7C75 | muted text |

#### Terracotta

| Token | Hex | Usage |
|------|-----|-------|
| terracotta50 | #F7E4DD | subtle tints |
| terracotta200 | #E4A499 | warm highlight |
| terracotta400 | #D9A08E | hover/pressed tint |
| terracotta500 | #C58A73 | brand base |
| terracotta700 | #935233 | pressed/selected, textWarm |
| terracotta900 | #5A2F25 | deep accents |

#### Cool Counterweight

| Token | Hex | Usage |
|------|-----|-------|
| teal300 | #AFE0E7 | subtle info surfaces |
| mutedTeal | #5A8C88 | info accent |
| slate600 | #304C53 | deep UI accents |

### Practical Rules

- Backgrounds: `neutral0–neutral2`
- Surfaces/cards: `neutral2–neutral3` (then add glass/texture)
- Text/icons: prefer `ink0` (not `grayGreen`) to keep contrast crisp
- CTA fills: `terracotta500`, pressed/selected `terracotta700`
- Links: keep `electricBlue` but make it rare (links only)
