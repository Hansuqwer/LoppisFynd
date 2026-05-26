import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../books/book_market_data_service.dart';

class BokborsenMarketDataSource {
  BokborsenMarketDataSource({
    required Uri functionUrl,
    http.Client? httpClient,
    String? anonKey,
    Duration timeout = const Duration(seconds: 15),
  }) : _functionUrl = functionUrl,
       _httpClient = httpClient ?? http.Client(),
       _anonKey = anonKey,
       _timeout = timeout;

  final Uri _functionUrl;
  final http.Client _httpClient;
  final String? _anonKey;
  final Duration _timeout;

  Future<List<BookSale>> search({required String query, DateTime? now}) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return const [];

    final headers = <String, String>{'content-type': 'application/json'};
    final anonKey = _anonKey;
    if (anonKey != null && anonKey.isNotEmpty) {
      headers['apikey'] = anonKey;
      headers['authorization'] = 'Bearer $anonKey';
    }

    final payload = jsonEncode({'query': normalized, 'maxResults': 50});

    http.Response response;
    try {
      response = await _httpClient
          .post(_functionUrl, headers: headers, body: payload)
          .timeout(_timeout);
    } on TimeoutException {
      return const [];
    } on http.ClientException {
      return const [];
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return const [];
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) return const [];

    final items = decoded['items'];
    if (items is! List) return const [];

    return _parseSales(items, now: now);
  }

  List<BookSale> _parseSales(List<Object?> items, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final sales = <BookSale>[];

    for (final raw in items) {
      if (raw is! Map) continue;
      final item = raw.cast<String, Object?>();

      final price = _extractPrice(item);
      if (price == null || price <= 0) continue;

      final soldAt = _extractDate(item) ?? current;
      final url = _optionalString(item['url'] ?? item['listingUrl']);

      sales.add(
        BookSale(
          platform: 'bokborsen',
          priceSek: price,
          soldAt: soldAt,
          listingUrl: url,
          fetchedAt: current,
        ),
      );
    }

    return sales;
  }

  int? _extractPrice(Map<String, Object?> item) {
    final price = item['price'] ?? item['priceSek'];
    if (price is num) return price.round();
    if (price is String) return int.tryParse(price);
    return null;
  }

  DateTime? _extractDate(Map<String, Object?> item) {
    final date = item['soldAt'] ?? item['date'] ?? item['soldDate'];
    if (date is String) return DateTime.tryParse(date);
    return null;
  }
}

String? _optionalString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
