import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/books_dao.dart';
import 'daos/book_market_data_dao.dart';
import 'daos/hauls_dao.dart';
import 'daos/app_settings_dao.dart';
import 'daos/draft_listings_dao.dart';
import 'daos/entity_sync_statuses_dao.dart';
import 'daos/market_stats_cache_dao.dart';
import 'daos/pending_cloud_sync_entities_dao.dart';
import 'daos/price_button_config_dao.dart';
import 'daos/scan_item_comps_dao.dart';
import 'daos/scan_item_photos_dao.dart';
import 'daos/scan_item_sync_states_dao.dart';
import 'daos/scan_items_dao.dart';
import 'daos/sync_quotas_dao.dart';
import 'tables/app_settings.dart';
import 'tables/book_market_data.dart';
import 'tables/books.dart';
import 'tables/draft_listings.dart';
import 'tables/entity_sync_statuses.dart';
import 'tables/market_stats_cache.dart';
import 'tables/hauls.dart';
import 'tables/pending_cloud_sync_entities.dart';
import 'tables/price_button_config.dart';
import 'tables/scan_item_comps.dart';
import 'tables/scan_item_photos.dart';
import 'tables/scan_item_sync_states.dart';
import 'tables/scan_items.dart';
import 'tables/sync_quotas.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Hauls,
    ScanItems,
    ScanItemPhotos,
    ScanItemComps,
    ScanItemSyncStates,
    EntitySyncStatuses,
    SyncQuotas,
    AppSettings,
    DraftListings,
    MarketStatsCache,
    PendingCloudSyncEntities,
    Books,
    BookMarketData,
    PriceButtonConfig,
  ],
  daos: [
    HaulsDao,
    ScanItemsDao,
    ScanItemPhotosDao,
    ScanItemCompsDao,
    ScanItemSyncStatesDao,
    EntitySyncStatusesDao,
    SyncQuotasDao,
    AppSettingsDao,
    DraftListingsDao,
    MarketStatsCacheDao,
    PendingCloudSyncEntitiesDao,
    BooksDao,
    BookMarketDataDao,
    PriceButtonConfigDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.open() => AppDatabase(_openConnection());

  factory AppDatabase.inMemory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 16;

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

      if (from < 8) {
        await m.alterTable(TableMigration(appSettings));
      }

      if (from < 9) {
        await m.alterTable(TableMigration(hauls));
        await m.alterTable(TableMigration(scanItems));
      }

      if (from < 10) {
        await m.createTable(scanItemPhotos);
        await m.createTable(scanItemComps);
        await m.createTable(entitySyncStatuses);
      }

      if (from < 11) {
        await m.alterTable(TableMigration(scanItems));
      }

      if (from < 12) {
        await m.alterTable(TableMigration(scanItems));
      }

      if (from < 13) {
        await m.createTable(draftListings);
      }

      if (from < 14) {
        await m.alterTable(TableMigration(scanItems));
      }

      if (from < 15) {
        await m.createTable(pendingCloudSyncEntities);
      }

      if (from < 16) {
        await m.createTable(books);
        await m.createTable(bookMarketData);
        await m.createTable(priceButtonConfig);
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
