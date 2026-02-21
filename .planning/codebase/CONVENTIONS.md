# Coding Conventions

**Analysis Date:** 2026-02-21

## Naming Patterns

**Files:**
- Use `snake_case.dart` for file names across `lib/` and `test/` (e.g. `lib/services/sync/sync_scheduler.dart`, `lib/core/theme/app_theme.dart`).
- Use descriptive suffixes for UI and domain types:
  - Screens: `*_screen.dart` (e.g. `lib/features/auth/login_screen.dart`, `lib/features/dashboard/dashboard_screen.dart`).
  - Widgets: `widgets/*.dart` (e.g. `lib/features/model_manager/widgets/model_download_card.dart`, `lib/shared/widgets/error_banner.dart`).
  - Services: `*_service.dart` (e.g. `lib/services/analytics/analytics_service.dart`, `lib/services/privacy/local_data_deletion_service.dart`).
  - DAOs: `*_dao.dart` / `daos/*.dart` (e.g. `lib/core/database/daos/scan_items_dao.dart`).

**Functions:**
- Use `lowerCamelCase` for methods/functions; private helpers are prefixed with `_` (e.g. `_bootstrapAndRun` in `lib/main.dart`, `_retryDelay` in `lib/services/market/tradera_client.dart`).

**Variables/Constants:**
- Prefer `final` for runtime values and `const` for compile-time constants.
- Use `k...` / `_k...` for constant keys (e.g. `kGemmaConsentKeyV1` in `lib/services/ai/model_install_controller.dart`, `_kLastEmail` in `lib/features/auth/login_screen.dart`).

**Types:**
- Use `PascalCase` for classes, and prefix private classes/enums with `_` when file-local (e.g. `_RetryableHttpStatus` in `lib/services/market/tradera_client.dart`, `_AuthMode` in `lib/features/auth/login_screen.dart`).
- Use “static token containers” as `abstract final class` with `static const` members (e.g. `lib/core/tokens/app_colors.dart`, `lib/core/tokens/app_typography.dart`).

## Code Style

**Formatting:**
- Format is enforced in CI with `dart format --output=none --set-exit-if-changed lib test` (`.github/workflows/ci.yml`).
- Use trailing commas so `dart format` produces stable diffs (common in widget trees; see `lib/features/auth/login_screen.dart`).

**Immutability:**
- Prefer `const` constructors and `const` widgets where possible (e.g. `const AppConfig(...)` in `lib/main.dart`; token constants in `lib/core/tokens/app_colors.dart`).

**Modern Dart features:**
- Use sealed class hierarchies for state/result unions (manual “freezed-like” pattern) (e.g. `sealed class ModelInstallControllerState` in `lib/services/ai/model_install_controller.dart`, `sealed class SyncEvent` in `lib/services/sync/sync_events.dart`).
- Use `switch` expressions where it reads cleaner (e.g. decoration switch in `lib/features/auth/login_screen.dart`).

**Dependency injection (testability):**
- Pass dependencies as constructor parameters with sensible defaults (e.g. `SyncScheduler` in `lib/services/sync/sync_scheduler.dart`, `TraderaClient` in `lib/services/market/tradera_client.dart`).
- Define small interfaces for time/external calls so they can be faked (e.g. `Clock` in `lib/core/time/clock.dart`, `MarketDataSource` in `lib/services/market/market_data_source.dart`).

## Linting

**Analyzer base:**
- `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml` and enables the `custom_lint` plugin.

**Custom guardrail lints (project-specific):**
- Custom lint plugin lives in `packages/fynd_loppis_lints/` and is wired via `fynd_loppis_lints` + `custom_lint` in `pubspec.yaml`.
- Run locally with `flutter pub run custom_lint` (also enforced in CI: `.github/workflows/ci.yml`).

