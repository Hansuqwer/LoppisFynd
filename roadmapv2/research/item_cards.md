# Item Cards - Nature Distilled

---

## Overview

Item cards display scanned second-hand items in lists, grids, and detail views. They are the core UI component for the app's main functionality.

---

## Card Types

### 1. ItemCard (Grid/List)

Primary card for displaying scanned items in lists/grids.

```
┌─────────────────────────────────────┐
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │       ITEM IMAGE            │    │
│  │                             │    │
│  │  ┌─────┐                    │    │
│  │  │CAT  │  ♥              →  │    │
│  │  └─────┘                    │    │
│  └─────────────────────────────┘    │
│                                     │
│  Item Title                        │
│  SEK 150 → SEK 450                │
│  📍 2km  •  Good                   │
└─────────────────────────────────────┘
```

| Property | Value |
|----------|-------|
| Container | GlassCard.bento |
| Border Radius | 24px |
| Padding | 12px |
| Image Aspect | 1:1 or 4:3 |
| Shadow | elevated |

---

### Content Layout

#### Image Section

| Element | Position | Notes |
|---------|----------|-------|
| Image | top | 1:1 or 4:3 aspect ratio |
| Category Chip | bottom-left overlay | GlassChip.category |
| Like Button | top-right | heart icon |
| Compare Button | top-right (below like) | + icon |

**Image States:**
- loading: shimmer placeholder
- error: fallback icon
- long-press: quick actions menu

---

#### Info Section

| Element | Order | Style |
|---------|-------|-------|
| Title | 1 | headlineMedium, max 2 lines |
| Price Row | 2 | see below |
| Meta Row | 3 | see below |

**Price Row:**
```
SEK 150 → SEK 450  [profit badge]
```

| Price Part | Font | Color |
|------------|------|-------|
| Purchase | Space Grotesk, 16px | grayGreen |
| Arrow | - | grayGreen.54 |
| Resale | Space Grotesk, 20px, bold | terracotta |
| Profit Badge | - | sage (profit), dustyRose (loss) |

**Meta Row:**
```
📍 2km  •  Condition  •  2 days ago
```

| Meta Part | Style |
|-----------|-------|
| Location | textMuted, icon + text |
| Divider | textMuted "•" |
| Condition | textMuted |
| Timestamp | textMuted |

---

### ItemCard Variants

#### Compact (List View)

```
┌──────────────────────────────────────────────┐
│ ┌──────┐  Title                      SEK 450 │
│ │ IMG  │  Condition • 2km              →     │
│ └──────┘  2 days ago                           │
└──────────────────────────────────────────────┘
```

- Image: 64x64, rounded 12px
- No shadow
- Horizontal layout

---

#### Featured (Hero)

```
┌─────────────────────────────────────────────┐
│ ┌─────────────────────────────────────────┐ │
│ │                                         │ │
│ │           LARGE IMAGE                   │ │
│ │                                         │ │
│ │  ┌─────┐              ♥               │ │
│ │  │CAT  │                              │ │
│ │  └─────┘                              │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│  Item Title (Large)                        │
│  SEK 150 → SEK 450  [+300%]               │
│  📍 2km  •  Good condition                 │
│                                             │
│  [Save]  [Compare]  [Details]              │
└─────────────────────────────────────────────┘
```

- Image: full width, 16:9
- More actions visible
- Profit percentage badge

---

#### Comparison Card (For compare mode)

```
┌─────────────────────────────────────┐
│  ○  SELECT                          │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │       ITEM IMAGE            │    │
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
│  Title                        85%  │
│  SEK 450                    [bars] │
└─────────────────────────────────────┘
```

- Checkbox/selection indicator
- Match score percentage
- Simplified layout

---

## Item Card Components

### 1. ItemImage

```dart
ItemImage(
  imageUrl: '...',
  aspectRatio: 1.0,
  category: 'Clothing',
  isLiked: false,
  onLike: () {},
  onLongPress: () {},
)
```

| Property | Light | Dark |
|----------|-------|------|
| placeholder | warmIvory | deepCharcoal |
| error | sage @ 30% | mutedSage @ 30% |
| loading | shimmer cream→clay | shimmer |

---

### 2. CategoryChip

```dart
CategoryChip(
  category: 'Clothing',
  icon: Icons.checkroom,
)
```

| Property | Light | Dark |
|----------|-------|------|
| background | sage @ 20% | mutedSage @ 15% |
| text | grayGreen | softCream |
| icon | grayGreen | softCream |
| border-radius | 12px | 12px |

