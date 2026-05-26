import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/books/aggregated_book_market_service.dart';
import 'package:fynd_loppis/services/books/book_market_data_service.dart';

class _FakeSource implements BookMarketSource {
  _FakeSource(this._sales, {this.shouldThrow = false});

  final List<BookSale> _sales;
  final bool shouldThrow;

  @override
  Future<List<BookSale>> search({required String query, DateTime? now}) async {
    if (shouldThrow) throw Exception('source failed');
    return _sales;
  }
}

void main() {
  final now = DateTime(2026, 5, 26);

  BookSale sale({
    required String platform,
    required int price,
    int daysAgo = 1,
  }) {
    return BookSale(
      platform: platform,
      priceSek: price,
      soldAt: now.subtract(Duration(days: daysAgo)),
    );
  }

  group('AggregatedBookMarketService', () {
    test('aggregates sales from multiple sources', () async {
      final traderaSource = _FakeSource([
        sale(platform: 'tradera', price: 50, daysAgo: 5),
        sale(platform: 'tradera', price: 100, daysAgo: 10),
      ]);
      final vintedSource = _FakeSource([
        sale(platform: 'vinted', price: 75, daysAgo: 3),
      ]);
      final bokborsenSource = _FakeSource([
        sale(platform: 'bokborsen', price: 120, daysAgo: 7),
      ]);

      final service = AggregatedBookMarketService(
        sources: [traderaSource, vintedSource, bokborsenSource],
      );

      final stats = await service.fetchStatsForBookQuery(
        query: 'test book',
        now: now,
      );

      expect(stats, isNotNull);
      expect(stats!.totalSales, 4);
      expect(stats.lowestSoldPriceSek, 50);
      expect(stats.highestSoldPriceSek, 120);
      expect(stats.averageSoldPriceSek, 86);
      expect(stats.sourceCounts, {
        'tradera': 2,
        'vinted': 1,
        'bokborsen': 1,
      });
    });

    test('continues when one source throws', () async {
      final goodSource = _FakeSource([
        sale(platform: 'tradera', price: 100, daysAgo: 5),
      ]);
      final badSource = _FakeSource([], shouldThrow: true);

      final service = AggregatedBookMarketService(
        sources: [goodSource, badSource],
      );

      final stats = await service.fetchStatsForBookQuery(
        query: 'test book',
        now: now,
      );

      expect(stats, isNotNull);
      expect(stats!.totalSales, 1);
      expect(stats.sourceCounts, {'tradera': 1});
    });

    test('returns null when all sources return empty', () async {
      final emptySource1 = _FakeSource([]);
      final emptySource2 = _FakeSource([]);

      final service = AggregatedBookMarketService(
        sources: [emptySource1, emptySource2],
      );

      final stats = await service.fetchStatsForBookQuery(
        query: 'test book',
        now: now,
      );

      expect(stats, isNull);
    });

    test('returns null for blank query', () async {
      final source = _FakeSource([
        sale(platform: 'tradera', price: 100),
      ]);

      final service = AggregatedBookMarketService(sources: [source]);

      final stats = await service.fetchStatsForBookQuery(
        query: '   ',
        now: now,
      );

      expect(stats, isNull);
    });

    test('works with single source', () async {
      final source = _FakeSource([
        sale(platform: 'vinted', price: 80, daysAgo: 2),
        sale(platform: 'vinted', price: 120, daysAgo: 4),
      ]);

      final service = AggregatedBookMarketService(sources: [source]);

      final stats = await service.fetchStatsForBookQuery(
        query: 'book',
        now: now,
      );

      expect(stats, isNotNull);
      expect(stats!.totalSales, 2);
      expect(stats.sourceCounts, {'vinted': 2});
    });
  });
}
