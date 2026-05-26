import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/market_stats_cache.dart';

part 'market_stats_cache_dao.g.dart';

@DriftAccessor(tables: [MarketStatsCache])
class MarketStatsCacheDao extends DatabaseAccessor<AppDatabase>
    with _$MarketStatsCacheDaoMixin {
  MarketStatsCacheDao(super.db);

  Future<MarketStatsCacheData?> getFresh({
    required String queryKey,
    required DateTime now,
    required Duration ttl,
  }) async {
    final row = await (select(
      marketStatsCache,
    )..where((t) => t.queryKey.equals(queryKey))).getSingleOrNull();
    if (row == null) return null;
    if (now.difference(row.fetchedAt) > ttl) return null;
    return row;
  }

  Future<void> upsert({
    required String queryKey,
    required int count,
    required double minSek,
    required double medianSek,
    required double maxSek,
    required DateTime fetchedAt,
  }) async {
    await into(marketStatsCache).insertOnConflictUpdate(
      MarketStatsCacheCompanion(
        queryKey: Value(queryKey),
        count: Value(count),
        minSek: Value(minSek),
        medianSek: Value(medianSek),
        maxSek: Value(maxSek),
        fetchedAt: Value(fetchedAt),
      ),
    );
  }
}
