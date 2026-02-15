import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/hauls_dao.dart';
import 'daos/app_settings_dao.dart';
import 'daos/market_stats_cache_dao.dart';
import 'daos/scan_item_sync_states_dao.dart';
import 'daos/scan_items_dao.dart';
import 'daos/sync_quotas_dao.dart';
import 'tables/app_settings.dart';
import 'tables/market_stats_cache.dart';
import 'tables/hauls.dart';
import 'tables/scan_item_sync_states.dart';
import 'tables/scan_items.dart';
import 'tables/sync_quotas.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Hauls,
    ScanItems,
    ScanItemSyncStates,
    SyncQuotas,
    AppSettings,
    MarketStatsCache,
  ],
  daos: [
    HaulsDao,
    ScanItemsDao,
    ScanItemSyncStatesDao,
    SyncQuotasDao,
    AppSettingsDao,
    MarketStatsCacheDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.open() => AppDatabase(_openConnection());

  factory AppDatabase.inMemory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(scanItemSyncStates);
        await m.createTable(syncQuotas);
      }

      if (from < 3) {
        await m.alterTable(TableMigration(scanItems));
      }

      if (from < 4) {
        await m.alterTable(TableMigration(hauls));
      }

      if (from < 5) {
        await m.alterTable(TableMigration(scanItems));
      }

      if (from < 6) {
        await m.createTable(appSettings);
      }

      if (from < 7) {
        await m.createTable(marketStatsCache);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'loppisfynd.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
