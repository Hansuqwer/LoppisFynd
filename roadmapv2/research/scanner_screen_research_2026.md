# Scanner Screen Research Notes (2025-2026)

These notes feed into `roadmapv2/research/scanner_screen.md`.

## Sources Checked

- Google ML Kit: Barcode scanning overview (offline scanning, structured parsing, orientation, limits)
  - https://developers.google.com/ml-kit/vision/barcode-scanning
- Behance: barcode scanner UI patterns (frame, hint text, torch toggle, bottom tray)
  - https://www.behance.net/search/projects/barcode%20scanner%20ui

## Signals Seen

- Good scanner UIs reduce cognitive load:
  - clear scan zone
  - a single dominant capture action
  - immediate feedback (pulse/flash + haptic)
  - torch toggle available without leaving the screen
- Batch flows often use a bottom thumbnail tray with small status badges.

## What To Steal For LoppisFynd

- Add a torch control in the camera area (top-right) with a clear state.
- Use ML Kit limits to drive UX:
  - avoid trying to show >10 barcode overlays at once
  - prefer "centered barcode" behavior for speed unless user explicitly needs multi-scan
