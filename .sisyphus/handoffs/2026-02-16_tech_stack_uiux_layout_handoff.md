HANDOFF CONTEXT
===============

USER REQUESTS (AS-IS)
---------------------
- "We are performing a visual overhaul of the LoppisFynd Flutter app.
GOAL: Replace the existing main UI with a new \"Nature Distilled\" 2026 design system.
KEY REQUIREMENTS:
1.  **Glassmorphism & Backgrounds:** Use the `Atmospheric Fog` and `Cloud Dancer` palette with a custom vector painter (`LoppisTrackPainter`) in the background of all screens.
2.  **Navigation:** Implement a floating \"capsule\" navigation bar using `BackdropFilter` that sits above the content.
3.  **Dashboard:** Replace list views with a \"Bento Grid\" layout. The primary action \"Start Scanner\" must be a large predictive hero card.
4.  **Scanner:** Add a custom painter `ScannerOverlay` with corner brackets and a kinetic \"breathing\" laser line.
5.  **Profile:** Hide technical debug info (API paths) behind a \"7-tap\" developer mode on the version number.
6.  **Empty States:** Use a custom branded \"Coffee Cup\" empty state for the History screen."
- "REFERENCE CODE:
I have provided the complete `main.dart` in the handover dossier. Please apply this code to `lib/main.dart` and ensure all dependencies (Material 3) are enabled in `pubspec.yaml`. /home/hans/HansuQWER/WorkSpace/FyndLoppis/Assets/AppLayout/UiUxOverHaul.md"
- "build apk install on my phone"
- "make a handoff about our current tech stack and ui ux layout in a pdf"
- "md is fine"

GOAL
----
Capture current tech stack + UI/UX layout (Nature Distilled overhaul) so work can be continued safely.

WORK COMPLETED
--------------
- I implemented the Nature Distilled overhaul inside the existing app shell (kept `lib/main.dart` bootstrap/providers intact instead of replacing it with a demo main).
- I added a global atmospheric background + vector track painter and render it behind all tab screens.
- I replaced the stock bottom `NavigationBar` with a floating glass capsule nav bar using `BackdropFilter`.
- I reworked Dashboard into a bento layout with a large predictive “Start Scanner” hero and a model preflight card.
- I added a scanner overlay custom painter with corner brackets + kinetic “breathing” laser + guidance copy.
- I added a coffee-cup empty state for History when there are zero hauls.
- I implemented a 7-tap developer mode on a version row; technical strings in settings are hidden unless dev mode is enabled.
- I updated widget tests that asserted the old bottom nav.
- I ran `flutter test` and fixed layout overflows; all tests passed.
- I installed a debug build to a connected Android phone using Flutter tooling.

CURRENT STATE
-------------
- Repo: Flutter app on branch `main` at commit `d2eed66`.
- Working tree is dirty (uncommitted changes) and includes new untracked files.
- `flutter test` passes (last run in this session).
- Device install: `flutter install -d R5CTA26ZWMT --debug` succeeded on `SM F721B`.
- Note: `adb` is not available on PATH in this environment, but `flutter install` still works.

PENDING TASKS
-------------
- None required for functionality; primary follow-ups are workflow:
- Decide how to commit/PR these changes (currently not committed).
- Optional: implement the “Haul: Kinetic Profit Header” concept mentioned in the later checklist (not part of the original 1-6 requirements and not implemented).
- Optional: refine capsule nav labeling strategy (currently icons-only to avoid layout overflow and keep capsule compact).

KEY FILES
---------
- lib/main.dart - App bootstrap (providers, Sentry/Supabase init, BackgroundSync, app routing gate)
- lib/core/navigation/app_nav_shell.dart - Main UI shell; atmospheric background + floating capsule nav + tabs
- lib/shared/widgets/atmospheric_background.dart - Global background widget (Cloud Dancer + fog gradient + track)
- lib/shared/painters/loppis_track_painter.dart - Vector “track” background painter
- lib/shared/widgets/capsule_nav_bar.dart - Floating capsule navigation bar (glass via BackdropFilter)
- lib/features/dashboard/dashboard_screen.dart - Bento dashboard + hero Start Scanner + model preflight card
- lib/features/scanner/scanner_screen.dart - Scanner screen; overlays ScannerOverlay above camera/AR boxes
- lib/features/scanner/widgets/scanner_overlay.dart - CustomPainter overlay (brackets + breathing laser)
- lib/features/history/widgets/coffee_cup_empty_state.dart - Branded coffee-cup empty state
- lib/features/settings/settings_screen.dart - 7-tap dev mode + hides technical strings unless enabled

