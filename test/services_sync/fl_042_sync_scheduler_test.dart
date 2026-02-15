import 'package:flutter_test/flutter_test.dart';

import 'package:drift/drift.dart' show Value;

import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/database/tables/scan_items.dart';
import 'package:fynd_loppis/core/time/clock.dart';
import 'package:fynd_loppis/services/market/market_data_source.dart';
import 'package:fynd_loppis/services/market/market_models.dart';
import 'package:fynd_loppis/services/sync/sync_scheduler.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  final DateTime _now;

  @override
  DateTime now() => _now;
}

class _FakeMarket implements MarketDataSource {
  _FakeMarket(this._result);
  final MarketStats? _result;

  @override
  Future<MarketStats?> fetchMarketStats({required String query}) async {
    return _result;
  }
}

class _ThrowingMarket implements MarketDataSource {
  @override
  Future<MarketStats?> fetchMarketStats({required String query}) async {
    throw StateError('network');
  }
}

void main() {
  test('SyncScheduler syncs pending item and increments quota', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.upsert(id: 'haul-1', title: 'Test');
    await db
        .into(db.scanItems)
        .insert(
          ScanItemsCompanion.insert(
            id: 'scan-1',
            haulId: 'haul-1',
            imagePath: const Value('/tmp/img.jpg'),
            thumbPath: const Value('/tmp/thumb.jpg'),
            query: const Value('glassvas'),
            status: const Value(ScanItemStatus.pendingSync),
          ),
        );

    final clock = _FakeClock(DateTime(2026, 2, 14, 10));
    final scheduler = SyncScheduler(
      db: db,
      market: _FakeMarket(
        const MarketStats(count: 3, minSek: 100, medianSek: 200, maxSek: 500),
      ),
      clock: clock,
      maxCallsPerDay: 10,
    );

    await scheduler.syncOnce();

    final item = await db.scanItemsDao.getById('scan-1');
    expect(item, isNotNull);
    expect(item!.status, ScanItemStatus.complete);
    expect(item.medianPrice, 200);
    expect(item.minPrice, 100);
    expect(item.maxPrice, 500);

    final used = await db.syncQuotasDao.getUsed('2026-02-14');
    expect(used, 1);
  });

  test('SyncScheduler records backoff on failure', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.upsert(id: 'haul-1', title: 'Test');
    await db
        .into(db.scanItems)
        .insert(
          ScanItemsCompanion.insert(
            id: 'scan-1',
            haulId: 'haul-1',
            imagePath: const Value('/tmp/img.jpg'),
            thumbPath: const Value('/tmp/thumb.jpg'),
            query: const Value('glassvas'),
            status: const Value(ScanItemStatus.pendingSync),
          ),
        );

    final clock = _FakeClock(DateTime(2026, 2, 14, 10));
    final scheduler = SyncScheduler(
      db: db,
      market: _ThrowingMarket(),
      clock: clock,
      maxCallsPerDay: 10,
    );

    await scheduler.syncOnce();

    final state = await db.scanItemSyncStatesDao.getByScanItemId('scan-1');
    expect(state, isNotNull);
    expect(state!.attempts, 1);
    expect(state.nextAttemptAt, isNotNull);

    final item = await db.scanItemsDao.getById('scan-1');
    expect(item, isNotNull);
    expect(item!.status, ScanItemStatus.pendingSync);
  });
}
