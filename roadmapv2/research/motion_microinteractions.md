# Motion Design & Micro-interactions (Research + Recommendations)

This document captures what LoppisFynd currently does for motion, what research suggests, and what we should change for a more intentional, modern, and accessible feel.

## Sources Checked (Accessible)

- Flutter docs: animation approaches + patterns
  - https://docs.flutter.dev/ui/animations
  - https://docs.flutter.dev/ui/animations/implicit-animations
- MDN: reduced-motion preference (why it matters + patterns)
  - https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion
- Figma Help: Smart Animate principles (matching layers, dissolve fallback, supported properties)
  - https://help.figma.com/hc/en-us/articles/360039818874-Create-advanced-animations-with-Smart-Animate
- Josh Comeau (for “don’t animate expensive stuff / glass realism pitfalls”)
  - Shadows: https://www.joshwcomeau.com/css/designing-shadows/
  - Glass: https://www.joshwcomeau.com/css/backdrop-filter/

Notes:
- Material 3 motion pages and Apple HIG motion pages require JavaScript and couldn’t be fetched in this environment.

## What The App Currently Does (Inventory)

### 1) Page transitions

- `SpringRoute` (`lib/core/navigation/spring_route.dart`)
  - Fade in + small upward slide using a physics spring.
  - Used widely (dashboard/settings/drafts/history/hauls/scanner/item detail).

### 2) Press feedback (micro-interactions)

- Common pattern: scale down slightly + translate down ~1.5px + shadow swap (bento -> pressed) + ripple
  - `lib/shared/widgets/glass_button.dart`
  - `lib/shared/widgets/bento_card.dart`
  - similar in `lib/features/auth/login_screen.dart` pill buttons

### 3) Entrance reveals

- Login: implicit entrance (opacity + slide + scale) for the central glass card
  - `lib/features/auth/login_screen.dart`

### 4) Selection transitions

- Capsule nav selection uses `AnimatedContainer`
  - `lib/shared/widgets/capsule_nav_bar.dart`
- Onboarding progress dots animate size/color
  - `lib/features/onboarding/onboarding_screen.dart`
- Haul summary KPI swaps use `AnimatedSwitcher`
  - `lib/features/summary/haul_summary_screen.dart`

### 5) Scanner motion

- Scanner overlay uses an `AnimationController` repeating “breathing” scan line
  - `lib/features/scanner/widgets/scanner_overlay.dart`

### 6) Haptics

- Scanner: light/medium impacts + selection click
  - `lib/features/scanner/scanner_screen.dart`
- Settings: heavy impact for Dev Mode toggle
  - `lib/features/settings/settings_screen.dart`

## Gaps / Improvement Opportunities

### A) One curve + few durations is too blunt

`AppMotion` currently defines:
- `fast=110ms`, `normal=180ms`, `spring=450ms`, curve `easeOutCubic`

This is good as a start, but it forces the same feel for:
- press feedback
- toggles
- content changes (switcher)
- navigation transitions

Research pattern (Flutter + Figma prototyping practice): use different motion “roles” (micro vs transition vs layout change), and be explicit about which properties you animate.

### B) Reduced motion is not a first-class behavior

MDN’s `prefers-reduced-motion` guidance generalizes well to apps: scaling and large translations can trigger vestibular discomfort; provide “reduce motion” fallbacks that replace motion with dissolve/opacity changes.

Right now:
- route transitions always slide + fade
- scanner overlay always animates

### C) Some “state changes” are instantaneous or rely on SnackBars

SnackBars are useful, but for a “crafted” feel we should also animate local state changes:
- counts / metrics
- AI status changes
- batch-tray item state (captured -> processing -> identified)

Flutter docs emphasize patterns like `AnimatedSwitcher`, staggered animation, and (when needed) explicit controllers.

### D) Performance guardrails

From the glass/shadow research: avoid animating the expensive/fragile parts (blur radius, shadows, masks) frequently. Prefer transforms + opacity.

The app already avoids blur animations in most places, but we should make it an explicit rule.

## Recommendations (Concrete)

### 1) Define a motion system (small set of semantic tokens)

Add semantic motion roles in tokens (still simple, but explicit):

- `microPress`: 90-120ms, transform only
- `microToggle`: 140-180ms, transform/opacity
- `contentSwap`: 160-220ms, opacity + slight translate
- `screenEnter`: 320-450ms, fade + subtle translate (optional spring)
- `screenExit`: 220-380ms, fade (avoid reverse spring overshoot)

Keep physics-based motion for navigation, but don’t use the same spring for everything.

### 2) Reduced motion policy

Implement a single “reduce motion” predicate (platform accessibility + app setting), and apply it consistently:

- Route transitions: slide distance -> 0, keep fade
- Scanner overlay: stop repeating laser line; show static brackets only
- Count-ups: disable; swap values with `AnimatedSwitcher` fade only

### 3) Consolidate the pressable pattern

Right now, the “pressed” behavior is duplicated across multiple widgets.

Create one shared `PressableSurface` (or mixin/utility) that handles:
- pressed scale
- pressed translate
- shadow swap
- ripple (InkWell)

This lets us tune “tactile feel” in one place.

### 4) Add a few high-value continuity animations

These are cheap and improve perceived polish:

- Shared element transition (Flutter’s Hero pattern) from ItemCard image -> ItemDetail hero image.
- Batch tray item state transitions using `AnimatedSwitcher` for the badge and a subtle “pop” for completion.
- Dashboard stat changes: use `AnimatedSwitcher` per tile (already used in haul summary; apply consistently).

### 5) Motion constraints for glass

For glass surfaces:
- Don’t animate blur radius.
- Don’t animate complex multi-layer shadows.
- Prefer opacity + transform on the content layer, and keep the glass material stable.

## Suggested File Touchpoints (When Implementing)

- Token expansion: `lib/core/tokens/app_motion.dart`
- Route transition policy: `lib/core/navigation/spring_route.dart`
- Reduced motion helper: a small utility in `lib/core/accessibility/` or similar
- Scanner overlay fallback: `lib/features/scanner/widgets/scanner_overlay.dart`
- Pressable consolidation: `lib/shared/widgets/` (`glass_button.dart`, `bento_card.dart`)
