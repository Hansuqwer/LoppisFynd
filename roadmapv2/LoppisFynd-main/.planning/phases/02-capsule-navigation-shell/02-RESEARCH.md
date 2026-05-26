# Phase 02: Capsule Navigation Shell - Research

**Researched:** 2026-02-18
**Domain:** Flutter navigation shell (5 tabs) + persistent tab state + custom capsule bottom nav
**Confidence:** MEDIUM

## User Constraints

No Phase 2 `*-CONTEXT.md` exists yet. Constraints below come from the phase prompt + Phase 1 decisions.

- Preserve `AppRadius.pill` semantics (`999.0`) and `AppRadius.capsule` (`30.0`).
- Avoid `ThemeData`-wide overrides that drift goldens; keep changes additive via tokens.
- Keep `GlassOverlay` API stable; prefer `GlassSurface`/`GlassBoard` for new screens.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| NAV-01 | Tabs remain exactly: Home, Scan, Haul, History, Profile (no navigation regression). | Keep existing routes (`/home`, `/scan`, `/haul`, `/history`, `/profile`) in `lib/main.dart` and keep tab order/keys in `lib/core/navigation/app_nav_shell.dart` + `lib/shared/widgets/capsule_nav_bar.dart`. |
| NAV-02 | App shell uses persistent Nature Distilled background + capsule nav and keeps tab state alive (e.g., `IndexedStack`). | Replace the current `switch (_tab)` rebuild in `lib/core/navigation/app_nav_shell.dart` with a keep-alive tab host (`IndexedStack`), but do it lazily to avoid eager initialization of heavy tabs (scanner/camera). |
| NAV-03 | Capsule nav shows an explicit selected “bubble” state consistent with the Visual Reference Pack. | Update `lib/shared/widgets/capsule_nav_bar.dart` so *all* destinations (including the primary Scan item) have a clearly distinct selected vs unselected bubble state; keep existing keys for tests. |
</phase_requirements>

## Summary

The app already has an `AppNavShell` and a `CapsuleNavBar`, plus a persistent Nature background (`NatureBackground` wraps `AtmosphericBackground`). However, tab switching is currently implemented with a `switch (_tab)` that removes the previous tab subtree from the widget tree, so scroll positions, text inputs, and stateful controllers reset when you change tabs. Phase 2 is primarily about turning the existing shell into a real “keep-alive” tab host while preserving the existing 5-tab contract and deep-link route names.

The main implementation risk is resource-heavy tabs: `ScannerScreen` eagerly initializes the camera in `didChangeDependencies()` and uses `WidgetsBindingObserver` only for app lifecycle, not tab visibility. If Phase 2 switches to an eager `IndexedStack(children: [...])`, the scanner will attempt camera init on app start (including in widget tests), and if kept alive it may keep the camera running while offstage. The shell should therefore be implemented as a *lazy* keep-alive stack (build tab on first visit, then keep it) and provide an “active tab” signal so the scanner can pause/release resources when not selected.

**Primary recommendation:** Implement a lazy cached `IndexedStack` in `lib/core/navigation/app_nav_shell.dart`, compute bottom insets from `CapsuleNavBar` metrics (remove the hardcoded `108`), and update `lib/shared/widgets/capsule_nav_bar.dart` so the selected bubble state is explicit for every tab (including the primary Scan tab).

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter `Navigator` (Navigator 1.0) | (SDK) | App routing and pushes | Current app uses `MaterialApp(onGenerateRoute: ...)` with named paths in `lib/main.dart`. |
| `flutter_riverpod` | ^2.6.1 | App state + deep-link signals | `AppNavShell` listens to `deepLinkTabIndexProvider`/`deepLinkScanItemIdProvider`. |
| `IndexedStack` | (SDK) | Keep tab subtree state alive | Flutter API explicitly notes `IndexedStack` keeps children state while showing one child. |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `lucide_icons` | ^0.257.0 | Capsule nav icons | Already used in `lib/core/navigation/app_nav_shell.dart`. |
| `flutter_animate` | ^4.5.2 | Screen entry animations | Used in `DashboardScreen`; disable tickers for inactive tabs to avoid background animation work. |
| `camera` | ^0.11.3+1 | Scanner camera | Must be paused/released on tab deactivation if scanner stays alive. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Single-Navigator + tab content swap | Nested `Navigator` per tab | Better per-tab back stacks, but higher regression risk (route behavior changes), more plumbing for deep links. Not required by NAV-01..03. |