---

### 3. PriceDisplay

```dart
PriceDisplay(
  purchasePrice: 150,
  resalePrice: 450,
  currency: 'SEK',
)
```

| Element | Style |
|---------|-------|
| purchase | Space Grotesk, 14px, textMuted |
| arrow | "-", textMuted |
| resale | Space Grotesk, 18px, bold, terracotta |
| profit badge | optional, pill shape |

**Profit Badge:**
- profit: sage background, "+X%"
- loss: dustyRose background, "-X%"
- neutral: grayGreen background

---

### 4. ConditionBadge

```dart
ConditionBadge(condition: ItemCondition.good)
```

| Condition | Color | Label |
|----------|-------|-------|
| mint | sage | Mint |
| good | mutedTeal | Good |
| fair | terracotta | Fair |
| poor | dustyRose | Poor |

---

### 5. MetaRow

```dart
MetaRow(
  location: '2km away',
  condition: ItemCondition.good,
  timestamp: DateTime.now().subtract(Duration(days: 2)),
)
```

Elements: location icon + text, divider, condition, divider, relative time

---

### 6. ActionButtons

```
[♡ Save]  [⚡ Compare]  [→ Details]
```

| Button | Style |
|--------|-------|
| Save | GlassButton.ghost, heart icon |
| Compare | GlassButton.ghost, + icon |
| Details | GlassButton.primary |

---

## States

### Default

- Normal appearance
- All elements visible

### Pressed

- Scale: 0.98
- Shadow: pressed
- Duration: 100ms

### Selected (Compare Mode)

- Border: 2px terracotta
- Checkmark overlay
- Background: terracotta @ 5%

### Disabled

- Opacity: 50%
- No interactions

### Loading

- Shimmer effect on image
- Skeleton text lines

### Error

- Error icon fallback
- Gray placeholder

---

## Responsive Behavior

### Mobile (Compact)

- Single column
- Image full width
- Stacked info

### Tablet (Grid)

- 2-3 columns
- Larger images
- More info visible

### Desktop (Expanded)

- 4+ columns
- Larger cards
- Hover states enabled

---

## Interactions

### Tap

- Scale animation (0.98)
- Navigate to detail

### Long Press

- Haptic feedback
- Quick actions sheet:
  - Save to list
  - Compare
  - Delete
  - Share

### Swipe (List)

- Left: delete
- Right: save to list

### Drag (Compare Mode)

- Reorder cards
- Drop zones highlighted

---

## Implementation

### Using GlassCard

```dart
GlassCard(
  blurIntensity: 16.0,
  opacity: 0.15,
  borderRadius: BorderRadius.circular(24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ItemImage(...),
      SizedBox(height: 12),
      Text(title, style: headlineMedium),
      PriceDisplay(...),
      MetaRow(...),
    ],
  ),
)
```

### Custom Implementation

```dart
BentoCard(
  padding: EdgeInsets.all(12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _ImageSection(...),
      _InfoSection(...),
    ],
  ),
)
```

---

## Animation Ideas

1. **Price reveal** - resale price fades in after scan
2. **Like heart** - scale + fill animation
3. **Match bars** - horizontal fill animation
4. **Card entrance** - staggered fade up in grid
5. **Profit badge** - count up animation for percentage

---

## Dark Mode

Same structure, colors from `AppColorsDark`:

| Element | Light | Dark |
|---------|-------|------|
| card background | white @ 40% | white @ 12% |
| title | grayGreen | softCream |
| resale price | terracotta | softTerracotta |
| meta text | grayGreen.54 | softCream.54 |

---

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- primary text: ink0 (light), softCream (dark)
- secondary/meta: ink1/ink2 (light), softCream alpha (dark)
- CTA/profit accents: terracotta500/terracotta700 + sage
- borders: neutral4 (light) / subtle white alpha (dark)

Typography:
- item title: headlineMedium/titleLarge depending on density
- prices/stats: Space Grotesk (priceMedium/priceLarge)
- chips/meta: labelMedium/bodySmall

---

## Accessibility

- Minimum touch target: 44x44px
- Contrast ratios: WCAG AA
- Screen reader: semantic labels
- Reduce motion: disable animations

---

## Trend-Informed Notes (2024-2026)

Reference notes: `roadmapv2/research/item_cards_research_2026.md`.

- Prefer one visible primary action per card; move secondary actions to overflow/long-press (Polaris guidance).
- Make price/profit hierarchy visually dominant; keep metadata subdued.
- Keep overlays minimal to avoid fighting the photo.
