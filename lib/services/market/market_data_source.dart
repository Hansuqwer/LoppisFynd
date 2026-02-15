import 'market_models.dart';

abstract interface class MarketDataSource {
  Future<MarketStats?> fetchMarketStats({required String query});
}

class NoopMarketDataSource implements MarketDataSource {
  const NoopMarketDataSource();

  @override
  Future<MarketStats?> fetchMarketStats({required String query}) async {
    return null;
  }
}