**Guardrails enforced by custom lint rules:**
- `no_hardcoded_ui_strings`: Avoid hardcoded user-facing strings in `lib/` and use `AppLocalizations` instead; generated localization files are excluded (`packages/fynd_loppis_lints/lib/src/no_hardcoded_ui_strings.dart`, `lib/gen/app_localizations.dart`).
- `no_raw_backdrop_filter`: Don’t instantiate `BackdropFilter` directly outside shared glass primitives; use the shared widgets instead (`packages/fynd_loppis_lints/lib/src/no_raw_backdrop_filter.dart`, `lib/shared/widgets/glass_overlay.dart`, `lib/shared/widgets/glass_surface.dart`).
- `no_ad_hoc_design_constants`: In shared UI primitives, avoid raw numeric literals in `EdgeInsets`, `BoxShadow`, and `ImageFilter.blur`; prefer design tokens (`packages/fynd_loppis_lints/lib/src/no_ad_hoc_design_constants.dart`, tokens in `lib/core/tokens/`).

## Import Organization

**Order:**
1. `dart:` imports
2. blank line
3. external `package:` imports
4. blank line
5. internal imports

**Internal imports:**
- `lib/` code commonly uses relative imports for internal modules (e.g. `lib/services/sync/sync_scheduler.dart`, `lib/core/app/providers.dart`).
- Tests use `package:fynd_loppis/...` imports for app code (e.g. `test/widget_test.dart`, `test/services_market/fl_041_tradera_client_test.dart`).

## Error Handling

**UI flows:**
- Catch typed exceptions first (e.g. `AuthException`) and fall back to a localized generic error (e.g. `_formatAuthError` + snackbars in `lib/features/auth/login_screen.dart`).
- Use `mounted` checks before calling `setState` after awaits (common throughout `lib/features/auth/login_screen.dart`, `lib/main.dart`).

**Best-effort operations:**
- Swallow errors for non-critical startup/background work (e.g. model install kickoff in `lib/main.dart`, seed attempt in `lib/services/sync/cloud/cloud_sync_coordinator.dart`).

**Retry/backoff:**
- Implement explicit retry loops with exponential backoff for network calls; retry only on transient conditions (e.g. `TraderaClient.searchEnded` retries on 429/5xx/timeouts/socket/client exceptions in `lib/services/market/tradera_client.dart`).

**State and persistence:**
- Persist errors as `toString()` where needed for user visibility/diagnostics (e.g. `lastError` stored via `scanItemSyncStatesDao.upsert` in `lib/services/sync/sync_scheduler.dart`, `entitySyncStatusesDao.set` in `lib/services/sync/cloud/cloud_sync_coordinator.dart`).

**Fail-fast on misuse:**
- Use `StateError` for programmer errors and “must be overridden” dependencies (e.g. `_uninitialized` provider helper in `lib/core/app/providers.dart`).

## Logging

**Framework:**
- Sentry is integrated centrally via `SentryFlutter.init` + `runZonedGuarded` in `lib/main.dart`.
- Analytics is modeled as a minimal service that writes Sentry breadcrumbs when enabled (see `lib/services/analytics/analytics_service.dart`).

**Patterns:**
- Prefer no logging in normal flows.
- Use `debugPrint` sparingly in catch-all branches where there is no better surface (e.g. auth error fallbacks in `lib/features/auth/login_screen.dart`).

## Comments

**When to comment:**
- Use short doc comments for “why” on non-obvious primitives and token files (e.g. `lib/core/tokens/app_colors.dart`, `lib/shared/widgets/glass_surface.dart`).
- Use `NOTE:` for design-system constraints and future wiring hints (e.g. dark theme note in `lib/core/theme/app_theme.dart`).

## Function Design

**Async:**
- Use `Future<void>` for commands; return values for queries.
- Use fire-and-forget only when explicitly non-blocking, and wrap with `unawaited(...)` (e.g. `lib/main.dart`).

**Small helpers:**
- Extract private helpers for repeated bits (e.g. `_dayKey`/`_backoff` in `lib/services/sync/sync_scheduler.dart`).

## Module Design

**Barrel files:**
- Use `lib/core/tokens/app_tokens.dart` as the single import for design tokens; it re-exports the token files.

**Generated code:**
- Treat these as generated/owned by tooling and avoid manual edits:
  - Drift: `lib/core/database/app_database.g.dart` and DAO mixes under `lib/core/database/daos/*.g.dart`
  - Localization: `lib/gen/app_localizations*.dart` and `lib/l10n/app_localizations*.dart`

---

*Convention analysis: 2026-02-21*
