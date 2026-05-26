import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/books/book_market_service.dart';
import 'package:fynd_loppis/services/market/tradera_client.dart';
import 'package:fynd_loppis/services/market/tradera_proxy_models.dart';

class _FakeTraderaClient extends TraderaClient {
  _FakeTraderaClient(this._onSearch)
    : super(functionUrl: Uri.parse('http://localhost'));

  final Future<TraderaProxyResponse> Function({
    required String searchWords,
    required int itemsPerPage,
    required int pageNumber,
  })
  _onSearch;

  @override
  Future<TraderaProxyResponse> searchEnded({
    required String searchWords,
    int itemsPerPage = 50,
    int pageNumber = 1,
  }) {
    return _onSearch(
      searchWords: searchWords,
      itemsPerPage: itemsPerPage,
      pageNumber: pageNumber,
    );
  }
}

void main() {
  final now = DateTime(2026, 4, 28);

  TraderaProxyItem item({
    required int id,
    required int price,
    int daysAgo = 1,
  }) {
    return TraderaProxyItem(
      id: id,
      shortDescription: 'book $id',
      endDate: now.subtract(Duration(days: daysAgo)),
      maxBid: price,
      totalBids: 1,
      hasBids: true,
      isEnded: true,
      itemLink: 'https://tradera.test/$id',
      thumbnailLink: null,
    );
  }

  group('BookMarketService', () {
    test(
      'fetchStatsForBookQuery trims query and returns aggregated stats',
      () async {
        String? receivedQuery;
        int? receivedItemsPerPage;
        final service = BookMarketService(
          traderaClient: _FakeTraderaClient(({
            required searchWords,
            required itemsPerPage,
            required pageNumber,
          }) async {
            receivedQuery = searchWords;
            receivedItemsPerPage = itemsPerPage;
            expect(pageNumber, 1);
            return TraderaProxyResponse(
              totalNumberOfItems: 3,
              totalNumberOfPages: 1,
              items: [
                item(id: 1, price: 50),
                item(id: 2, price: 100),
                item(id: 3, price: 150),
              ],
            );
          }),
        );

        final stats = await service.fetchStatsForBookQuery(
          query: '  Den allvarsamma leken Hjalmar Söderberg ',
          itemsPerPage: 25,
          now: now,
        );

        expect(receivedQuery, 'Den allvarsamma leken Hjalmar Söderberg');
        expect(receivedItemsPerPage, 25);
        expect(stats, isNotNull);
        expect(stats!.lowestSoldPriceSek, 50);
        expect(stats.averageSoldPriceSek, 100);
        expect(stats.highestSoldPriceSek, 150);
        expect(stats.sourceCounts, {'tradera': 3});
      },
    );

    test('returns null for blank query without calling Tradera', () async {
      final service = BookMarketService(
        traderaClient: _FakeTraderaClient(({
          required searchWords,
          required itemsPerPage,
          required pageNumber,
        }) async {
          fail('Tradera should not be called for blank query');
        }),
      );

      expect(
        await service.fetchStatsForBookQuery(query: '   ', now: now),
        isNull,
      );
    });

    test('returns null when Tradera response has no usable sales', () async {
      final service = BookMarketService(
        traderaClient: _FakeTraderaClient(({
          required searchWords,
          required itemsPerPage,
          required pageNumber,
        }) async {
          return TraderaProxyResponse(
            totalNumberOfItems: 1,
            totalNumberOfPages: 1,
            items: [
              TraderaProxyItem(
                id: 1,
                shortDescription: 'no bids',
                endDate: now,
                maxBid: 100,
                totalBids: 0,
                hasBids: false,
                isEnded: true,
                itemLink: null,
                thumbnailLink: null,
              ),
            ],
          );
        }),
      );

      expect(
        await service.fetchStatsForBookQuery(query: 'book', now: now),
        isNull,
      );
    });

    test(
      'lets TraderaClientException surface for caller-facing handling',
      () async {
        final service = BookMarketService(
          traderaClient: _FakeTraderaClient(({
            required searchWords,
            required itemsPerPage,
            required pageNumber,
          }) async {
            throw const TraderaClientException('Rate limited');
          }),
        );

        await expectLater(
          service.fetchStatsForBookQuery(query: 'book', now: now),
          throwsA(isA<TraderaClientException>()),
        );
      },
    );
  });
}
