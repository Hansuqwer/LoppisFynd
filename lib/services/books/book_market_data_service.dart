class BookSale {
  const BookSale({
    required this.platform,
    required this.priceSek,
    required this.soldAt,
    this.listingUrl,
    this.fetchedAt,
  });

  final String platform;
  final int priceSek;
  final DateTime soldAt;
  final String? listingUrl;
  final DateTime? fetchedAt;
}

class BookMarketStats {
  const BookMarketStats({
    required this.highestSoldPriceSek,
    required this.averageSoldPriceSek,
    required this.lowestSoldPriceSek,
    required this.totalSales,
    required this.salesPerMonth,
    required this.sourceCounts,
    required this.recentSales,
  });

  final int highestSoldPriceSek;
  final int averageSoldPriceSek;
  final int lowestSoldPriceSek;
  final int totalSales;
  final double salesPerMonth;
  final Map<String, int> sourceCounts;
  final List<BookSale> recentSales;
}

class BookMarketDataAggregator {
  const BookMarketDataAggregator({
    this.period = const Duration(days: 365),
    this.maxRecentSales = 20,
  });

  final Duration period;
  final int maxRecentSales;

  BookMarketStats? aggregate(List<BookSale> sales, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final periodStart = current.subtract(period);
    final scoped = sales
        .where((sale) => sale.priceSek > 0)
        .where((sale) => !sale.soldAt.isBefore(periodStart))
        .where((sale) => !sale.soldAt.isAfter(current))
        .toList(growable: false);
    if (scoped.isEmpty) return null;

    final deduplicated = _deduplicate(scoped);
    final filtered = _filterOutliersIqr(deduplicated);
    final usable = filtered.length >= 5 ? filtered : deduplicated;
    if (usable.isEmpty) return null;

    final prices = usable.map((sale) => sale.priceSek).toList()..sort();
    final recent = [...usable]..sort((a, b) => b.soldAt.compareTo(a.soldAt));

    return BookMarketStats(
      highestSoldPriceSek: prices.last,
      averageSoldPriceSek: _averageInt(prices),
      lowestSoldPriceSek: prices.first,
      totalSales: usable.length,
      salesPerMonth: _salesPerMonth(usable.length, period),
      sourceCounts: _sourceCounts(usable),
      recentSales: recent.take(maxRecentSales).toList(growable: false),
    );
  }

  List<BookSale> deduplicateForTest(List<BookSale> sales) {
    return _deduplicate(sales);
  }

  List<BookSale> filterOutliersForTest(List<BookSale> sales) {
    return _filterOutliersIqr(sales);
  }
}

List<BookSale> _deduplicate(List<BookSale> sales) {
  final seen = <String>{};
  final result = <BookSale>[];
  for (final sale in sales) {
    final key = [
      sale.priceSek,
      DateTime(
        sale.soldAt.year,
        sale.soldAt.month,
        sale.soldAt.day,
      ).toIso8601String(),
      sale.listingUrl ?? '',
    ].join('|');
    if (seen.add(key)) {
      result.add(sale);
    }
  }
  return result;
}

List<BookSale> _filterOutliersIqr(List<BookSale> sales) {
  if (sales.length < 8) return sales;
  final sortedPrices = sales.map((sale) => sale.priceSek).toList()..sort();
  final q1 = _quartile(sortedPrices, 0.25);
  final q3 = _quartile(sortedPrices, 0.75);
  final iqr = (q3 - q1).toDouble();
  if (iqr <= 0) return sales;

  final lower = q1 - (1.5 * iqr);
  final upper = q3 + (1.5 * iqr);
  return sales
      .where((sale) => sale.priceSek >= lower && sale.priceSek <= upper)
      .toList(growable: false);
}

int _averageInt(List<int> sortedPrices) {
  final total = sortedPrices.fold<int>(0, (sum, price) => sum + price);
  return (total / sortedPrices.length).round();
}

int _quartile(List<int> sorted, double p) {
  if (sorted.isEmpty) throw const FormatException('No data');
  final idx = p * (sorted.length - 1);
  final lo = idx.floor();
  final hi = idx.ceil();
  if (lo == hi) return sorted[lo];
  final t = idx - lo;
  return ((sorted[lo] * (1 - t)) + (sorted[hi] * t)).round();
}

double _salesPerMonth(int totalSales, Duration period) {
  final months = period.inDays / 30.4375;
  if (months <= 0) return totalSales.toDouble();
  return double.parse((totalSales / months).toStringAsFixed(2));
}

Map<String, int> _sourceCounts(List<BookSale> sales) {
  final counts = <String, int>{};
  for (final sale in sales) {
    counts[sale.platform] = (counts[sale.platform] ?? 0) + 1;
  }
  return Map.unmodifiable(counts);
}
