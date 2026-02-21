# Typography Trends (2026) - Inputs For LoppisFynd

Source checked:
- Behance curated gallery: https://www.behance.net/galleries/graphic-design/typography

## Signals Seen In Curated Work (What’s “winning” visually)

1. Display fonts stay expressive, but cleaner
- Lots of *new* display families that are still usable (less distressed/grunge, more controlled curves).
- Common vibe: “soft grotesk” (rounded-ish, friendly terminals) rather than ultra-neutral UI sans.

2. Condensed + bold headlines are back (for posters + editorial blocks)
- Narrow widths let designers keep hero type large without blowing vertical space.
- Often paired with generous tracking in small caps / labels.

3. Variable fonts are increasingly default (especially for type foundries)
- Many new releases emphasize VF (weight/width axes) as a product feature.
- Practical impact: fewer font files, finer weight steps for hierarchy.

4. Motion typography / animated typefaces are mainstream
- Animated type is treated like a brand asset, not a gimmick.
- Typical use: short hero moments, loading states, or promo banners.

5. Non-Latin typography is *prominent*, not “niche”
- Arabic calligraphy/type experiments and CJK display work show up in curated sets.
- Implication: apps that claim “craft” benefit from better fallback + numerals decisions.

## Concrete Examples From The Behance Gallery

(Links are for style reference; not all are directly compatible with our “Nature Distilled” tone.)

- Soft grotesk / friendly display: https://www.behance.net/gallery/243893965/Aeonik-Soft
- Condensed bold headline energy: https://www.behance.net/gallery/243056041/Reiger-Bold-Condensed-Font
- Clean grotesk / editorial: https://www.behance.net/gallery/243001713/Postamp-Grotesk
- Geometric sans demo: https://www.behance.net/gallery/242836515/Method-Geometric-Sans-Serif-Font-Download-Free-Demo
- Victorian / high-character display: https://www.behance.net/gallery/242925615/Mikayani-Victorian-Typeface
- Variable font emphasis (example): https://www.behance.net/gallery/241465245/TS-Cordoba-VF-
- Animated type (example): https://www.behance.net/gallery/243079209/Fat-Frank-Animated-Typeface

## What We Should Steal For LoppisFynd

- Use a *soft*, human UI sans for most text (we already have Outfit; lean into its friendlier weights).
- Make prices/numbers feel “designed” (we already have Space Grotesk; ensure tabular numerals / consistent weight steps).
- Add one intentional “poster moment” per screen max (big title, bold stat, or one accent word), not everywhere.
- Prefer width/weight variation over adding more font families.

## Token Implications (Actionable Adjustments)

- Add width/weight steps to headline tokens (e.g., 600/700, and a “condensed-like” fallback via letterspacing + size if we don’t add a condensed font).
- Define numeric styles as first-class tokens (price/stat) and standardize the weight ladder.
- Tighten headline line-heights (1.05-1.15) while keeping body comfortable (1.45-1.6).
- Use tracking only for labels/caps; avoid tracking body text.

## Notes / Constraints For Flutter

- If we move to variable fonts later, confirm platform rendering parity (Android vs iOS) and package size.
- Keep motion typography subtle: opacity/translate/scale + number count-up; avoid per-glyph animations for performance.
