import '../books/book_market_data_service.dart';
import 'apify_client.dart';

class VintedMarketDataSource {
  VintedMarketDataSource({
    required ApifyClient apifyClient,
    required String actorId,
    String country = 'se',
    int maxItems = 50,
  }) : _apifyClient = apifyClient,
       _actorId = actorId,
       _country = country,
       _maxItems = maxItems;

  final ApifyClient _apifyClient;
  final String _actorId;
  final String _country;
  final int _maxItems;

  Future<List<BookSale>> search({required String query, DateTime? now}) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return const [];

    List<Map<String, Object?>> items;
    try {
      items = await _apifyClient.runActorAndWait(
        actorId: _actorId,
        input: {
          'searchQuery': normalized,
          'maxItems': _maxItems,
          'country': _country,
        },
      );
    } on ApifyClientException {
      return const [];
    }

    return _parseSales(items, now: now);
  }

  List<BookSale> _parseSales(
    List<Map<String, Object?>> items, {
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final sales = <BookSale>[];

    for (final item in items) {
      final price = _extractPriceSek(item);
      if (price == null || price <= 0) continue;

      final soldAt = _extractSoldAt(item) ?? current;
      final url = _optionalString(item['url']);

      sales.add(
        BookSale(
          platform: 'vinted',
          priceSek: price,
          soldAt: soldAt,
          listingUrl: url,
          fetchedAt: current,
        ),
      );
    }

    return sales;
  }

  int? _extractPriceSek(Map<String, Object?> item) {
    final price = item['price'];
    if (price is num) return price.round();

    final priceSek = item['priceSek'];
    if (priceSek is num) return priceSek.round();

    final priceObj = item['price'];
    if (priceObj is Map) {
      final amount = priceObj['amount'];
      if (amount is num) return amount.round();
    }

    return null;
  }

  DateTime? _extractSoldAt(Map<String, Object?> item) {
    final soldAt = item['soldAt'] ?? item['sold_at'] ?? item['soldDate'];
    if (soldAt is String) {
      return DateTime.tryParse(soldAt);
    }
    return null;
  }
}

String? _optionalString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
