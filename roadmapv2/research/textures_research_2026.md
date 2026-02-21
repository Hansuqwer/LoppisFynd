# Texture Research Notes (2024-2026)

These notes feed into `roadmapv2/research/textures.md`.

## Sources Checked

- Behance: paper texture packs and scanned materials (kraft, folded paper, soft texture packs)
  - https://www.behance.net/search/projects/paper%20texture
- Behance: noise / film grain texture packs (noise, photocopy, grain overlays)
  - https://www.behance.net/search/projects/noise%20texture

## Signals Seen

- "Tactile" design is implemented with overlays more often than full backgrounds.
- Scanned textures are preferred over procedural ones when the goal is authenticity.
- Noise/grain is used to unify composites (photo + blur + gradient) and hide banding.

## What To Steal For LoppisFynd

- Keep full textures for rare moments (splash, onboarding, empty states).
- Use tiny tileable grain everywhere else (glass, surfaces) at very low opacity.
- Make textures monochrome or near-monochrome; let our palette provide color.

## Token Implications

- Add explicit tokens for:
  - `textureOverlayOpacityLow/Med/High`
  - `grainTileSize` (e.g. 256)
  - `grainOpacity` (start at 0.04-0.08)
  - `textureBlendMode` guidance (overlay/softLight/multiply depending on asset)
