# Spacing & Elevation Tokens - Nature Distilled

---

## Current System

### Spacing

| Token | Value | Usage |
|-------|-------|-------|
| xxs | 4px | icon gaps, tight spacing |
| xs | 8px | compact elements |
| sm | 12px | default padding |
| md | 16px | card padding |
| lg | 24px | section spacing |
| xl | 32px | screen margins |
| xxl | 40px | large gaps |
| xxxl | 56px | hero spacing |

### Radius

| Token | Value | Usage |
|-------|-------|-------|
| sm | 12px | buttons, inputs |
| md | 16px | cards |
| lg | 24px | modals, sheets |
| pill | 999px | pills, capsules |
| board | 36px | large glass boards |
| capsule | 30px | nav capsules |

### Blur (Glassmorphism)

| Token | Value | Usage |
|-------|-------|-------|
| tileSigma | 10px | small tiles, inputs |
| cardSigma | 16px | standard cards |
| navSigma | 18px | nav capsules |

### Shadows

| Token | Usage |
|-------|-------|
| bento | glass cards, default |
| soft | alias for bento |
| pressed | button pressed state |
| capsuleNav | nav capsule |
| motifOverlay | login motif overlay |

---

## Proposed Expanded System

### Spacing (8pt Grid)

| Token | Value | Usage |
|-------|-------|-------|
| xxxs | 2px | minimal gaps |
| xxs | 4px | icon gaps |
| xs | 8px | tight, compact |
| sm | 12px | default padding |
| md | 16px | card padding |
| lg | 24px | section spacing |
| xl | 32px | screen margins |
| xxl | 40px | large gaps |
| xxxl | 48px | hero spacing |
| xxxxl | 64px | max spacing |

### Spacing Scale (Semantic)

| Token | Value | Usage |
|-------|-------|-------|
| insetXxs | 4px | chip padding |
| insetSm | 8px | button padding |
| insetMd | 12px | card internal |
| insetLg | 16px | modal padding |
| insetXl | 24px | screen padding |

| Token | Value | Usage |
|-------|-------|-------|
| stackXxs | 4px | inline gaps |
| stackSm | 8px | list item gaps |
| stackMd | 12px | section gaps |
| stackLg | 16px | major sections |
| stackXl | 24px | page sections |

---

### Radius (Expanded)

| Token | Value | Usage |
|-------|-------|-------|
| none | 0px | images, overlays |
| xs | 4px | tiny elements |
| sm | 8px | small buttons |
| md | 12px | buttons, inputs |
| lg | 16px | cards |
| xl | 24px | modals, sheets |
| xxl | 32px | large surfaces |
| xxxl | 40px | glass boards |
| full | 999px | pills, avatars |

### Radius Semantic

| Token | Value | Usage |
|-------|-------|-------|
| button | md (12px) | buttons |
| card | lg (16px) | bento cards |
| modal | xl (24px) | dialogs |
| sheet | lg (16px) | bottom sheets |
| avatar | full | circular avatars |
| chip | full | pill chips |

---

### Elevation (Shadows + Blur Combined)

#### Light Mode

| Level | Blur | Offset | Spread | Color | Usage |
|-------|------|--------|--------|-------|-------|
| flat | 0 | 0 | 0 | - | surfaces |
| raised | 8 | (0, 4) | -4 | 8% black | buttons |
| elevated | 16 | (0, 8) | -6 | 10% black | cards |
| floating | 24 | (0, 16) | -8 | 12% black | modals |
| overlay | 40 | (0, 24) | -16 | 16% black | dialogs |

#### Dark Mode

| Level | Blur | Offset | Spread | Color | Usage |
|-------|------|--------|--------|-------|-------|
| flat | 0 | 0 | 0 | - | surfaces |
| raised | 8 | (0, 4) | -4 | 12% white | buttons |
| elevated | 16 | (0, 8) | -6 | 16% white | cards |
| floating | 24 | (0, 16) | -8 | 20% white | modals |
| overlay | 40 | (0, 24) | -16 | 24% white | dialogs |

---

### Glassmorphism Blur Levels

| Token | Sigma | Opacity | Usage |
|-------|-------|---------|-------|
| frosted | 5px | 50% | subtle glass |
| light | 10px | 40% | tiles |
| medium | 16px | 30% | cards |
| heavy | 24px | 25% | nav |
| maximum | 40px | 20% | overlays |

### Glass Surface (Combined)

| Token | Blur | Fill | Stroke | Usage |
|-------|------|------|--------|-------|
| surfaceLight | 10px | 30% white | 10% white | tiles |
| surfaceMedium | 16px | 40% white | 15% white | cards |
| surfaceHeavy | 24px | 50% white | 20% white | nav |
| surfaceDark | 16px | 60% black | 10% black | dark mode |

---

## Atmospheric Background Tokens

| Token | Value | Usage |
|-------|-------|-------|
| backgroundTintOpacity | 0.65 | warm ivory overlay |
| backgroundBlurSigma | 20px | backdrop blur |
| backgroundTintColor | #F3EEDC | warm ivory |
| scrimOpacity | 0.4 | content scrim |

---

## 8pt Grid Reference

```
4  | xxs
8  | xs
12 | sm
16 | md
24 | lg
32 | xl
40 | xxl
48 | xxxl
56 | -
64 | -
```

**Rule:** Prefer multiples of 4px. Allow rare "optical" exceptions (e.g. 6px) for tight icon+text alignment.

---

## Trend-Informed Notes (2025-2026)

Reference notes: `roadmapv2/research/spacing_elevation_research_2026.md`.

- Spacing systems commonly anchor on 8px, but allow 2/4/6 for compact UI (Atlassian tokens).
- Use space to communicate grouping/hierarchy; avoid relying on divider lines (Polaris).
- Elevation looks more natural with layered shadows + consistent "light source" direction (Josh Comeau + MDN multi-shadow).

### Recommended Additions

#### Optical micro-spacing (optional)

| Token | Value | Usage |
|-------|-------|-------|
| optical6 | 6px | icon+text pairs, tight labels |
| optical10 | 10px | rare alignment fixes |

#### Screen gutters

| Token | Value | Usage |
|-------|-------|-------|
| gutterMobile | 16px | default screen padding |
| gutterTablet | 24px | tablet/large phones |

#### Layered shadow recipes (example)

Use 2-5 `BoxShadow`s per elevation level instead of one.

| Level | Shadow layers (concept) |
|-------|--------------------------|
| raised | small + medium layers |
| elevated | medium + large layers |
| floating | 3-5 layers, lower opacity |

---

## Implementation Notes

1. Create `AppSpacing` with 4px base grid
2. Create semantic aliases (`inset*`, `stack*`)
3. Merge blur + shadow into `AppElevation` with light/dark variants
4. Add `AppGlass` with combined blur + fill + stroke tokens
5. Update existing `AppShadows`, `AppRadius`, `AppBlur` to reference new system
6. Consider creating `ThemeData` extension for elevation
