import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;

import 'package:fynd_loppis/services/books/bokborsen_book_market_source.dart';
import 'package:fynd_loppis/services/market/bokborsen_market_data_source.dart';

void main() {
  final now = DateTime(2026, 5, 26);

  http.Client fakeClient(Map<String, Object?> responseBody) {
    return http_testing.MockClient((request) async {
      return http.Response(jsonEncode(responseBody), 200);
    });
  }

  http.Client errorClient(int statusCode) {
    return http_testing.MockClient((request) async {
      return http.Response('error', statusCode);
    });
  }

  group('BokborsenBookMarketSource', () {
    test('returns BookSale list from BokborsenMarketDataSource', () async {
      final client = fakeClient({
        'items': [
          {
            'price': 85,
            'soldAt': now.subtract(const Duration(days: 3)).toIso8601String(),
            'url': 'https://bokborsen.se/1',
          },
          {
            'price': 140,
            'soldAt': now.subtract(const Duration(days: 7)).toIso8601String(),
            'url': 'https://bokborsen.se/2',
          },
        ],
      });

      final dataSource = BokborsenMarketDataSource(
        functionUrl: Uri.parse('https://example.com/bokborsen'),
        httpClient: client,
      );
      final source = BokborsenBookMarketSource(dataSource: dataSource);

      final sales = await source.search(query: 'test book', now: now);

      expect(sales.length, 2);
      expect(sales[0].platform, 'bokborsen');
      expect(sales[0].priceSek, 85);
      expect(sales[1].priceSek, 140);
    });

    test('returns empty list when HTTP request fails', () async {
      final client = errorClient(500);
      final dataSource = BokborsenMarketDataSource(
        functionUrl: Uri.parse('https://example.com/bokborsen'),
        httpClient: client,
      );
      final source = BokborsenBookMarketSource(dataSource: dataSource);

      final sales = await source.search(query: 'test book', now: now);

      expect(sales, isEmpty);
    });

    test('returns empty list for blank query', () async {
      final client = fakeClient({'items': []});
      final dataSource = BokborsenMarketDataSource(
        functionUrl: Uri.parse('https://example.com/bokborsen'),
        httpClient: client,
      );
      final source = BokborsenBookMarketSource(dataSource: dataSource);

      final sales = await source.search(query: '   ', now: now);

      expect(sales, isEmpty);
    });

    test('filters out items with zero or missing price', () async {
      final client = fakeClient({
        'items': [
          {'price': 0, 'url': 'https://bokborsen.se/1'},
          {'url': 'https://bokborsen.se/2'},
          {
            'price': 60,
            'soldAt': now.subtract(const Duration(days: 1)).toIso8601String(),
            'url': 'https://bokborsen.se/3',
          },
        ],
      });

      final dataSource = BokborsenMarketDataSource(
        functionUrl: Uri.parse('https://example.com/bokborsen'),
        httpClient: client,
      );
      final source = BokborsenBookMarketSource(dataSource: dataSource);

      final sales = await source.search(query: 'book', now: now);

      expect(sales.length, 1);
      expect(sales[0].priceSek, 60);
    });
  });
}
