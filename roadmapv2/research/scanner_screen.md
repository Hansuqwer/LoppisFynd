# Scanner Screen - Nature Distilled

---

## Current Implementation

**What's there:**
- Camera preview (42% screen height)
- Barcode detection (ML Kit)
- Barcode AR overlay
- Scan capture button
- Batch tray showing scanned items
- Permission handling

**Current stack:**
- `CameraPreview` from `camera` package
- `GoogleMlKitBarcodeScanning`
- `BentoCard` for UI containers
- `GlassOverlay` for camera container

---

## Proposed Redesign

### Layout Overview

```
┌─────────────────────────────────────────────┐
│  ← Back                    [⚙️] [📤]        │  <- AppBar (glass)
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │                                     │    │
│  │         CAMERA PREVIEW              │    │
│  │                                     │    │
│  │   ┌─────────────────────────┐       │    │
│  │   │   BARCODE SCAN ZONE    │       │    │  <- Scanner frame
│  │   │   (rounded rect)       │       │    │
│  │   └─────────────────────────┘       │    │
│  │                                     │    │
│  │  [Hint text overlay]                │    │
│  │                                     │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │  🤖 AI Status: Cloud   📶 Online   │    │  <- Status bar
│  └─────────────────────────────────────┘    │
│                                             │
│  [    📷 Capture    ]  [  Done  ]           │  <- Action buttons
│                                             │
│  ─────────────────────────────────────────  │
│                                             │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐       │
│  │ 📷 1 │ │ 📷 2 │ │ 📷 3 │ │ 📷 4 │  +    │  <- Batch tray
│  └──────┘ └──────┘ └──────┘ └──────┘       │
│                                             │
│  SCAN 5 ITEMS              [View All →]    │
└─────────────────────────────────────────────┘
```

---

## Components

### 1. Scanner Frame

| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| frame border | terracotta @ 60% | softTerracotta |
| corner radius | 24px | 24px |
| corner length | 32px | 32px |
| corner stroke | 3px | 3px |
| hint background | grayGreen @ 50% | softCream @ 20% |

Note: prefer ink0/ink1 from v2 ramps for text colors where possible; keep grayGreen as legacy mapping only.

**Animation:**
- Corner pulse when barcode detected
- Green flash on successful scan

---

### 2. Camera Preview

| Property | Value |
|----------|-------|
| Container | GlassSurface.medium |
| Border radius | 24px |
| Aspect ratio | 4:3 or 16:9 (configurable) |
| Safe area | respected |

**States:**
- loading: shimmer
- error: error banner with retry
- permission denied: permission request UI
- inactive: dimmed overlay

---

### 3. Status Bar

Shows current AI mode and connectivity.

```
[🤖 AI: Cloud]  [📶 Online]  [🔋 Normal]
```

| Status | Icon | Color |
|--------|------|-------|
| AI: Cloud | cloud | mutedTeal |
| AI: Offline | brain | sage |
| AI: Loading | hourglass | terracotta |
| Online | wifi | sage |
| Offline | wifi_off | dustyRose |
| Battery: Low | battery_alert | dopamineRed |

---

### 4. Capture Button

| Property | Light | Dark |
|----------|-------|------|
| Size | 72px | 72px |
| background | terracotta @ 80% | softTerracotta |
| icon | camera | camera |
| border | 4px white | 4px white |

**States:**
- default: full opacity
- capturing: scale 0.9, loading spinner
- disabled: 40% opacity

**Animation:**
- Tap: scale 0.9 → 1.0
- Success: green pulse ring

---

### 5. Batch Tray

Horizontal scrollable tray of captured items.

```
┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ 
│ img  │ │ img  │ │ img  │ │ img  │ + 
└──────┘ └──────┘ └──────┘ └──────┘
```

| Property | Value |
|----------|-------|
| item size | 64x64 |
| border radius | 12px |
| spacing | 8px |
| max visible | 5 (+ overflow indicator) |

**Item States:**
- captured: thumbnail
- processing: shimmer
- identified: category badge
- error: retry icon

**Actions:**
- tap: preview
- long press: remove
- swipe: reorder

---

### 6. AI Preflight Card (New)

When user opens scanner, show AI status (cloud + offline fallback). No downloads.

```
┌─────────────────────────────────────────┐
│ 🤖 AI Ready                              │
│ Cloud Gemini • Offline available         │
│ [AI settings]                            │
└─────────────────────────────────────────┘
```

| Property | Value |
|----------|-------|
| position | top of scanner |
| shown when | first open, offline disabled, or cloud unavailable |
| action | open `roadmapv2/research/model_manager_screen.md` |

---

## Interaction Patterns

### 1. Capture Flow

```
User taps Capture
    ↓
Show shutter animation
    ↓
Haptic feedback (medium)
    ↓
Add to batch tray (animate in)
    ↓
If AI enabled → start identification
    ↓
Show result badge on thumbnail
```

