import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../../core/database/app_database.dart';
import '../../core/database/tables/scan_items.dart';
import '../../core/settings/app_settings_keys.dart';
import '../../core/time/clock.dart';
import '../../core/utils/serial_task_queue.dart';
import '../analytics/analytics_service.dart';
import '../market/market_data_source.dart';
import '../market/market_models.dart';
import 'sync_events.dart';

class SyncScheduler {
  SyncScheduler({
    required AppDatabase db,
    required MarketDataSource market,
    AnalyticsService analytics = const NoopAnalyticsService(),
    String? Function()? userIdProvider,
    Clock clock = const SystemClock(),
    int maxCallsPerDay = 200,
  }) : _db = db,
       _market = market,
       _analytics = analytics,
       _userIdProvider = userIdProvider,
       _clock = clock,
       _maxCallsPerDay = maxCallsPerDay;

  final AppDatabase _db;
  final MarketDataSource _market;
  final AnalyticsService _analytics;
  final String? Function()? _userIdProvider;
  final Clock _clock;
  final int _maxCallsPerDay;

  final _queue = SerialTaskQueue();
  final _events = StreamController<SyncEvent>.broadcast();

  Stream<SyncEvent> get events => _events.stream;

  Future<void> syncOnce() {
    return _queue.add(_syncOnceInternal);
  }

  Future<void> _syncOnceInternal() async {
    _events.add(const SyncRunStarted());
    try {
      final enabled =
          (await _db.appSettingsDao.getInt(
            kPrivacyFetchSoldPriceCompsEnabledKeyV1,
          )) ??
          1;
      if (enabled != 1) return;

      final sw = Stopwatch()..start();
      final now = _clock.now();
      final dayKey = _dayKey(now);
      var used = await _db.syncQuotasDao.getUsed(dayKey);
      if (used >= _maxCallsPerDay) return;

      final userId = _userIdProvider?.call();
      final pending = await _db.scanItemsDao.listPendingMarketSync(
        userId: userId,
      );
      for (final item in pending) {
        if (used >= _maxCallsPerDay) break;
        final query = item.query;
        if (query == null || query.trim().isEmpty) continue;

        final state = await _db.scanItemSyncStatesDao.getByScanItemId(item.id);
        final nextAttemptAt = state?.nextAttemptAt;
        if (nextAttemptAt != null && nextAttemptAt.isAfter(now)) {
          _events.add(ScanItemSyncDeferred(scanItemId: item.id));
          continue;
        }

        try {
          await _db.scanItemsDao.transitionStatus(
            id: item.id,
            to: ScanItemStatus.syncing,
          );

          MarketComps? comps;
          try {
            comps = await _analytics.measure(
              'comps_fetch',
              () => _market.fetchComps(query: query),
            );
          } finally {
            await _db.syncQuotasDao.incrementUsed(dayKey, 1);
            used += 1;
          }

          if (comps == null) {
            throw const _NoMarketData();
          }

          final stats = comps.stats;

          await _db.scanItemCompsDao.upsert(
            scanItemId: item.id,
            rawJson: jsonEncode(comps.toJson()),
            medianPrice: stats.medianSek.toDouble(),
            minPrice: stats.minSek.toDouble(),
            maxPrice: stats.maxSek.toDouble(),
            fetchedAt: now,
          );

          await _db.scanItemsDao.setMarketStats(
            id: item.id,
            medianPrice: stats.medianSek.toDouble(),
            minPrice: stats.minSek.toDouble(),
            maxPrice: stats.maxSek.toDouble(),
          );

          await _db.scanItemsDao.transitionStatus(
            id: item.id,
            to: ScanItemStatus.complete,
          );

          await _db.scanItemSyncStatesDao.clear(item.id);
          _events.add(ScanItemSynced(scanItemId: item.id));
          _analytics.event('comps_ready');
        } catch (e) {
          final attempts = (state?.attempts ?? 0) + 1;
          final delay = _backoff(attempts);
          final next = now.add(delay);

          await _db.scanItemSyncStatesDao.upsert(
            scanItemId: item.id,
            attempts: attempts,
            nextAttemptAt: next,
            lastError: e.toString(),
          );

          try {
            await _db.scanItemsDao.transitionStatus(
              id: item.id,
              to: ScanItemStatus.pendingSync,
            );
          } catch (_) {
            await _db.scanItemsDao.transitionStatus(
              id: item.id,
              to: ScanItemStatus.failed,
            );
          }

          _events.add(
            ScanItemSyncFailed(scanItemId: item.id, error: e.toString()),
          );
        }
      }

      sw.stop();
      _analytics.event(
        'sync_run_finished',
        data: {'duration_ms': sw.elapsedMilliseconds},
      );
    } finally {
      _events.add(const SyncRunFinished());
    }
  }
}

String _dayKey(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

Duration _backoff(int attempts) {
  final capped = min(attempts, 10);
  final seconds = 30 * (1 << (capped - 1));
  return Duration(seconds: min(seconds, 6 * 60 * 60));
}

class _NoMarketData implements Exception {
  const _NoMarketData();
  @override
  String toString() => 'No market data';
}
