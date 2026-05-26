import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/books/book_market_data_service.dart';
import 'package:fynd_loppis/services/books/vinted_book_market_source.dart';
import 'package:fynd_loppis/services/market/vinted_market_data_source.dart';
import 'package:fynd_loppis/services/market/apify_client.dart';

class _FakeApifyClient extends ApifyClient {
  _FakeApifyClient(this._items) : super(apiToken: 'fake');

  final List<Map<String, Object?>> _items;

  @override
  Future<List<Map<String, Object?>>> runActorAndWait({
    required String actorId,
    required Map<String, Object?> input,
    int? memoryMbytes,
    Duration? runTimeout,
  }) async {
    return _items;
  }
}

class _ThrowingApifyClient extends ApifyClient {
  _ThrowingApifyClient() : super(apiToken: 'fake');

  @override
  Future<List<Map<String, Object?>>> runActorAndWait({
    required String actorId,
    required Map<String, Object?> input,
    int? memoryMbytes,
    Duration? runTimeout,
  }) async {
    throw const ApifyClientException('test error');
  }
}

void main() {
  final now = DateTime(2026, 5, 26);

  group('VintedBookMarketSource', () {
    test('returns BookSale list from VintedMarketDataSource', () async {
      final client = _FakeApifyClient([
        {
          'price': 75,
          'soldAt': now.subtract(const Duration(days: 2)).toIso8601String(),
          'url': 'https://vinted.se/1',
        },
        {
          'price': 120,
          'soldAt': now.subtract(const Duration(days: 5)).toIso8601String(),
          'url': 'https://vinted.se/2',
        },
      ]);

      final dataSource = VintedMarketDataSource(
        apifyClient: client,
        actorId: 'test-actor',
      );
      final source = VintedBookMarketSource(dataSource: dataSource);

      final sales = await source.search(query: 'test book', now: now);

      expect(sales.length, 2);
      expect(sales[0].platform, 'vinted');
      expect(sales[0].priceSek, 75);
      expect(sales[1].priceSek, 120);
    });

    test('returns empty list when Apify throws', () async {
      final client = _ThrowingApifyClient();
      final dataSource = VintedMarketDataSource(
        apifyClient: client,
        actorId: 'test-actor',
      );
      final source = VintedBookMarketSource(dataSource: dataSource);

      final sales = await source.search(query: 'test book', now: now);

      expect(sales, isEmpty);
    });

    test('returns empty list for blank query', () async {
      final client = _FakeApifyClient([]);
      final dataSource = VintedMarketDataSource(
        apifyClient: client,
        actorId: 'test-actor',
      );
      final source = VintedBookMarketSource(dataSource: dataSource);

      final sales = await source.search(query: '   ', now: now);

      expect(sales, isEmpty);
    });

    test('filters out items with zero or missing price', () async {
      final client = _FakeApifyClient([
        {'price': 0, 'url': 'https://vinted.se/1'},
        {'url': 'https://vinted.se/2'},
        {
          'price': 50,
          'soldAt': now.subtract(const Duration(days: 1)).toIso8601String(),
          'url': 'https://vinted.se/3',
        },
      ]);

      final dataSource = VintedMarketDataSource(
        apifyClient: client,
        actorId: 'test-actor',
      );
      final source = VintedBookMarketSource(dataSource: dataSource);

      final sales = await source.search(query: 'book', now: now);

      expect(sales.length, 1);
      expect(sales[0].priceSek, 50);
    });
  });
}
