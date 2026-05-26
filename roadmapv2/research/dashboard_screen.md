# Dashboard Screen - Nature Distilled

---

## Current Implementation

**What's there:**
- GlassBoard container
- Hero CTA card ("Start Scanning")
- 2x2 grid of stats tiles
- Model preflight card (Gemma-era; should be removed/repurposed when moving away from Gemma)
- Notifications button

**Current components:**
- `_HeroCtaCard` - main CTA
- `_HomeTile` - stat tiles (4 items)
- `_ModelPreflightCard` - AI model status

---

## Proposed Redesign

### Layout Overview

```
┌─────────────────────────────────────────────┐
│  Loppisfynd              🔔 [Avatar]        │  <- AppBar (glass)
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │  Welcome back!                      │    │
│  │                                     │    │
│  │  📷 Ready to find treasures?       │    │
│  │                                     │    │
│  │  [  Start Scanning  ]              │    │  <- Hero CTA
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌────────────┐ ┌────────────┐            │
│  │   12       │ │  SEK 2,450  │            │
│  │  Items     │ │  Profit     │            │  <- Stats Grid
│  └────────────┘ └────────────┘            │
│  ┌────────────┐ ┌────────────┐            │
│  │   3        │ │   85%      │            │
│  │  Drafts    │ │  Accuracy  │            │
│  └────────────┘ └────────────┘            │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │  🤖 AI Status: Cloud                │    │
│  │  Model ready • Fast identification  │    │  <- AI Status Card
│  └─────────────────────────────────────┘    │
│                                             │
│  Recent Activity                    See All │  <- Section header
│  ┌─────────────────────────────────────┐    │
│  │ 🧥 Vintage Jacket    SEK 450      │    │
│  │ 📍 2km • 2h ago                    │    │  <- Activity list
│  └─────────────────────────────────────┘    │
│  ┌─────────────────────────────────────┐    │
│  │ 👗 Floral Dress     SEK 200        │    │
│  │ 📍 5km • Yesterday                 │    │
│  └─────────────────────────────────────┘    │
│                                             │
└─────────────────────────────────────────────┘
```

---

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- background: neutral0 (atmospheric image behind, tinted)
- text: ink0 (primary), ink1 (secondary)
- surfaces: GlassCard (warm tint)
- primary action: terracotta500 (pressed: terracotta700)
- profit: sage

Typography:
- app greeting/title: headlineMedium
- hero CTA: headlineLarge + labelLarge for button
- stat values: statLarge/statMedium (Space Grotesk)
- stat labels/meta: labelMedium/bodySmall

---

## Components

### 1. Hero CTA Card

Primary call-to-action to start scanning.

```
┌─────────────────────────────────────┐
│  👋 Welcome back, Hans!             │
│                                     │
│  Ready to find some treasures?     │
│                                     │
│  [  📷 Start Scanning  ]            │
│                                     │
│  Today: 3 items • SEK 450 profit   │
└─────────────────────────────────────┘
```

| Property | Light | Dark |
|----------|-------|------|
| background | glassSurfaceMedium | glassSurfaceDark |
| title | headlineMedium | headlineMedium |
| body | bodyMedium | bodyMedium |
| button | GlassButton.primary | GlassButton.primary |
| accent | terracotta | softTerracotta |

**Animation:**
- Subtle float on load
- Button pulse on idle (draw attention)

---

### 2. Stats Grid

2x2 grid showing key metrics.

| Tile | Icon | Value Style | Label Style |
|------|------|-------------|-------------|
| Items | shopping_bag | displayLarge, bold | labelMedium, muted |
| Profit | trending_up | displayLarge, bold, terracotta | labelMedium, muted |
| Drafts | bookmark | displayLarge | labelMedium, muted |
| Accuracy | target | displayLarge, sage | labelMedium, muted |

**Stats Cards:**

```
┌─────────────────┐
│  🛍️           │
│                 │
│     12          │
│   Items         │
└─────────────────┘
```

| Property | Value |
|----------|-------|
| container | GlassCard.bento |
| icon size | 24px |
| value size | 28px (displayLarge) |
| label size | 12px (labelMedium) |
| value color | grayGreen (terracotta for profit) |

---

### 3. AI Status Card

Shows current AI backend and model status.

```
┌─────────────────────────────────────┐
│  🤖 AI: Cloud Gemini               │
│  ● Online • Fast identification    │
│                                     │
│  [ ⚡ Switch to Offline ]           │
└─────────────────────────────────────┘
```

| Property | Light | Dark |
|----------|-------|------|
| indicator (online) | sage | mutedSage |
| indicator (offline) | mutedTeal | lightGrayGreen |
| button | GlassButton.secondary | GlassButton.secondary |

**States:**
- Cloud: "Cloud Gemini • Online"
- Offline: "Offline Mode • Ready"
- Loading: "Warming up AI..."
- Error: "AI unavailable"

**Behavior:**
- Primary tap opens offline AI management: `roadmapv2/research/model_manager_screen.md`

---

### 4. Recent Activity List

Shows last scanned items.

