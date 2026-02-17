# Coding Conventions

**Analysis Date:** 2026-02-17

## Naming Patterns

**Files:**
- Use `snake_case.dart` for Dart files (examples: `lib/services/market/tradera_client.dart`, `lib/core/text/keyword_query_sanitizer.dart`).
- Test files end with `_test.dart` (examples: `test/fl_010_database_test.dart`, `test/features_auth/login_screen_widget_test.dart`).
- Generated code uses `*.g.dart` and is referenced with `part` directives (example: `lib/core/database/app_database.dart`).

**Functions:**
- Use `lowerCamelCase` for top-level functions and methods (examples: `sanitizeKeywordQuery` in `lib/core/text/keyword_query_sanitizer.dart`, `syncOnce` in `lib/services/sync/sync_scheduler.dart`).
- Use leading `_` for private helpers (examples: `_dayKey`, `_backoff` in `lib/services/sync/sync_scheduler.dart`, `_retryDelay` in `lib/services/market/tradera_client.dart`).

**Variables:**
- Use `lowerCamelCase` for locals/fields and leading `_` for private fields (examples: `_db`, `_market` in `lib/services/sync/sync_scheduler.dart`, `_client` in `lib/features/auth/email_otp_auth.dart`).

**Types:**
- Use `PascalCase` for classes/enums (examples: `TraderaClient` in `lib/services/market/tradera_client.dart`, `AppTab` in `lib/core/navigation/app_nav_shell.dart`).
- Use leading `_` for private classes and exceptions (examples: `_RetryableHttpStatus` in `lib/services/market/tradera_client.dart`, `_NoMarketData` in `lib/services/sync/sync_scheduler.dart`).
- Riverpod providers use a `...Provider` suffix (examples: `appDatabaseProvider`, `isOnlineProvider` in `lib/core/app/providers.dart`).

## Code Style

**Formatting:**
- Use `dart format` / IDE formatting; code matches standard Dart formatting (examples throughout `lib/`).
- Prefer `const` where possible (examples: `const LoppisfyndApp()` in `lib/main.dart`, `const _NoMarketData()` in `lib/services/sync/sync_scheduler.dart`).

**Linting:**
- Base lint set is `package:flutter_lints/flutter.yaml` via `analysis_options.yaml`.
- Generated files suppress lints via `// ignore_for_file: type=lint` (examples: `lib/gen/app_localizations.dart`, `lib/core/database/app_database.g.dart`).

## Import Organization

**Order:**
1. Dart SDK imports (`dart:*`) (example: `lib/services/market/tradera_client.dart`).
2. Third-party package imports (`package:*`) (examples: `lib/main.dart`, `lib/core/app/providers.dart`).
3. Project imports:
   - Within `lib/`, relative imports are common (examples: `lib/services/sync/sync_scheduler.dart`, `lib/shared/widgets/capsule_nav_bar.dart`).
   - In tests, `package:fynd_loppis/...` imports are common (examples: `test/widget_test.dart`, `test/fl_010_database_test.dart`).

**Path Aliases:**
- Not applicable (Dart uses `package:` imports rather than TS-style aliases). Package name is `fynd_loppis` (see `pubspec.yaml`).

## Error Handling

**Patterns:**
- Validate inputs early and throw domain exceptions with stable codes/messages (example: `EmailOtpAuth.sendOtp` throws `EmailOtpAuthException` in `lib/features/auth/email_otp_auth.dart`).
- Use `StateError` for invariants/missing required wiring (examples: `_uninitialized` in `lib/core/app/providers.dart`, DAO state checks in `lib/core/database/daos/scan_items_dao.dart`).
- Use `try/catch` with `rethrow` to preserve stack traces after cleanup (examples: retry loop in `lib/services/market/tradera_client.dart`, cleanup in `lib/services/ai/model_manager.dart`).
- Best-effort behavior: swallow exceptions when work should not block startup (example: model download guarded by `try { ... } catch (_) {}` in `lib/main.dart`).

## Logging

**Framework:**
- Sentry is the primary error reporting mechanism when configured (example initialization in `lib/main.dart`).
- Analytics events are abstracted behind `AnalyticsService` (example: `lib/services/analytics/analytics_service.dart`) and used for measuring operations (example: `_analytics.measure` in `lib/services/sync/sync_scheduler.dart`).

**Patterns:**
- Avoid `print`/`debugPrint` in production code; errors are routed through Sentry when enabled (example: `runZonedGuarded` + `Sentry.captureException` in `lib/main.dart`).

## Comments

**When to Comment:**
- Use short comments to explain non-obvious intent (examples: offline-first font note in `lib/main.dart`, deep-link skeleton notes in `lib/core/app/providers.dart` and `lib/core/navigation/app_nav_shell.dart`).

**JSDoc/TSDoc:**
- Not applicable. Use Dart doc comments (`///`) for public APIs when needed (example: `EmailOtpAuth` doc comment in `lib/features/auth/email_otp_auth.dart`).

## Function Design

**Size:**
- Keep logic in small, testable units; extract helpers for formatting/backoff/retry (examples: `_dayKey` and `_backoff` in `lib/services/sync/sync_scheduler.dart`, `_retryDelay` in `lib/services/market/tradera_client.dart`).

**Parameters:**
- Prefer named parameters with `required` for injected dependencies and key inputs (examples: `SyncScheduler` constructor in `lib/services/sync/sync_scheduler.dart`, `TraderaClient` constructor in `lib/services/market/tradera_client.dart`).
- Use optional injected dependencies for testability (examples: `Clock clock = const SystemClock()` in `lib/services/sync/sync_scheduler.dart`, `http.Client? httpClient` in `lib/services/market/tradera_client.dart`).

**Return Values:**
- Use `Future<T>` for async operations and `Stream<T>` for continuous state (examples: provider streams in `lib/core/app/providers.dart`, sync events stream in `lib/services/sync/sync_scheduler.dart`).

## Module Design

**Exports:**
- Import concrete files directly; no barrel files detected under `lib/`.

**Barrel Files:**
- Not used (no `index.dart`/`exports.dart` patterns detected under `lib/`).

---

*Convention analysis: 2026-02-17*
