# Phase 02-01 Summary (Capsule Navigation Shell)

Date: 2026-02-18

Completed work:
- Refactored `AppNavShell` to a lazy keep-alive `IndexedStack` so switching tabs preserves in-tab state.
- Centralized capsule obstruction height in `CapsuleNavBar` and derived shell bottom padding from it (removed `108` magic padding).
- Switched the shell background to the contract widget `NatureBackground`.
- Added an `active` flag to `ScannerScreen` and release/re-init camera resources on tab activation changes (prevents offstage camera work).

Files changed:
- `lib/core/navigation/app_nav_shell.dart`
- `lib/shared/widgets/capsule_nav_bar.dart`
- `lib/features/scanner/scanner_screen.dart`

Verification:
- `flutter test test/fl_065_nav_smoke_test.dart` (PASS)
- `flutter analyze` (PASS)
- `flutter pub run custom_lint` (PASS)
- `flutter test` (PASS)

Notes:
- The keep-alive host is lazy: non-selected tabs start as placeholders and are only built after first selection.
