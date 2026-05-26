import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/books/book_market_data_service.dart';

void main() {
  final now = DateTime(2026, 4, 28);
  const aggregator = BookMarketDataAggregator();

  BookSale sale({
    required int price,
    int daysAgo = 1,
    String platform = 'tradera',
    String? url,
  }) {
    return BookSale(
      platform: platform,
      priceSek: price,
      soldAt: now.subtract(Duration(days: daysAgo)),
      listingUrl: url,
    );
  }

  group('BookMarketDataAggregator', () {
    test('calculates high average low total sales and sales per month', () {
      final stats = aggregator.aggregate([
        sale(price: 50, daysAgo: 10),
        sale(price: 100, daysAgo: 20),
        sale(price: 150, daysAgo: 30, platform: 'vinted'),
      ], now: now);

      expect(stats, isNotNull);
      expect(stats!.lowestSoldPriceSek, 50);
      expect(stats.averageSoldPriceSek, 100);
      expect(stats.highestSoldPriceSek, 150);
      expect(stats.totalSales, 3);
      expect(stats.salesPerMonth, closeTo(0.25, 0.01));
      expect(stats.sourceCounts, {'tradera': 2, 'vinted': 1});
    });

    test('sorts recent sales newest first and caps result count', () {
      const capped = BookMarketDataAggregator(maxRecentSales: 2);

      final stats = capped.aggregate([
        sale(price: 70, daysAgo: 10),
        sale(price: 80, daysAgo: 1),
        sale(price: 90, daysAgo: 5),
      ], now: now);

      expect(stats!.recentSales.map((s) => s.priceSek), [80, 90]);
    });

    test('filters old future and non-positive sales', () {
      final stats = aggregator.aggregate([
        sale(price: 0, daysAgo: 5),
        sale(price: 100, daysAgo: 500),
        BookSale(
          platform: 'tradera',
          priceSek: 120,
          soldAt: now.add(const Duration(days: 1)),
        ),
        sale(price: 90, daysAgo: 5),
      ], now: now);

      expect(stats!.totalSales, 1);
      expect(stats.averageSoldPriceSek, 90);
    });

    test('deduplicates same price date and listing URL', () {
      final duplicateA = sale(
        price: 100,
        daysAgo: 3,
        url: 'https://example.com/item/1',
      );
      final duplicateB = sale(
        price: 100,
        daysAgo: 3,
        url: 'https://example.com/item/1',
      );
      final distinct = sale(
        price: 100,
        daysAgo: 3,
        url: 'https://example.com/item/2',
      );

      final deduplicated = aggregator.deduplicateForTest([
        duplicateA,
        duplicateB,
        distinct,
      ]);

      expect(deduplicated.length, 2);
    });

    test('removes extreme outliers when enough sales remain', () {
      final stats = aggregator.aggregate([
        for (final price in [80, 85, 90, 95, 100, 105, 110, 115, 5000])
          sale(price: price),
      ], now: now);

      expect(stats!.highestSoldPriceSek, 115);
      expect(stats.totalSales, 8);
    });

    test(
      'keeps original sales when outlier filtering would leave too few values',
      () {
        final stats = aggregator.aggregate([
          sale(price: 80),
          sale(price: 85),
          sale(price: 90),
          sale(price: 5000),
        ], now: now);

        expect(stats!.highestSoldPriceSek, 5000);
        expect(stats.totalSales, 4);
      },
    );

    test('returns null when no usable sales exist', () {
      expect(aggregator.aggregate([], now: now), isNull);
      expect(aggregator.aggregate([sale(price: -1)], now: now), isNull);
    });
  });
}
