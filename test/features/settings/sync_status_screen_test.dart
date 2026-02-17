import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fynd_loppis/core/app/providers.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/database/daos/app_settings_dao.dart';
import 'package:fynd_loppis/core/database/daos/entity_sync_statuses_dao.dart';
import 'package:fynd_loppis/features/settings/sync_status_screen.dart';
import 'package:fynd_loppis/gen/app_localizations.dart';
import 'package:fynd_loppis/shared/widgets/glass_button.dart';
import 'package:drift/native.dart';

// Fake classes to avoid using real DB and pending timers
class FakeAppSettingsDao extends AppSettingsDao {
  FakeAppSettingsDao(super.db);

  final Map<String, int> _ints = {};

  @override
  Future<int?> getInt(String key) async {
    final val = _ints[key];
    return val;
  }

  @override
  Future<void> setInt(String key, int? value) async {
    if (value == null) {
      _ints.remove(key);
    } else {
      _ints[key] = value;
    }
  }
}

class FakeEntitySyncStatusesDao extends EntitySyncStatusesDao {
  FakeEntitySyncStatusesDao(super.db);

  @override
  Stream<List<EntitySyncStatuse>> watchProblems() => Stream.value([]);
}

class FakeAppDatabase extends AppDatabase {
  FakeAppDatabase() : super(NativeDatabase.memory());

  late final _appSettingsDao = FakeAppSettingsDao(this);
  late final _entitySyncStatusesDao = FakeEntitySyncStatusesDao(this);

  @override
  AppSettingsDao get appSettingsDao => _appSettingsDao;

  @override
  EntitySyncStatusesDao get entitySyncStatusesDao => _entitySyncStatusesDao;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAppDatabase db;

  setUp(() {
    db = FakeAppDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          isOnlineProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SyncStatusScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('Sync now button is hidden by default (dev mode off)', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.byType(GlassButton), findsNothing);
  });

  testWidgets('Sync now button is visible when dev mode is enabled', (
    tester,
  ) async {
    await db.appSettingsDao.setInt('dev_mode_enabled_v1', 1);

    await pumpScreen(tester);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(GlassButton), findsOneWidget);
  });
}
