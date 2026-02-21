# Glassmorphism Components - Nature Distilled

---

## Design Principles

1. **Frosted glass effect** - blur background + semi-transparent fill + subtle stroke
2. **Layered depth** - glass surfaces stack with increasing opacity
3. **Warm tint** - use warm ivory (#F3EEDC) tint for light mode
4. **Dark mode contrast** - use subtle white fill for dark glass
5. **Performance first** - use moderate blur (10-24px), avoid >40px

---

## Trend-Informed Notes (2025-2026)

Reference notes: `roadmapv2/research/glassmorphism_research_2026.md`.

- Modern glass is a stack: blur + translucent fill + subtle stroke + highlight lines + (optional) noise.
- Readability is the failure mode; constrain the backdrop with tint+blur and keep fill opacity high enough for text.
- Provide a fallback for "reduced transparency" (increase fill opacity, reduce blur).

---

## Component Library

### 1. GlassSurface (Base)

The foundational glass container.

| Property | Light Mode | Dark Mode |
|----------|------------|-----------|
| blurSigma | 16px | 16px |
| fillColor | #FFFFFF @ 35% | #FFFFFF @ 10% |
| strokeColor | #FFFFFF @ 20% | #FFFFFF @ 15% |
| borderRadius | 16px | 16px |

**Usage:** Base for all glass components.

---

### 2. GlassCard (Bento)

Main content card for dashboard, item details, etc.

| Property | Light Mode | Dark Mode |
|----------|------------|-----------|
| blurSigma | 16px | 16px |
| fillColor | #FFFFFF @ 40% | #FFFFFF @ 12% |
| strokeColor | #FFFFFF @ 25% | #FFFFFF @ 18% |
| borderRadius | 24px | 24px |
| shadow | elevated | elevated |

**Variants:**
- `GlassCard.bento` - default, 24px radius
- `GlassCard.tight` - 12px radius, smaller blur
- `GlassCard.floating` - higher blur, more elevation

---

### 3. GlassButton

Primary action buttons.

| Property | Light Mode | Dark Mode |
|----------|------------|-----------|
| blurSigma | 10px | 10px |
| fillColor | #C58A73 @ 60% (terracotta) | #D9A08E @ 50% |
| strokeColor | #FFFFFF @ 30% | #FFFFFF @ 20% |
| borderRadius | 12px | 12px |
| textColor | #FFFFFF | #1A1A1A |

**States:**
- default: as above
- pressed: fill @ 80%, blur 5px
- disabled: fill @ 20%, no stroke
- loading: shimmer animation

**Variants:**
- `GlassButton.primary` - terracotta fill
- `GlassButton.secondary` - subtle white fill
- `GlassButton.ghost` - transparent fill, stroke only

---

### 4. GlassChip

Tags, filters, categories.

| Property | Light Mode | Dark Mode |
|----------|------------|-----------|
| blurSigma | 8px | 8px |
| fillColor | #FFFFFF @ 30% | #FFFFFF @ 8% |
| strokeColor | #FFFFFF @ 15% | #FFFFFF @ 10% |
| borderRadius | 20px (pill) | 20px |
| textColor | grayGreen | softCream |

**Variants:**
- `GlassChip.filter` - selectable, checkmark on select
- `GlassChip.tag` - static, no interaction
- `GlassChip.category` - with icon support

---

### 5. GlassInput

Text fields, search bars.

| Property | Light Mode | Dark Mode |
|----------|------------|-----------|
| blurSigma | 10px | 10px |
| fillColor | #FFFFFF @ 25% | #FFFFFF @ 8% |
| strokeColor | #FFFFFF @ 15% | #FFFFFF @ 10% |
| borderRadius | 12px | 12px |
| textColor | grayGreen | softCream |
| placeholderColor | grayGreen @ 54% | softCream @ 54% |

**States:**
- default: as above
- focused: stroke color increases, subtle glow
- error: terracotta tint stroke
- disabled: 50% opacity

---

### 6. GlassNavBar

Bottom navigation capsule.

| Property | Light Mode | Dark Mode |
|----------|------------|-----------|
| blurSigma | 24px | 24px |
| fillColor | #FFFFFF @ 60% | #1A1A1A @ 80% |
| strokeColor | #FFFFFF @ 30% | #FFFFFF @ 15% |
| borderRadius | 24px | 24px |

**Features:**
- Pill-shaped container
- Floating above content
- Safe area aware

---

### 7. GlassAppBar

Top app bar.

| Property | Light Mode | Dark Mode |
|----------|------------|-----------|
| blurSigma | 12px | 12px |
| fillColor | #FFFFFF @ 50% | #1A1A1A @ 70% |
| strokeColor | none | none |
| borderRadius | 0 (extend) | 0 |

---

### 8. GlassBottomSheet

Slide-up panels.

| Property | Light Mode | Dark Mode |
|----------|------------|-----------|
| blurSigma | 30px | 30px |
| fillColor | #FFFFFF @ 75% | #1A1A1A @ 90% |
| strokeColor | #FFFFFF @ 30% | #FFFFFF @ 15% |
| borderRadius | 24px (top only) | 24px |
| handleColor | grayGreen @ 30% | softCream @ 30% |

---

### 9. GlassModal

Dialogs, overlays.

| Property | Light Mode | Dark Mode |
|----------|------------|-----------|
| blurSigma | 40px (background) | 40px |
| fillColor | #FFFFFF @ 90% | #2D3436 @ 95% |
| strokeColor | #FFFFFF @ 40% | #FFFFFF @ 20% |
| borderRadius | 24px | 24px |
| scrimColor | #000000 @ 50% | #000000 @ 60% |

---

### 10. GlassHero

Hero sections with image.

| Property | Light Mode | Dark Mode |
|----------|------------|-----------|
| blurSigma | 8px | 8px |
| gradient | cream→transparent | charcoal→transparent |
| overlayOpacity | 30% | 40% |

---

## Atmospheric Background Usage

Glass components work best with atmospheric backgrounds:

```dart
// Layer order
Stack(
  1. AtmosphericBackground (image + tint + blur)
  2. GlassSurface / GlassCard (content container)
  3. Content (text, buttons, etc.)
)
```

### Background Settings

| Token | Value |
|-------|-------|
| tintColor | #F3EEDC (warm ivory) |
| tintOpacity | 0.60 - 0.70 |
| blurSigma | 15 - 25 |
| imagePath | loppis_background.png |

---

## Component Composition

### Example: Item Card

```
GlassCard.bento
├── GlassImage (item photo)
├── GlassSurface (content area)
│   ├── Title (headline)
│   ├── Price (metrics font)
│   └── GlassChip (category)
└── GlassButton.primary (action)
```

### Example: Filter Sheet

```
GlassBottomSheet
├── Handle
├── GlassChip.filter (multiple)
│   ├── Category chips
│   └── Price range chips
└── GlassButton.primary (apply)
```

---

## Implementation Options

### Option A: flutter_glass_morphism Package

```dart
import 'package:flutter_glass_morphism/flutter_glass_morphism.dart';

GlassMorphismCard(
  blurIntensity: 16.0,
  opacity: 0.15,
  borderRadius: BorderRadius.circular(24),
  child: Content(),
)
```

**Pros:** Ready-to-use components, battle-tested
**Cons:** Additional dependency, may not match exact specs

### Option B: Custom Implementation

```dart
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color fill;
  final Color stroke;
  
  // ClipRRect + BackdropFilter + Container
}
```

**Pros:** Full control, matches design exactly
**Cons:** More code to maintain

### Option C: Hybrid

- Create custom `GlassSurface` base
- Use for complex components
- Use `flutter_glass_morphism` for simple cases

---

## Performance Considerations

1. **Blur is expensive** - use `RepaintBoundary` around glass surfaces
2. **Limit blur layers** - max 3-4 visible glass components
3. **Cache blur** - consider `ImageFiltered` with cached images
4. **Reduce on low-end** - use 8-10px blur on budget devices
5. **Animate carefully** - avoid animating blur value

---

## Accessibility / Fallbacks

- Reduced transparency (fallback): increase fill opacity by ~10-20%, reduce blur by ~30-50%, strengthen stroke.
- Busy backgrounds: always apply an atmospheric tint+blur behind major glass surfaces.

---

## Mobile-Specific Notes

- iOS: `BackdropFilter` works well, use `sigmaX/Y`
- Android: Test on older devices, may need reduced blur
- Foldables: Blur may need adjustment for larger screens

---

## Future (2027)

- **Variable blur** - blur based on scroll velocity
- **Dynamic tint** - tint color from background image dominant color
- **Haptic glass** - subtle feedback on glass surface interaction
