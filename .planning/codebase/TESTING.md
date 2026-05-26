# Testing Patterns

**Analysis Date:** 2026-02-21

## Test Framework

**Runner:**
- `flutter_test` (Flutter’s built-in test runner)
- CI runs `flutter test` (`.github/workflows/ci.yml`)

**Assertion Library:**
- `package:flutter_test/flutter_test.dart` matchers (e.g. `expect`, `expectLater`, `findsOneWidget`, stream matchers)

**Run Commands:**
```bash
flutter test                         # Run all tests
flutter test --update-goldens        # Update golden snapshots
flutter test --coverage              # Generate coverage/lcov.info (not enforced in CI)
dart format --output=none --set-exit-if-changed lib test  # Format check (CI)
flutter analyze                      # Static analysis (CI)
flutter pub run custom_lint          # Custom guardrail lints (CI)
```

## Test File Organization

**Location:**
- Tests live under `test/` (no `integration_test/` detected).

**Naming:**
- Standard Dart/Flutter: `*_test.dart`
- Scenario-indexed tests in repo root: `test/fl_###_*_test.dart` (e.g. `test/fl_010_database_test.dart`, `test/fl_070_offline_core_screens_smoke_test.dart`).
- Feature/service grouping directories are also used:
  - Features: `test/features_auth/`, `test/features_dashboard/`, `test/features_history/`, `test/features_drafts/`
  - Note: a second pattern exists for settings: `test/features_settings/` and `test/features/settings/`
  - Services: `test/services_ai/`, `test/services_market/`, `test/services_sync/`, `test/services_analytics/`

## Test Structure

**Suite organization:**
```dart
void main() {
  group('FeatureOrType', () {
    setUp(() {
      // optional global setup
    });

    testWidgets('does something in the UI', (tester) async {
      // pump
      // interact
      // expect
    });

    test('does something in pure Dart', () async {
      // arrange/act/assert
    });
  });
}
```

**Patterns used in this repo:**
- Use `addTearDown(...)` to close resources created inside a test (common for Drift DBs; e.g. `test/fl_010_database_test.dart`, `test/widget_test.dart`).
- Dispose widget trees at the end of widget tests to flush pending Drift timers:
  - `await tester.pumpWidget(const SizedBox.shrink()); await tester.pumpAndSettle();` (e.g. `test/widget_test.dart`, `test/fl_070_offline_core_screens_smoke_test.dart`).

## Mocking

**Framework:**
- No `mockito`/`mocktail` detected.
- Prefer hand-written fakes/stubs implementing small interfaces.

**Patterns:**
```dart
class _FakeClock implements Clock {
  _FakeClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

class _FakeMarket implements MarketDataSource {
  _FakeMarket(this._result);
  final MarketComps? _result;
  @override
  Future<MarketComps?> fetchComps({required String query}) async => _result;
}
```
Examples: `test/services_sync/fl_042_sync_scheduler_test.dart`, `test/services_market/market_bridge_cache_test.dart`.

**HTTP mocking:**
- Use `package:http/testing.dart` `MockClient` for `http.Client` injection (e.g. `test/services_market/fl_041_tradera_client_test.dart`).

**Platform/plugin mocking:**
- Override plugin platform singletons and restore them in teardown:
  - Workmanager: `WorkmanagerPlatform.instance = _FakeWorkmanagerPlatform();` (e.g. `test/features_settings/fl_068_settings_dev_mode_reveal_test.dart`, `test/services_sync/fl_067_background_sync_policy_test.dart`).
- When behavior differs per platform, set `debugDefaultTargetPlatformOverride` (Android-specific scheduling expectations in `test/services_sync/fl_067_background_sync_policy_test.dart`).

**DB fakes (avoid timers/complex setup):**
- For UI that only needs a subset of DAOs, tests sometimes use a fake `AppDatabase` with overridden DAOs (e.g. `test/features/settings/sync_status_screen_test.dart`).

## Fixtures and Factories

**Test data:**
- Inline factory values are common (e.g. `TraderaProxyResponse`/`TraderaProxyItem` in `test/services_market/market_bridge_cache_test.dart`).
- Drift companions with `Value(...)` are used for nullable columns (e.g. `ScanItemsCompanion.insert(...)` in `test/services_sync/fl_042_sync_scheduler_test.dart`).

## Common Patterns

**Riverpod overrides for widget tests:**
- Wrap widgets/app with `ProviderScope` and override required providers (`appDatabaseProvider`, `appConfigProvider`, etc.).
- Example bootstrapping pattern: `test/widget_test.dart` and `test/fl_070_offline_core_screens_smoke_test.dart`.

**Offline-first test stability:**
- Disable runtime font fetching in tests: `GoogleFonts.config.allowRuntimeFetching = false;` (e.g. `test/widget_test.dart`, `test/features_auth/login_screen_widget_test.dart`).
- Use `Directory.systemTemp` / temp dirs for file IO (e.g. `test/services_ai/fl_030_model_manager_test.dart`).

**Stream assertions:**
- Use `expectLater(stream, emitsThrough(predicate(...)))` for Drift watch streams (e.g. `test/fl_010_database_test.dart`).

**Error testing:**
- Use `expectLater(() => fn(), throwsA(isA<Exception>()))` or specific matchers like `throwsStateError` (e.g. `test/fl_022_serial_task_queue_test.dart`, `test/services_ai/fl_030_model_manager_test.dart`).

## Golden Tests

**Approach:**
- Goldens use Flutter’s built-in `matchesGoldenFile(...)` matcher (no `golden_toolkit` detected).
- Patterns:
  - Render a fixed-size widget (often inside a `SizedBox`)
  - Wrap in `RepaintBoundary` with a `GlobalKey`
  - `pumpAndSettle` then `expectLater(..., matchesGoldenFile(...))`
  - Example: `test/features_auth/login_screen_golden_test.dart`, `test/fl_066_bento_card_golden_test.dart`

**Golden assets:**
- Master images live under `test/goldens/*.png`.
- Failure artifacts are present under `test/**/failures/*.png` (e.g. `test/features_dashboard/failures/`).

## Coverage

**Requirements:**
- Not detected as enforced in CI (CI runs `flutter test` without coverage in `.github/workflows/ci.yml`).

**View coverage:**
```bash
flutter test --coverage
# open coverage/lcov.info with your preferred lcov viewer
```

---

*Testing analysis: 2026-02-21*
