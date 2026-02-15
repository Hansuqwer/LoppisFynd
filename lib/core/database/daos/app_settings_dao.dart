import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/app_settings.dart';

part 'app_settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  Future<int?> getInt(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.intValue;
  }

  Future<void> setInt(String key, int? value) async {
    final now = DateTime.now();
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        key: Value(key),
        intValue: Value(value),
        updatedAt: Value(now),
      ),
    );
  }

  Stream<int?> watchInt(String key) {
    final q = select(appSettings)..where((t) => t.key.equals(key));
    return q.watchSingleOrNull().map((row) => row?.intValue);
  }
}
