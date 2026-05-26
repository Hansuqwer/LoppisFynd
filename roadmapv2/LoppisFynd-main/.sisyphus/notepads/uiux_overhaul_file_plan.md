## Nature Distilled UI Overhaul (2026) - File Plan

Assumption (to keep app functional): we do NOT literally replace `lib/main.dart` with the dossier demo.
`lib/main.dart` contains critical bootstrap (Supabase/Sentry/Drift/Riverpod/providers/onboarding/auth) and should remain.
We instead port the dossier UI concepts into the existing app shell (`lib/core/navigation/app_nav_shell.dart`) and the feature screens.

### New files
- `lib/shared/painters/loppis_track_painter.dart`
  - Global vector background painter ("L" track) used behind all tabs.
- `lib/shared/widgets/atmospheric_background.dart`
  - Reusable background widget: Cloud Dancer canvas + subtle Fog gradient + track painter.
- `lib/shared/widgets/capsule_nav_bar.dart`
  - Floating capsule navigation bar (glass via `BackdropFilter`) with 5 destinations.
- `lib/features/scanner/widgets/scanner_overlay.dart`
  - Custom painter overlay for scanner: corner brackets + kinetic/breathing laser line.
- `lib/features/history/widgets/coffee_cup_empty_state.dart`
  - Branded empty state: coffee cup custom painter + copy.

### Edit files
- `lib/core/navigation/app_nav_shell.dart`
  - Replace stock `NavigationBar` with `CapsuleNavBar`.
  - Wrap content in `Stack` with `AtmosphericBackground` behind all screens.
  - Keep deep-link subscriptions, offline banner, and tab switching logic.
- `lib/features/dashboard/dashboard_screen.dart`
  - Replace flat list with bento-style layout.
  - Add predictive hero tile "Start Scanner" (switch tab via `deepLinkTabIndexProvider`).
  - Add model preflight tile (surface model install/download entry point).
- `lib/features/scanner/scanner_screen.dart`
  - Add `ScannerOverlay` layer above `CameraPreview` (keep barcode AR overlay intact).
- `lib/features/history/history_screen.dart`
  - Use coffee-cup empty state when there are no hauls.
- `lib/features/settings/settings_screen.dart`
  - Add 7-tap dev mode toggle on version row.
  - Hide technical strings (e.g. `--dart-define...`, expected model path) unless dev mode is enabled.
- `test/fl_065_nav_smoke_test.dart`
  - Update expectations to the new capsule nav (keys/semantics) instead of `NavigationBar`.

### Notes
- Tokens already exist in `lib/core/tokens/*` and align with the dossier palette/typography.
- Material 3 is already enabled in `lib/core/theme/app_theme.dart`.

### Implemented (current state)
- Global atmospheric background now comes from `lib/shared/widgets/atmospheric_background.dart` + `lib/shared/painters/loppis_track_painter.dart` and is applied in `lib/core/navigation/app_nav_shell.dart`.
- Floating capsule nav is `lib/shared/widgets/capsule_nav_bar.dart` and replaced the stock `NavigationBar` in `lib/core/navigation/app_nav_shell.dart`.
- Dashboard bento/hero/preflight changes are in `lib/features/dashboard/dashboard_screen.dart`.
- Scanner overlay is `lib/features/scanner/widgets/scanner_overlay.dart` and is layered in `lib/features/scanner/scanner_screen.dart`.
- Coffee-cup empty state is `lib/features/history/widgets/coffee_cup_empty_state.dart` and is used in `lib/features/history/history_screen.dart`.
- 7-tap dev mode + hiding technical strings are in `lib/features/settings/settings_screen.dart`.
- Tests updated: `test/fl_065_nav_smoke_test.dart`, `test/widget_test.dart`.