### 2. Barcode Scan Flow

```
Camera detects barcode
    ↓
Highlight barcode region (green)
    ↓
Vibrate (light)
    ↓
If auto-identify enabled → capture + identify
    ↓
Show result toast
```

### 3. Batch Review Flow

```
Tap item in tray
    ↓
Open quick preview (bottom sheet)
    ↓
Edit details / delete
    ↓
Close sheet → return to scanner
```

---

## Atmospheric Elements

### Background

Use `AtmosphericBackground` behind scanner UI:

```
Stack(
  1. AtmosphericBackground (blurred, tinted)
  2. Scanner content (camera + controls)
  3. Glass overlays
)
```

### Glass Effect

Camera preview container:

```dart
GlassSurface(
  blur: 16,
  fill: white @ 35%,
  borderRadius: 24,
  child: CameraPreview(),
)
```

---

## Animations

### Scanner Frame

| Animation | Trigger | Duration | Curve |
|-----------|---------|----------|-------|
| corner pulse | barcode detected | 300ms | easeOut |
| success flash | scan complete | 200ms | easeIn |
| error shake | scan failed | 400ms | elastic |

### Capture Button

| Animation | Trigger | Duration | Curve |
|-----------|---------|----------|-------|
| scale tap | onTapDown | 100ms | easeOut |
| scale release | onTapUp | 150ms | bounceOut |
| ring expand | capture success | 400ms | easeOut |

### Batch Tray

| Animation | Trigger | Duration | Curve |
|-----------|---------|----------|-------|
| slide in | item added | 300ms | easeOutCubic |
| slide out | item removed | 250ms | easeInCubic |
| badge pop | identification done | 200ms | bounceOut |

---

## AI Integration (Per Roadmap)

### Preflight Check

Before scanner activates:

1. Check model status
2. If cloud available: show "Cloud AI ready"
3. If offline enabled: show "Offline quick ID ready"
4. If cloud unavailable: keep offline path prominent

### Backend Selection

Per roadmap M1 (Cloud-first AI):

- Default: Cloud Gemini
- Offline quick ID: YOLOX (M2), lightweight and bundled/small optional (no multi-GB downloads)

### Identification Flow

```
Capture image
    ↓
Compress + crop
    ↓
Check settings (cloud/offline)
    ↓
Call appropriate backend
    ↓
Parse result
    ↓
Update batch item with result
    ↓
Show badge on thumbnail
```

---

## Dark Mode Considerations

| Element | Light | Dark |
|---------|-------|------|
| scanner frame | terracotta | softTerracotta |
| hint background | grayGreen @ 50% | softCream @ 20% |
| capture button | terracotta | softTerracotta |
| status text | grayGreen | softCream |

---

## Accessibility

- VoiceOver: announce scan results
- Minimum touch targets: 44x44px
- Haptic feedback for scan success
- High contrast mode for scanner frame

---

## Trend-Informed Notes (2025-2026)

Reference notes: `roadmapv2/research/scanner_screen_research_2026.md`.

- ML Kit barcode scanning is offline and fast, but recognizes a maximum of 10 barcodes per call; design UI around a primary target.
- Add a torch toggle in the camera area (top-right) to reduce failed scans in real environments.
- Keep feedback immediate: frame pulse + haptic + badge update in tray.

---

## Tokens (Color + Typography)

Use v2 ramps from `roadmapv2/research/color_palette_tokens.md` and text styles from `roadmapv2/research/typography_tokens.md`.

Color:
- background behind camera: neutral0 tint + blur
- text on glass: ink0/ink1 (light mode), softCream variants (dark)
- frame highlight: terracotta500
- status indicators: sage (online/success), mutedTeal (info), dustyRose (offline)

Typography:
- status bar: labelMedium
- hint text: bodySmall
- tray badges: labelSmall

---

## Asset Suggestions (roadmapv2/images)

- Background: `roadmapv2/images/loppis_background.png`

---

## Future Enhancements

### Multi-item Scan

- Detect multiple items in frame
- Show multiple bounding boxes
- Batch capture all detected items

### AR Overlays

- Price estimates floating on items
- Category labels
- Historical data overlay

### Continuous Scan

- Auto-capture mode
- Motion detection
- Hands-free scanning

### Sound Effects

- Shutter sound (configurable)
- Success chime
- Error tone

---

## Implementation Priority

### Phase 1 (M1 - Cloud AI)

1. Status bar component
2. AI preflight card
3. Atmospheric background integration

### Phase 2 (M2 - Offline)

4. Offline status indicator
5. Offline fallback explanation (no downloads)

### Phase 3 (UI Polish)

6. Animations
7. Sound/haptic feedback
8. Batch tray improvements
