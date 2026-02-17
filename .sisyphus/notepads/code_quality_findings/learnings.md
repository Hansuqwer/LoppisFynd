# Code Quality Findings from current diffs (FyndLoppis)
- lib/services/sync/background/background_sync.dart: catch (_) in callbackDispatcher swallows exceptions; consider logging or surfacing error to aid debugging in background tasks.
- lib/scanner/scanner_screen.dart: _startBarcodeStreamIfPossible and other blocks catch (_) without logging; swallow errors can hide failures; add at least debug logs.
- lib/features/dashboard/dashboard_screen.dart: _ModelPreflightCard uses hard-coded strings "Modell nedladdad" and "Misslyckades: $e" for download errors; should be localized (l10n) for consistency.
- lib/features/settings/settings_screen.dart: Several UI strings appear in Swedish (e.g., "Utvecklarläge aktiverat") outside l10n flow; prefer localization or feature-flag gating; ensure consistency across locales.
- lib/scanner/scanner_screen.dart: Overlaid guidance text Håll
