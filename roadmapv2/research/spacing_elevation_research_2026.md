# Spacing + Elevation Research Notes (2025-2026)

These notes feed into `roadmapv2/research/spacing_elevation_tokens.md`.

## Sources Checked

- Figma Help Center: Auto layout fundamentals (padding + gap, responsive flows)
  - https://help.figma.com/hc/en-us/articles/360040451373-Apply-layout-grids
- Figma Help Center: Variables (tokens + modes)
  - https://help.figma.com/hc/en-us/articles/15339657135383-Create-and-use-variables
- Atlassian Design System: Spacing (8px base, token scale including 2/4/6/8/12/16/20/24/32/40/48/64/80)
  - https://atlassian.design/foundations/spacing/
- Shopify Polaris (Layout + Cards): proximity/hierarchy via space; avoid overusing dividers; cards ship with consistent padding and radius
  - https://polaris.shopify.com/design/layout
  - https://polaris.shopify.com/components/layout-and-structure/card
- MDN: `box-shadow` supports multiple layered shadows, offsets/blur/spread/color
  - https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/box-shadow
- Josh W. Comeau: cohesive shadow environment, layered shadows, color-matched shadows
  - https://www.joshwcomeau.com/css/designing-shadows/

## Spacing Signals

- Most mature systems still anchor on an 8px base, but permit smaller steps for tight UI (2/4/6).
- They treat spacing as a communication tool (proximity indicates relationship).
- Semantic grouping and hierarchy are preferred over adding divider lines.

## Elevation / Depth Signals

- Single-shadow elevation often looks "cheap"; layered shadows read more natural.
- A consistent "light source angle" (offset ratio) matters more than exact numbers.
- Shadow color should be tuned to the environment (avoid washed-out neutral gray).

## What To Steal For LoppisFynd

- Keep the 4px base grid for implementation sanity, but allow a small set of "optical" exceptions (6px) for tight icon+text pairings.
- Define at least 3 density bands:
  - compact (scanner, dense lists)
  - default (most screens)
  - airy (dashboard hero, onboarding)
- Elevation tokens should be 2-part:
  - drop shadow (external)
  - highlight/stroke (internal or border) to keep glass edges crisp on photos

## Token Implications

- Spacing scale should include: 2, 4, 6, 8, 12, 16, 20, 24, 32, 40, 48, 64.
- Introduce a "gutter" token for screen padding (16px mobile, 24px tablet+).
- Introduce layered shadow recipes per elevation level (2-5 layers) and a "shadow hue" variable (ink-tinted, not pure black).
