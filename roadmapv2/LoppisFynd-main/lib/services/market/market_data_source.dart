import 'market_models.dart';

abstract interface class MarketDataSource {
  Future<MarketStats?> fetchMarketStats({required String query});

  /// Returns both raw comps (sold items) and derived stats.
  Future<MarketComps?> fetchComps({required String query});
}

class NoopMarketDataSource implements MarketDataSource {
  const NoopMarketDataSource();

  @override
  Future<MarketStats?> fetchMarketStats({required String query}) async {
    return null;
  }

  @override
  Future<MarketComps?> fetchComps({required String query}) async {
    return null;
  }
}
