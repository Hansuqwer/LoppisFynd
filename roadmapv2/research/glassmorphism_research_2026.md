# Glassmorphism Research Notes (2025-2026)

These notes feed into `roadmapv2/research/glassmorphism_components.md`.

## Sources Checked

- MDN: `backdrop-filter` (blur/contrast/saturate apply to what is behind; needs transparency)
  - https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/backdrop-filter
- Glassmorphism generator (common layering recipe: blur + translucent fill + border + multi-shadow + inset highlights)
  - https://glassmorphism.com/
- Hype4 Academy: Glassmorphism overview + origin context
  - https://hype4.academy/articles/design/glassmorphism
- Medium tag portal (signals: accessibility/readability concerns show up repeatedly)
  - https://medium.com/tag/glassmorphism
- Behance search (usage patterns in recent work)
  - https://www.behance.net/search/projects/glassmorphism

## Signals Seen

- Modern "glass" is rarely just blur; it is a stack of:
  - blur (background)
  - translucent fill (material)
  - subtle border/stroke (edge definition)
  - highlight lines / inset glints (top + side)
  - noise/grain (prevents banding, hides artifacts)
- Readability is the failure mode: busy backdrops + low-contrast text = unusable.
- Designs that hold up tend to constrain the background:
  - tint + blur the backdrop
  - keep glass opacity high enough for text

## What To Steal For LoppisFynd

- Treat glass as a system with explicit fallbacks:
  - if blur is disabled/reduced (performance or accessibility), increase fill opacity + add stronger stroke.
- Prefer 2-3 glass layers visible at once.
- Add a tiny noise overlay as part of the glass surface (very low opacity) to reduce "cheap" gradients.

## Token Implications

- Add tokens for:
  - `glassFilter`: blur + (optional) saturate/contrast
  - `glassNoiseOpacity`
  - `glassStrokeOpacity`
  - `glassHighlightOpacity` (top glint)
  - `glassFallbackFillOpacity` (reduce transparency mode)
