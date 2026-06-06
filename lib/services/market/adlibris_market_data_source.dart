import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../books/book_market_data_service.dart';

/// Fetches used-book listing prices from Adlibris Sweden via the
/// `adlibris-scraper` Supabase Edge Function.
///
/// **Important:** Adlibris shows current *asking* prices, not sold
/// transaction prices.  [BookSale.soldAt] is set to [DateTime.now] as a
/// proxy — this makes Adlibris data useful for demand signalling and price
/// ceiling estimation, but it is not a true sold-price comp.
/// The aggregator treats all sources equally; callers that need
/// sold-only data should filter by platform.
class AdlibrisMarketDataSource {
  AdlibrisMarketDataSource({
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

  Future<List<BookSale>> search({
    required String query,
    DateTime? now,
  }) async {
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

      // Adlibris has no sold date — use fetch time as proxy.
      final url = _optionalString(item['url']);

      sales.add(
        BookSale(
          platform: 'adlibris',
          priceSek: price,
          soldAt: current,
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
}

String? _optionalString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
