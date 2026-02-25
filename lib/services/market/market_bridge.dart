import 'market_math.dart';
import 'market_data_source.dart';
import 'market_models.dart';
import 'tradera_client.dart';
import 'tradera_proxy_models.dart';

import '../../core/database/app_database.dart';
import '../../core/settings/app_settings_keys.dart';
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
    final comps = await fetchComps(query: query);
    return comps?.stats;
  }

  @override
  Future<MarketComps?> fetchComps({required String query}) async {
    final now = _clock.now();
    final key = _key(query);
    if (key.isEmpty) return null;

    final cached = await _db.marketStatsCacheDao.getFresh(
      queryKey: key,
      now: now,
      ttl: _ttl,
    );
    if (cached != null) {
      final stats = MarketStats(
        count: cached.count,
        p25Sek: (cached.p25Sek ?? cached.minSek).round(),
        minSek: cached.minSek.round(),
        medianSek: cached.medianSek.round(),
        p75Sek: (cached.p75Sek ?? cached.maxSek).round(),
        maxSek: cached.maxSek.round(),
        lastUpdated: cached.fetchedAt,
      );

      // Cache only stores stats; return empty comps payload.
      return MarketComps(sales: const [], stats: stats);
    }

    final enabled =
        (await _db.appSettingsDao.getInt(
          kPrivacyFetchSoldPriceCompsEnabledKeyV1,
        )) ??
        1;
    if (enabled != 1) return null;

    final resp = await _tradera.searchEnded(searchWords: query);
    final sales = <MarketSale>[];

    for (final item in resp.items) {
      final endDate = item.endDate;
      final price = _extractPrice(item);
      if (price == null || price <= 0) continue;
      if (endDate == null) continue;
      sales.add(MarketSale(priceSek: price, endDate: endDate));
    }

    if (sales.isEmpty) return null;
    final stats = MarketMath.statsFromSalesWithOutlierFilter(
      sales,
      lastUpdated: now,
    );

    await _db.marketStatsCacheDao.upsert(
      queryKey: key,
      count: stats.count,
      p25Sek: stats.p25Sek.toDouble(),
      minSek: stats.minSek.toDouble(),
      medianSek: stats.medianSek.toDouble(),
      p75Sek: stats.p75Sek.toDouble(),
      maxSek: stats.maxSek.toDouble(),
      fetchedAt: now,
    );

    return MarketComps(sales: sales, stats: stats);
  }

  int? _extractPrice(TraderaProxyItem item) {
    if (item.isEnded == false) return null;
    final itemType = item.itemType;
    if (itemType == TraderaItemType.pureBuyItNow ||
        itemType == TraderaItemType.shopItem) {
      return item.buyItNowPrice;
    }

    if (itemType == TraderaItemType.auction ||
        itemType == TraderaItemType.auctionWithBuyItNow) {
      if (item.hasBids != true) return null;
      return item.maxBid;
    }

    if (item.hasBids == true && (item.maxBid ?? 0) > 0) {
      return item.maxBid;
    }
    return item.buyItNowPrice;
  }
}
