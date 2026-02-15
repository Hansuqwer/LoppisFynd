import 'market_math.dart';
import 'market_data_source.dart';
import 'market_models.dart';
import 'tradera_client.dart';

import '../../core/database/app_database.dart';
import '../../core/time/clock.dart';

class MarketBridge implements MarketDataSource {
  MarketBridge({
    required TraderaClient tradera,
    required AppDatabase db,
    Clock clock = const SystemClock(),
    Duration ttl = const Duration(hours: 24),
  }) : _tradera = tradera,
       _db = db,
       _clock = clock,
       _ttl = ttl;

  final TraderaClient _tradera;
  final AppDatabase _db;
  final Clock _clock;
  final Duration _ttl;

  String _key(String query) {
    return query.trim().toLowerCase();
  }

  @override
  Future<MarketStats?> fetchMarketStats({required String query}) async {
    final now = _clock.now();
    final key = _key(query);
    if (key.isEmpty) return null;

    final cached = await _db.marketStatsCacheDao.getFresh(
      queryKey: key,
      now: now,
      ttl: _ttl,
    );
    if (cached != null) {
      return MarketStats(
        count: cached.count,
        minSek: cached.minSek.round(),
        medianSek: cached.medianSek.round(),
        maxSek: cached.maxSek.round(),
      );
    }

    final resp = await _tradera.searchEnded(searchWords: query);
    final sales = <MarketSale>[];

    for (final item in resp.items) {
      final price = item.maxBid;
      final endDate = item.endDate;
      if (price == null || price <= 0) continue;
      if (endDate == null) continue;
      if (item.isEnded == false) continue;
      if (item.hasBids == false) continue;
      sales.add(MarketSale(priceSek: price, endDate: endDate));
    }

    if (sales.isEmpty) return null;
    final stats = MarketMath.statsFromSalesWithOutlierFilter(sales);

    await _db.marketStatsCacheDao.upsert(
      queryKey: key,
      count: stats.count,
      minSek: stats.minSek.toDouble(),
      medianSek: stats.medianSek.toDouble(),
      maxSek: stats.maxSek.toDouble(),
      fetchedAt: now,
    );

    return stats;
  }
}