## Architecture Patterns

### Recommended Project Structure (existing)
```
lib/
├── core/navigation/            # app shell + transitions
├── shared/widgets/             # capsule nav + background primitives
├── core/tokens/                # AppRadius/AppSpacing/AppShadows/etc.
└── features/<feature>/         # screens (dashboard/scanner/haul/history/settings)
```

### Pattern 1: Lazy Keep-Alive Tab Host (Cached IndexedStack)

**What:** Keep previously visited tabs mounted to preserve widget state, but avoid building all 5 tabs immediately.

**When to use:** When one tab does expensive initialization (camera/map streams) and you need state preservation after first visit.

**Why this phase needs it:** `ScannerScreen` attempts camera init in `didChangeDependencies()`. Eagerly building it via `IndexedStack(children: [...])` can cause startup/test failures and background resource usage.

**Example (Dart):**
```dart
// Source: https://api.flutter.dev/flutter/widgets/IndexedStack-class.html
// Pattern adapted to this repo (AppTab order must remain stable).

class _TabCache {
  final _built = <int, Widget>{};
  Widget getOrBuild(int index, Widget Function() builder) {
    return _built.putIfAbsent(index, builder);
  }
}

// In AppNavShell State:
final _cache = _TabCache();

Widget _buildTab(int i) {
  return _cache.getOrBuild(i, () {
    return switch (AppTab.values[i]) {
      AppTab.dashboard => const DashboardScreen(),
      AppTab.scanner => const ScannerScreen(/* see Pattern 2 for "active" */),
      AppTab.haul => const HaulScreen(),
      AppTab.history => const HistoryScreen(),
      AppTab.profile => const SettingsScreen(),
    };
  });
}

@override
Widget build(BuildContext context) {
  return IndexedStack(
    index: _index,
    children: List.generate(AppTab.values.length, (i) {
      final selected = i == _index;
      return TickerMode(
        // Source: https://api.flutter.dev/flutter/widgets/TickerMode-class.html
        enabled: selected,
        child: _buildTab(i),
      );
    }),
  );
}
```

### Pattern 2: Tab Visibility Signal for Resource Tabs (Scanner)

**What:** Provide the currently selected tab to tabs that need to pause/resume resources (camera, streams).

**When to use:** Any keep-alive tab that should stop work when not visible.

**Implementation note:** `Offstage`/`IndexedStack` do not stop animations/resources automatically. Flutter docs explicitly warn Offstage children remain active and animations keep running; pair with `TickerMode` for animations, and add explicit pause/resume for non-animation resources.

**Example (Dart):**
```dart
// Source: https://api.flutter.dev/flutter/widgets/Offstage-class.html
// (Offstage warns inactive children are still active; tab visibility needs explicit handling.)

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key, required this.active});
  final bool active;
  // ...existing fields...
}

// In _ScannerScreenState.didUpdateWidget:
@override
void didUpdateWidget(covariant ScannerScreen oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.active != widget.active) {
    if (!widget.active) {
      _controller?.dispose();
      _controller = null;
      // (Optional) stop image stream / close scanners if held.
    } else {
      _initCameraIfNeeded();
    }
  }
  _syncOverlayListenable();
}
```

### Pattern 3: Single Source of Truth for Capsule Insets