IMPORTANT DECISIONS
-------------------
- I did not replace `lib/main.dart` with the dossier’s demo main; `lib/main.dart` contains critical app bootstrap (providers, Supabase/Sentry, DB, background sync) and replacing it would break the app wiring.
- Capsule nav is implemented as a floating glass bar with icons only (and a primary Scan affordance) to keep the capsule compact and avoid render overflows in small layouts/tests.
- I modified `lib/shared/widgets/glass_button.dart` to be robust under constrained widths (avoid RenderFlex overflow in widget tests).

EXPLICIT CONSTRAINTS
--------------------
- "Implement the Loppisfynd app exactly as described in `docs/roadmap_refactored(1).md`."
- "Do NOT add features that are not in the roadmap."
- "Keep changes small: one ticket (FL-xxx) per PR/commit series."
- "Prefer feature-first architecture: do not create “mega” folders."
- "Never commit secrets. Supabase/Tradera keys must be read from env or Supabase Vault."
- "Keep the app offline-first: everything must function without internet except price fetch."
- "Use AppTokens for all colors/radius/spacing."
- "Prefer Bento cards, soft shadows, 24px radii."
- "Keep motion springy and tactile; avoid harsh/linear transitions."

CONTEXT FOR CONTINUATION
------------------------
- Tech stack quick map:
  - Flutter 3.38.9 / Dart 3.10.8 (see `flutter --version`)
  - State management: Riverpod (`lib/core/app/providers.dart`)
  - Local DB: Drift (`lib/core/database/app_database.dart` + DAOs/tables)
  - Offline-first + background: Workmanager (`lib/services/sync/background/background_sync.dart`)
  - Auth/sync backend: Supabase (optional, gated by `AppConfig.hasSupabase`)
  - Crash/analytics: Sentry (optional, gated by `AppConfig.hasSentry`)
  - Scanner: `camera` + `google_mlkit_barcode_scanning` (`lib/features/scanner/`)
  - On-device AI: ModelManager + isolate inference service (`lib/services/ai/`)
  - Localization: generated `lib/gen/app_localizations*.dart`
- Runtime config is passed via `--dart-define` and read in `lib/core/config/app_config.dart`.
- Dev mode: tap the version row 7 times in Settings/Profile to toggle; technical strings are only shown when enabled.
- If continuing with releases: add `adb` to PATH or rely on `flutter install`; for production you’ll need signed `--release` builds.
- Session metadata: The OpenCode `session_read` tool could not find the user-provided session id in this environment; this handoff relies on git status/diff + direct file inspection.

Additional inventory (from internal repo scan)
--------------------------------------------
- State management: Riverpod (`flutter_riverpod`) via `lib/core/app/providers.dart`
- Offline-first DB: Drift (`drift`, `drift_flutter`, `sqlite3_flutter_libs`) via `lib/core/database/app_database.dart`
- Auth/cloud: Supabase (`supabase_flutter`) init in `lib/main.dart`, session stream in `lib/core/app/providers.dart`, cloud sync via `lib/services/sync/cloud/`
- Crash/analytics: Sentry (`sentry_flutter`) init in `lib/main.dart`, analytics wrapper `lib/services/analytics/analytics_service.dart`
- Scanner: `camera` + `google_mlkit_barcode_scanning` via `lib/features/scanner/scanner_screen.dart`
- Background jobs: Workmanager (`workmanager`) via `lib/services/sync/background/background_sync.dart`
- Notifications: `flutter_local_notifications` via `lib/services/notifications/app_notifications.dart`
- AI: `flutter_gemma` + `lib/services/ai/model_manager.dart` + `lib/services/ai/inference/inference_isolate_service.dart` (inference off UI thread)
- Localization: `flutter_localizations` + generated `lib/gen/app_localizations*.dart` + config in `l10n.yaml`
- Fonts: bundled assets (Outfit, Space Grotesk, Homemade Apple) configured in `pubspec.yaml`; GoogleFonts runtime fetching disabled in `lib/main.dart`

UI/UX layout architecture (current)
---------------------------------
- App shell: `lib/core/navigation/app_nav_shell.dart`
  - Background: `lib/shared/widgets/atmospheric_background.dart` + `lib/shared/painters/loppis_track_painter.dart`
  - Floating nav: `lib/shared/widgets/capsule_nav_bar.dart` (icons-only, primary Scan)
  - Transitions: `lib/core/navigation/spring_route.dart`
- Shared design components:
  - Tokens: `lib/core/tokens/app_tokens.dart` (colors/motion/radius/shadows/spacing/typography)
  - Theme: `lib/core/theme/app_theme.dart` (Material 3, light + highContrast)
  - BentoCard: `lib/shared/widgets/bento_card.dart`
  - GlassButton: `lib/shared/widgets/glass_button.dart` (constrained-layout safe)
  - GlassOverlay: `lib/shared/widgets/glass_overlay.dart`
