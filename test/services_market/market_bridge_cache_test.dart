import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/time/clock.dart';
import 'package:fynd_loppis/services/market/market_bridge.dart';
import 'package:fynd_loppis/services/market/tradera_client.dart';
import 'package:fynd_loppis/services/market/tradera_proxy_models.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration d) {
    _now = _now.add(d);
  }
}

class _FakeTraderaClient extends TraderaClient {
  _FakeTraderaClient(this._onSearch)
    : super(functionUrl: Uri.parse('http://localhost'));

  final Future<TraderaProxyResponse> Function(String) _onSearch;

  @override
  Future<TraderaProxyResponse> searchEnded({
    required String searchWords,
    int itemsPerPage = 50,
    int pageNumber = 1,
  }) {
    return _onSearch(searchWords);
  }
}

void main() {
  test('MarketBridge uses TTL cache by query', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    var calls = 0;
    final tradera = _FakeTraderaClient((q) async {
      calls += 1;
      return TraderaProxyResponse(
        totalNumberOfItems: 3,
        totalNumberOfPages: 1,
        items: [
          TraderaProxyItem(
            id: 1,
            shortDescription: q,
            endDate: DateTime(2026, 2, 1),
            maxBid: 100,
            buyItNowPrice: null,
            itemType: TraderaItemType.auction,
            totalBids: 1,
            hasBids: true,
            isEnded: true,
            itemLink: null,
            thumbnailLink: null,
          ),
          TraderaProxyItem(
            id: 2,
            shortDescription: q,
            endDate: DateTime(2026, 2, 2),
            maxBid: 200,
            buyItNowPrice: null,
            itemType: TraderaItemType.auction,
            totalBids: 1,
            hasBids: true,
            isEnded: true,
            itemLink: null,
            thumbnailLink: null,
          ),
          TraderaProxyItem(
            id: 3,
            shortDescription: q,
            endDate: DateTime(2026, 2, 3),
            maxBid: 300,
            buyItNowPrice: null,
            itemType: TraderaItemType.auction,
            totalBids: 1,
            hasBids: true,
            isEnded: true,
            itemLink: null,
            thumbnailLink: null,
          ),
        ],
      );
    });

    final clock = _FakeClock(DateTime(2026, 2, 14, 10));
    final market = MarketBridge(
      tradera: tradera,
      db: db,
      clock: clock,
      ttl: const Duration(hours: 24),
    );

    final s1 = await market.fetchMarketStats(query: 'Glassvas');
    expect(s1, isNotNull);
    expect(calls, 1);

    final s2 = await market.fetchMarketStats(query: '  glassvas ');
    expect(s2, isNotNull);
    expect(calls, 1);

    clock.advance(const Duration(hours: 25));
    final s3 = await market.fetchMarketStats(query: 'glassvas');
    expect(s3, isNotNull);
    expect(calls, 2);
  });
}