```
Recent Activity                See All →

┌─────────────────────────────────────┐
│  🧥 Vintage Leather Jacket         │
│  SEK 150 → SEK 450  [+200%]       │
│  📍 2km away • 2 hours ago        │
│  [Clothing] [Good]                 │
└─────────────────────────────────────┘
```

| Element | Style |
|---------|-------|
| container | GlassCard (flat) |
| title | titleMedium, bold |
| price | Space Grotesk, terracotta |
| profit badge | sage (positive), dustyRose (negative) |
| meta | textMuted |
| chips | GlassChip.category |

---

### 5. Quick Actions

Optional: floating action area.

```
[ 📷 Scan ]  [ 📊 Stats ]  [ 📤 Sync ]
```

| Button | Icon | Action |
|--------|------|--------|
| Scan | camera | Navigate to scanner |
| Stats | chart | Navigate to summary |
| Sync | cloud_upload | Manual sync |

---

## Section: Today's Summary

Optional hero section with daily stats.

```
┌─────────────────────────────────────┐
│  Today's Haul                      │
│                                     │
│  ┌──────┐  ┌──────┐  ┌──────┐     │
│  │  3   │  │  SEK │  │ 85%  │     │
│  │ items │  │ 450  │  │ fit  │     │
│  └──────┘  └──────┘  └──────┘     │
│                                     │
│  ████████████░░░░░░░  55% of goal │
└─────────────────────────────────────┘
```

---

## Section: Goals Progress

If user has set goals.

```
┌─────────────────────────────────────┐
│  Weekly Goal: SEK 3,000            │
│                                     │
│  ████████████████░░░  2,450 / 3,000│
│                                     │
│  3 days left • 550 SEK to go       │
└─────────────────────────────────────┘
```

---

## Atmospheric Elements

### Background

Use `AtmosphericBackground`:

```
Stack(
  1. AtmosphericBackground (loppis_background)
  2. SafeArea
  3. GlassBoard / GlassCard containers
)
```

### Glass Containers

All major containers use glass:

- Hero CTA: GlassCard.bento
- Stats grid: GlassCard items
- AI Status: GlassCard.small
- Activity list: GlassCard items

---

## Responsive Behavior

### Mobile (Default)

- Single column
- 2x2 stats grid
- Full-width cards

### Tablet

- Side-by-side sections
- 4-column stats grid
- Larger cards

### Desktop

- Centered container (max 600px)
- 4-column stats
- Hover states on cards

---

## Animations

### Page Load

| Animation | Element | Duration | Curve |
|-----------|---------|----------|-------|
| fade in | container | 300ms | easeOut |
| fade up | cards (staggered) | 400ms | easeOutCubic |
| scale in | stats numbers | 500ms | bounceOut |

### Interactions

| Animation | Element | Duration | Curve |
|-----------|---------|----------|-------|
| tap scale | cards | 100ms | easeOut |
| tap scale | buttons | 150ms | bounceOut |
| ripple | buttons | 300ms | easeOut |

### Data Updates

| Animation | Element | Duration | Curve |
|-----------|---------|----------|-------|
| count up | stats numbers | 600ms | easeOut |
| color flash | profit (positive) | 300ms | easeOut |
| color flash | profit (negative) | 300ms | easeOut |

---

## Dark Mode

| Element | Light | Dark |
|---------|-------|------|
| background | AtmosphericBackground | AtmosphericBackground (dark) |
| GlassCard | white @ 40% | white @ 12% |
| title | grayGreen | softCream |
| value (profit) | terracotta | softTerracotta |
| value (neutral) | grayGreen | softCream |
| button | terracotta | softTerracotta |

---

## Implementation (Per Roadmap)

### Phase 1 (M1 - Cloud AI)

1. AI Status Card component
2. Cloud/Offline toggle
3. Integration with AI settings

### Phase 2 (M2 - Offline)

4. Offline status indicator
5. Offline fallback explanation (no downloads)

### Phase 3 (UI Polish)

6. Atmospheric background
7. Glassmorphism containers
8. Animations

---

## Accessibility

- Minimum touch targets: 44x44px
- Screen reader: semantic labels for stats
- Reduce motion: disable count-up animations
- High contrast: increase text contrast in dark mode

---

## Future Enhancements

### Personalized Greeting

- Time-based greeting (morning/afternoon/evening)
- User name from profile
- Streak counter

### Gamification

- Daily/weekly goals
- Achievement badges
- Streak tracking

### Social

- Share haul
- Friend activity
- Leaderboard

### Insights

- Profit trends chart
- Category breakdown
- Time analysis

---

## Trend-Informed Notes (2025-2026)

Reference notes: `roadmapv2/research/dashboard_screen_research_2026.md`.

- "Bento" dashboards remain popular: staggered glass cards + a small set of headline metrics.
- Keep one primary action (scan) dominant; everything else supports it.
- Prefer spacing/typography hierarchy over divider lines.

---

## Asset Suggestions (roadmapv2/images)

- Background: `roadmapv2/images/loppis_background.png`
- Optional hero accent (very subtle): `roadmapv2/images/antique_store.png`