**What:** Compute shell bottom padding from the capsule bar’s actual height + bottom margin (including safe-area padding), rather than hardcoding `108`.

**Why:** `lib/core/navigation/app_nav_shell.dart` currently pads content with `EdgeInsets.only(bottom: 108)` while `lib/shared/widgets/capsule_nav_bar.dart` computes its own bottom margin from `MediaQuery.paddingOf(context).bottom`. This can drift across devices and complicate future nav tweaks.

**Prescriptive approach:** Extract a small helper (token or function) that returns:

- `capsuleMarginBottom(context)` (same logic used by `CapsuleNavBar`)
- `capsuleObstructionHeight(context) = AppCapsuleNav.barHeight + capsuleMarginBottom(context)`

Use the obstruction height for content bottom padding in the shell.

### Anti-Patterns to Avoid

- **Eager IndexedStack children:** building all tabs at once can initialize the camera/map at startup and break widget tests.
- **Keep-alive without resource pausing:** camera/image streams can continue when tab is offstage; `TickerMode` only addresses animations.
- **Changing tab order/keys:** `test/fl_065_nav_smoke_test.dart` depends on `Key('nav_*')` and `Key('capsule_nav')` and expects specific titles to appear when tapping.
- **Theme-wide style overrides:** violates Phase 1 constraints and risks golden drift; keep capsule styling token-based.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| “Keep tab state alive” | Manual state persistence / serialization | `IndexedStack` + lazy caching | Keeps widget subtree alive with minimal complexity; proven pattern in Flutter SDK docs. |
| Safe-area/notch handling | Device-model heuristics | `SafeArea` / `MediaQuery.padding` | Flutter provides correct OS insets across platforms. |
| Animation pausing | Custom global animation manager | `TickerMode` | Built-in mechanism to disable tickers in inactive subtrees. |

**Key insight:** The hard part of this phase is not navigation APIs; it is *resource management* (camera) and *layout correctness* (capsule obstruction + safe insets) while keeping existing route and test contracts unchanged.

## Common Pitfalls

### Pitfall 1: Scanner Camera Initializes at App Start
**What goes wrong:** Switching to `IndexedStack(children: [all tabs])` builds `ScannerScreen` immediately; it calls `_initCameraIfNeeded()` from `didChangeDependencies()`, which may fail or hang in tests/simulators.

**Why it happens:** IndexedStack keeps all children in the tree; they still build.

**How to avoid:** Implement lazy caching (build on first selection) and/or gate scanner init behind `active == true`.

**Warning signs:** Widget tests start failing before any nav taps (especially `test/fl_065_nav_smoke_test.dart`).

### Pitfall 2: Camera/Streams Keep Running Offstage
**What goes wrong:** After visiting Scan, switching away keeps the scanner mounted; camera continues streaming in the background.

**Why it happens:** Offstage/IndexedStack do not dispose widgets; lifecycle observers only cover app lifecycle.

**How to avoid:** Pass an `active` flag (or similar) to scanner; dispose/stop streams when inactive; re-init on active.

**Warning signs:** Battery drain, camera busy errors when returning, or unexpected CPU usage.

### Pitfall 3: Selected Bubble Not Explicit for Primary Destination
**What goes wrong:** The Scan destination is marked `isPrimary: true` and currently renders with an accent fill regardless of `selected`, which can make it appear selected even when another tab is active.

**Why it happens:** In `lib/shared/widgets/capsule_nav_bar.dart`, the `isPrimary` branch ignores `selected` for background/border.

**How to avoid:** Ensure the active tab has a clearly distinct bubble state for *every* destination, including the primary item. Keep radii tokenized (`AppRadius.pill`/`AppRadius.capsule`).

**Warning signs:** Visually ambiguous selection, failing NAV-03 review against the reference pack.

### Pitfall 4: Content Obscured by Capsule (Insets Drift)
**What goes wrong:** A hardcoded bottom padding (`108`) doesn’t match the actual bar margin on devices with bottom insets, or after capsule styling tweaks.

