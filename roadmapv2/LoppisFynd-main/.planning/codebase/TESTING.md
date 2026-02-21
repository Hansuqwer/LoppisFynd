# Testing Patterns

**Analysis Date:** 2026-02-17

## Test Framework

**Runner:**
- `flutter_test` (from Flutter SDK; configured via `pubspec.yaml`).
- Config: Not detected (no `dart_test.yaml`, no `flutter_test_config.dart`).

**Assertion Library:**
- `package:test` matchers exposed via `package:flutter_test/flutter_test.dart` (examples: `expect`, `emitsThrough`, `throwsA` throughout `test/`).

**Run Commands:**
```bash
flutter test                 # Run all tests
flutter test --watch         # Watch mode
flutter test --coverage      # Coverage (writes coverage/lcov.info)
flutter test --update-goldens # Re-generate golden snapshots
```

## Test File Organization

**Location:**
- Tests live under `test/` and cover unit, service, and widget behavior.

**Naming:**
- Standard: `*_test.dart` (example: `test/widget_test.dart`).
- Many tests are prefixed with a tracking id `fl_###_..._test.dart` (examples: `test/fl_010_database_test.dart`, `test/fl_066_bento_card_golden_test.dart`).
- Feature-grouped subdirectories exist (examples: `test/features_auth/`, `test/services_sync/`, `test/services_ai/`, `test/features/model_manager/widgets/`).

**Structure:**
```
test/
  fl_###_..._test.dart
  features_auth/
    ..._test.dart
  services_ai/
    ..._test.dart
  services_sync/
    ..._test.dart
  goldens/
    *.png
```

## Test Structure

**Suite Organization:**
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SomeFeature', () {
    test('does something', () async {
      // arrange
      // act
      // assert
    });
  });
}
```

**Patterns:**
- **Setup:** prefer local setup inside each `test` for clarity; use `setUp`/`tearDown` when platform globals must be restored (example: `test/services_sync/fl_067_background_sync_policy_test.dart`).
- **Teardown:** use `addTearDown(...)` for resource cleanup (examples: closing DB in `test/fl_010_database_test.dart`, deleting temp dirs in `test/services_ai/fl_030_model_manager_test.dart`).
- **Widget tests:** pump `ProviderScope` with overrides to isolate dependencies (example: `test/widget_test.dart`).

## Mocking

**Framework:**
- No mocking framework detected (no `mockito`/`mocktail` imports). Prefer fakes.

**Patterns:**
```dart
class _FakeClock implements Clock {
  _FakeClock(this._now);
  DateTime _now;
  @override
  DateTime now() => _now;
  void advance(Duration d) => _now = _now.add(d);
}
```
Examples of fake-based testing:
- Clock fakes to control time in sync/cache logic: `test/services_sync/fl_042_sync_scheduler_test.dart`, `test/services_market/market_bridge_cache_test.dart`.
- API fakes implementing abstract interfaces: `_FakeEmailOtpAuthApi` in `test/features_auth/email_otp_auth_test.dart` and `test/features_auth/login_screen_widget_test.dart`.
- Platform overrides by swapping singleton instances:
  - Workmanager platform fake in `test/services_sync/fl_067_background_sync_policy_test.dart` (sets `WorkmanagerPlatform.instance` in `setUp`, restores in `tearDown`).

**What to Mock:**
- External boundaries and singletons (HTTP, time, platform plugins) via fakes and injectable dependencies (examples: `http.Client?` injection in `lib/services/market/tradera_client.dart`, `Clock` injection in `lib/services/sync/sync_scheduler.dart`).

**What NOT to Mock:**
- Drift DAOs are exercised against an in-memory database rather than mocked (example: `AppDatabase.inMemory()` in `test/fl_010_database_test.dart`).

## Fixtures and Factories

**Test Data:**
- Inline data and temporary filesystem fixtures are preferred over shared factories.
- Temp filesystem usage pattern (example: `test/services_ai/fl_030_model_manager_test.dart`):
```dart
final temp = await Directory.systemTemp.createTemp('fynd_model_test_');
addTearDown(() async => temp.delete(recursive: true));
```

**Location:**
- Golden snapshots live in `test/goldens/` and are referenced via `matchesGoldenFile(...)` (examples: `test/fl_066_bento_card_golden_test.dart`, `test/features_auth/login_screen_golden_test.dart`).

## Coverage

**Requirements:**
- None enforced in-repo (no coverage thresholds/config detected).

**View Coverage:**
```bash
flutter test --coverage
# Output: coverage/lcov.info
```

## Test Types

**Unit Tests:**
- Pure functions and small services (examples: `test/fl_064_keyword_query_sanitizer_test.dart`, `test/services_market/fl_041_market_math_test.dart`, `test/features_auth/email_masking_test.dart`).

**Integration Tests:**
- Not detected (no `integration_test/` directory).

**E2E Tests:**
- Not detected (no `flutter_driver` / device-level harness found).

## Common Patterns

**Async Testing:**
- Stream assertions use `expectLater` + `emitsThrough` then await the future (example: `test/fl_010_database_test.dart`).
- Widget tests frequently use `pumpAndSettle` with explicit durations to wait for animations/timers (examples: `test/widget_test.dart`, `test/fl_065_nav_smoke_test.dart`).

**Error Testing:**
- Use matcher-based exception assertions: `throwsA(isA<Exception>())` and specific matchers like `throwsStateError` (examples: `test/services_ai/fl_030_model_manager_test.dart`, `test/fl_022_serial_task_queue_test.dart`).

---

*Testing analysis: 2026-02-17*
