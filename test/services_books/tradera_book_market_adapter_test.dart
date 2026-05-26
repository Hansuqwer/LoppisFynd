import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/books/tradera_book_market_adapter.dart';
import 'package:fynd_loppis/services/market/tradera_proxy_models.dart';

void main() {
  final now = DateTime(2026, 4, 28);
  const adapter = TraderaBookMarketAdapter();

  TraderaProxyItem item({
    required int id,
    int? price = 100,
    DateTime? endDate,
    bool omitEndDate = false,
    bool? isEnded = true,
    bool? hasBids = true,
    String? link,
  }) {
    return TraderaProxyItem(
      id: id,
      shortDescription: 'book $id',
      endDate: omitEndDate
          ? null
          : endDate ?? now.subtract(const Duration(days: 1)),
      maxBid: price,
      totalBids: hasBids == true ? 1 : 0,
      hasBids: hasBids,
      isEnded: isEnded,
      itemLink: link,
      thumbnailLink: null,
    );
  }

  TraderaProxyResponse response(List<TraderaProxyItem> items) {
    return TraderaProxyResponse(
      totalNumberOfItems: items.length,
      totalNumberOfPages: 1,
      items: items,
    );
  }

  group('TraderaBookMarketAdapter', () {
    test('maps valid ended bid items into BookSale records', () {
      final sales = adapter.salesFromResponse(
        response([
          item(id: 1, price: 75, link: 'https://tradera.test/1'),
          item(id: 2, price: 125, link: 'https://tradera.test/2'),
        ]),
      );

      expect(sales, hasLength(2));
      expect(sales.first.platform, 'tradera');
      expect(sales.first.priceSek, 75);
      expect(sales.first.listingUrl, 'https://tradera.test/1');
      expect(sales.first.soldAt, now.subtract(const Duration(days: 1)));
    });

    test('filters items without usable sold price evidence', () {
      final sales = adapter.salesFromResponse(
        response([
          item(id: 1, price: null),
          item(id: 2, price: 0),
          item(id: 3, omitEndDate: true),
          item(id: 4, isEnded: false),
          item(id: 5, hasBids: false),
          item(id: 6, price: 99),
        ]),
      );

      expect(sales, hasLength(1));
      expect(sales.single.priceSek, 99);
    });

    test('feeds mapped sales into BookMarketDataAggregator', () {
      final stats = adapter.statsFromResponse(
        response([
          item(id: 1, price: 50),
          item(id: 2, price: 100),
          item(id: 3, price: 150),
        ]),
        now: now,
      );

      expect(stats, isNotNull);
      expect(stats!.lowestSoldPriceSek, 50);
      expect(stats.averageSoldPriceSek, 100);
      expect(stats.highestSoldPriceSek, 150);
      expect(stats.totalSales, 3);
      expect(stats.sourceCounts, {'tradera': 3});
    });

    test('returns null stats when no valid Tradera sales remain', () {
      final stats = adapter.statsFromResponse(
        response([item(id: 1, price: null), item(id: 2, hasBids: false)]),
        now: now,
      );

      expect(stats, isNull);
    });
  });
}