**Why it happens:** Content padding and nav margin are computed in different places.

**How to avoid:** Centralize capsule obstruction calculation and reuse it for body padding.

## Code Examples

Verified patterns from official sources (adapted for this codebase):

### Keep Tab State with IndexedStack
```dart
// Source: https://api.flutter.dev/flutter/widgets/IndexedStack-class.html
// Key point: children remain in the tree and keep their state.

IndexedStack(
  index: selectedIndex,
  children: tabs,
)
```

### Disable Animations in Inactive Tabs
```dart
// Source: https://api.flutter.dev/flutter/widgets/TickerMode-class.html

TickerMode(
  enabled: isActive,
  child: tab,
)
```

### Safe Insets via SafeArea
```dart
// Source: https://api.flutter.dev/flutter/widgets/SafeArea-class.html

SafeArea(
  // Note: shell may choose bottom: false and handle capsule obstruction itself.
  child: child,
)
```

## State of the Art

| Old Approach (current) | Current Approach (recommended) | When Changed | Impact |
|------------------------|--------------------------------|--------------|--------|
| `switch (_tab)` swaps a single widget | Lazy cached `IndexedStack` keeps visited tabs alive | Phase 2 | Preserves scroll/input state; removes rebuild resets. |
| Offstage children keep animating | Wrap each tab with `TickerMode(enabled: selected)` | Phase 2 | Prevents invisible animations consuming CPU/battery. |
| No “tab active” concept | Pass `active` to scanner (and any future resource tabs) | Phase 2 | Prevents camera running while not selected. |

## Open Questions

1. **Primary Scan styling when unselected (NAV-03):**
   - What we know: Scan is marked `isPrimary: true` and currently looks “selected” even when inactive.
   - What's unclear: In the Visual Reference Pack, is the center Scan capsule always accent-filled, or only when selected?
   - Recommendation: Implement a *secondary* selected affordance (e.g., ring/halo/inner glass bubble) that toggles with `selected` while preserving the primary prominence.

2. **Keyboard behavior with capsule nav:**
   - What we know: CapsuleNavBar uses `MediaQuery.paddingOf(context).bottom`, not `viewInsets`, so it likely stays behind the keyboard.
   - What's unclear: Should the capsule float above the keyboard on text entry screens?
   - Recommendation: Keep current behavior for v1 unless the reference pack shows otherwise; ensure form fields can scroll above the capsule obstruction.

## Sources

### Primary (HIGH confidence)
- Flutter API: `IndexedStack` https://api.flutter.dev/flutter/widgets/IndexedStack-class.html
- Flutter API: `Offstage` https://api.flutter.dev/flutter/widgets/Offstage-class.html
- Flutter API: `TickerMode` https://api.flutter.dev/flutter/widgets/TickerMode-class.html
- Flutter API: `SafeArea` https://api.flutter.dev/flutter/widgets/SafeArea-class.html

### Repo (code-as-source)
- `lib/core/navigation/app_nav_shell.dart` (current shell + tab switching)
- `lib/shared/widgets/capsule_nav_bar.dart` (capsule nav visuals + selected state)
- `lib/main.dart` (named routes: `/home`, `/scan`, `/haul`, `/history`, `/profile`)
- `test/fl_065_nav_smoke_test.dart` (contract: keys + tab switching expectations)
- `lib/features/scanner/scanner_screen.dart` (camera init + lifecycle handling)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - based on repo + Flutter API docs.
- Architecture: MEDIUM - keep-alive patterns are standard, but final chosen details depend on scanner behavior + reference-pack review.
- Pitfalls: HIGH - derived from current scanner implementation + Flutter Offstage/TickerMode behavior.

**Research date:** 2026-02-18
**Valid until:** 2026-03-20 (30 days; Flutter APIs stable, but visual reference interpretation may change once reviewed)
