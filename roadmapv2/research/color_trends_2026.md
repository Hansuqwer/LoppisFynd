# Color Palette Trends (2025–2026) + What To Steal For Loppisfynd

This is a quick scan of palette patterns showing up across:

- Figma palette collections (neutral / pastel / earthy)
- Behance palette/gradient projects + search scan
- Dribbble color guidance articles

Goal: keep Loppisfynd "Nature Distilled" (cream + terracotta + sage + texture) while aligning with what looks contemporary.

Additional reference notes: `roadmapv2/research/color_trends_behance_2026.md`.

---

## What "Top" Palettes Look Like Right Now

### Trend 1: Warm neutrals + one cool counterweight

Common structure:

- 2–3 warm neutrals (cream/sand/stone)
- 1 earthy anchor (brown/charcoal)
- 1 cool accent (muted teal, steel blue, slate)

Examples (Figma neutral palettes):

- Driftwood Pearl Morning: `#BC7B6F #E4A499 #5A322A #718A9E #CCCDC7`
- Sandstone Aquamarine Serenity: `#BC6C50 #DDAD9C #304C53 #5A2F25 #AFE0E7`
- Soft Linen: `#E8C09A #E9A760 #F6F5F5 #ABA19F #BF885F #B5DCC9`

Source: https://www.figma.com/color-palettes/neutral/

Why it works for Loppisfynd:

- Reads "craft" and "second-hand" immediately
- Cool accent gives UI clarity (links, info, focus)

---

### Trend 2: Earthy palettes include real dark anchors

Even earthy palettes include a deep near-black/near-charcoal to keep contrast crisp.

Example (Figma earthy palettes):

- Amber Obsidian Autumn: `#DC3C0C #691F0C #D3C0B2 #7A7A78 #E1E1E1 #1D1816`

Source: https://www.figma.com/color-palettes/earthy/

Why it matters for us:

- If terracotta becomes "primary", you still need an ink that is darker than `grayGreen` for body text and icons.

---

### Trend 3: Pastels are used as atmosphere, not structure

Pastel palettes usually pair:

- 1–2 pastel surfaces
- 1 muted dark anchor
- 1 accent that carries personality

Example (Figma pastel palettes):

- Gentle Dunes: `#F3C09F #FEE1BB #E083AC #69AAAF #9DC9C3 #52DCCE`

Source: https://www.figma.com/color-palettes/pastel/

How to steal it:

- Use pastels in backgrounds/illustrations/textures (your nano textures + atmospheric images)
- Keep UI surfaces mostly neutral for readability

---

### Trend 4: Gradients remain common (but mostly for hero/marketing)

Behance still pushes gradient palette collections as a "UI trend" artifact and as moodboard material.

- Gradient palette project: https://www.behance.net/gallery/231518933/Best-Gradient-Color-Palettes-for-2025-UI-Trends
- Large palette exploration / gradients: https://www.behance.net/gallery/242180381/Above-the-Clouds-color-palette

How to use this without making the app look like a crypto dashboard:

- Reserve gradients for:
  - onboarding hero background
  - scanner hint overlays
  - badges (profit/insight)
- Keep core UI surfaces matte + textured

---

### Trend 5: Brand guidance leans toward intentional, meaning-led selection

Dribbble’s guidance (even if not a 2026 trend report) aligns with current brand practice:

- define brand voice keywords
- study competitor palettes
- treat color as a message system (not decoration)

Source: https://dribbble.com/resources/freelance/logo-color-schemes

For Loppisfynd brand voice keywords:

- warm, honest, tactile, second-hand, Nordic, calm

---

## What This Means For Our Palette Tokens

Your current "Nature Distilled" palette is directionally right, but to be production-usable it needs:

1. A neutral ramp (not just 1 background + 1 surface)
2. A deeper ink (text/icon anchor)
3. A terracotta ramp (for CTA, hover/pressed, subtle tints)
4. A cool accent ramp (muted teal/steel-blue) to keep the UI readable and modern

---

## Suggested Improvements (Palette v2)

Keep your existing named colors, add ramps.

### Neutral ramp

- `neutral0` `#FAF6EF` (app background alt)
- `neutral1` `#F3EEE6` (cream)
- `neutral2` `#F3EEDC` (warmIvory)
- `neutral3` `#E9E0D3` (surface alt)
- `neutral4` `#D7CFC3` (borders on light)

### Ink ramp (the missing piece)

- `ink0` `#2F3A34` (primary text/icons)
- `ink1` `#4E5C56` (secondary text)
- `ink2` `#6E7C75` (muted text)

### Terracotta ramp

- `terra50` `#F7E4DD`
- `terra200` `#E4A499` (matches Figma neutral examples)
- `terra400` `#D9A08E` (your dark-mode terracotta already lives here)
- `terra500` `#C58A73` (current)
- `terra700` `#935233` (existing copperOak)
- `terra900` `#5A2F25` (seen in Figma neutrals)

### Cool counterweight ramp

- `teal300` `#AFE0E7` (seen in Figma neutrals)
- `teal500` `#5A8C88` (your mutedTeal)
- `slate600` `#304C53` (seen in Figma neutrals; great for dark UI accents)

---

## Practical UI Rules (So It Doesn’t Drift)

- Backgrounds: always neutral (`neutral0–2`)
- Cards: neutral + glass (texture/blur gives personality)
- CTA: terracotta 500 for fills, terracotta 700 for pressed/selected
- Text: use `ink0` for primary content; `ink1/ink2` for meta
- Links: keep blue for links, but keep it rare
- Data viz: do not reuse CTA terracotta for every chart series; add a small chart palette
