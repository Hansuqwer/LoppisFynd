# Textures - Nature Distilled

---

## Concept

Textures add tactile warmth and second-hand authenticity without overwhelming the UI. Used sparingly as overlays, backgrounds, or accent elements.

**Philosophy:** "Worn, loved, honest" - Nordic/Scandi second-hand aesthetic.

Trend notes: `roadmapv2/research/textures_research_2026.md`.

---

## Texture Types

### 1. Worn Vintage Paper

| Property | Value |
|----------|-------|
| Base Color | #F3EEDC (warm ivory) |
| Aging Spots | #C58A73 (terracotta) |
| Creases | subtle, light shadows |
| Grain | fine, matte |
| Feel | soft, tactile |

**Best Use:**
- Splash screen background
- Empty state illustrations
- Onboarding illustrations
- Large hero sections

---

### 2. Weathered Linen

| Property | Value |
|----------|-------|
| Base Color | #F3EEE6 (cream) |
| Weave Pattern | subtle, visible on close |
| Highlights | #F5F0E6 |
| Shadows | #7A9B76 (sage) @ 10% |
| Feel | fabric, organic |

**Best Use:**
- Category cards
- Filter backgrounds
- Bottom sheet backgrounds

---

### 3. Patinated Metal / Brass

| Property | Value |
|----------|-------|
| Base Color | #C58A73 (terracotta) |
| Patina | #5A8C88 (muted teal) |
| Tarnish | #B77B87 (dusty rose) |
| Scratches | subtle, light |
| Feel | vintage, premium |

**Best Use:**
- Icon backgrounds
- Accent borders
- Loading states
- Price tag elements

---

### 4. Reclaimed Wood Grain

| Property | Value |
|----------|-------|
| Base Stain | #4E5C56 (gray-green) |
| Grain Lines | #C58A73 (terracacotta) |
| Age Cracks | subtle, dark |
| Pattern | vertical planks |
| Feel | rustic, warm |

**Best Use:**
- Noisy texture overlay (10-15% opacity)
- Detail page headers
- Background accent strips

---

## Application Methods

### Method 1: Full Background

```
Stack(
  Image texture (full screen, low opacity 10-15%)
  Solid color overlay (cream @ 80%)
  AtmosphericBackground image (optional)
)
```

**Use for:** Splash, empty states, onboarding

---

### Method 2: Subtle Overlay

```
Container(
  decoration: BoxDecoration(
    color: cream,
    image: DecorationImage(
      image: AssetImage('linen_texture.png'),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        cream.withOpacity(0.1),
        BlendMode.overlay,
      ),
    ),
  ),
)
```

**Use for:** Card backgrounds, sheet backgrounds

---

### Method 3: Noise/Grain Overlay

```
BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 0.1, sigmaY: 0.1),
  child: Container(
    color: Colors.transparent,
    foregroundDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('paper_grain.png'),
        repeat: ImageRepeat.repeat,
        opacity: 0.08,
      ),
    ),
  ),
)
```

**Use for:** Adding subtle texture to glass surfaces

---

### Method 4: Element-Specific

Apply texture only to specific UI elements:

```
GlassCard(
  background: wood_texture,
  child: content,
)
```

**Use for:** Price tags, category icons, accent pieces

---

## Texture Assets Needed

### Required (Priority Order)

| Texture | Format | Resolution | Size Target |
|---------|--------|------------|-------------|
| paper_worn | PNG | 1080x1080 | < 500KB |
| linen_woven | PNG | 1080x1080 | < 500KB |
| wood_grain | PNG | 1080x1080 | < 500KB |
| metal_patina | PNG | 512x512 | < 200KB |
| paper_grain (noise) | PNG | 256x256 tileable | < 100KB |

### Nano Banano Prompt (for generation)

```
Texture swatches for a Swedish second-hand app. Create 4 seamless texture tiles:

1) Worn vintage paper / aged kraft paper - soft creases, slight tea-staining, warm ivory base (#F3EEDC) with terracotta (#C58A73) aging spots

2) Weathered linen / vintage fabric - hand-woven feel, subtle weave pattern, sage green (#7A9B76) with cream (#F3EEE6) highlights, soft folds

3) Patinated metal / old brass button - warm tarnished patina, muted teal (#5A8C88) and dusty rose (#B77B87) undertones, subtle scratches

4) Reclaimed wood grain - vertical planks, deep gray-green (#4E5C56) stain, warm terracotta grain lines, visible age cracks

All textures: matte finish, tactile feel, subtle grain noise, no glossy or digital-looking surfaces. Nordic/Scandi second-hand aesthetic - worn, loved, honest. Seamless tileable edges. Square format, even lighting, clean shot on warm neutral background.
```

---

## Where to Apply

### High Impact (Use Full Textures)

| Screen/Element | Texture | Opacity |
|----------------|---------|---------|
| Splash screen | paper_worn | 100% |
| Empty state | paper_worn | 60% |
| Onboarding | linen_woven | 40% |
| Hero section | linen_woven | 30% |

### Medium Impact (Use Overlays)

| Element | Texture | Opacity |
|---------|---------|---------|
| Card backgrounds | linen_woven | 15-20% |
| Bottom sheets | linen_woven | 10% |
| Modal backgrounds | paper_worn | 20% |

### Low Impact (Subtle Noise)

| Element | Texture | Opacity |
|---------|---------|---------|
| Glass cards | paper_grain | 5-8% |
| Buttons | paper_grain | 5% |
| Input fields | paper_grain | 5% |

---

## Dark Mode

Textures shift to warmer, more subtle:

| Texture | Light | Dark |
|---------|-------|------|
| paper_worn | cream base | charcoal base |
| linen_woven | cream base | deepCharcoal base |
| wood_grain | grayGreen | warmCharcoal |
| metal_patina | same | slightly brighter |

**Note:** Dark mode textures should be even more subtle (50-70% of light mode opacity).

---

## Performance

1. **Tileable** - create 256x256 tiles, repeat as needed
2. **Optimized** - prefer WEBP for large textures; keep tiles small (256-512) and target < 200KB each
3. **Lazy load** - load textures only when needed
4. **Cache** - use memory cache for frequently displayed textures

---

## Future Ideas

- **Animated textures** - subtle paper flutter, fabric ripple
- **Dynamic textures** - texture color shifts with brand color changes
- **Personalized textures** - user chooses texture theme
- **Seasonal textures** - different textures for holidays/seasons
