import 'market_models.dart';

class MarketMath {
  static MarketStats statsFromSales(
    List<MarketSale> sales, {
    DateTime? lastUpdated,
  }) {
    if (sales.isEmpty) {
      throw const FormatException('No sales');
    }
    final prices = sales.map((s) => s.priceSek).toList()..sort();

    final p25Sek = _quartile(prices, 0.25);
    final minSek = prices.first;
    final maxSek = prices.last;
    final medianSek = _medianInt(prices);
    final p75Sek = _quartile(prices, 0.75);

    return MarketStats(
      count: prices.length,
      p25Sek: p25Sek,
      minSek: minSek,
      medianSek: medianSek,
      p75Sek: p75Sek,
      maxSek: maxSek,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  static MarketStats statsFromSalesWithOutlierFilter(
    List<MarketSale> sales, {
    DateTime? lastUpdated,
  }) {
    final filtered = filterSalesOutliersIqr(sales);
    if (filtered.length >= 5) {
      return statsFromSales(filtered, lastUpdated: lastUpdated);
    }
    return statsFromSales(sales, lastUpdated: lastUpdated);
  }

  static List<MarketSale> filterSalesOutliersIqr(List<MarketSale> sales) {
    if (sales.length < 8) return sales;
    final sortedPrices = sales.map((s) => s.priceSek).toList()..sort();

    final q1 = _quartile(sortedPrices, 0.25);
    final q3 = _quartile(sortedPrices, 0.75);
    final iqr = (q3 - q1).toDouble();
    if (iqr <= 0) return sales;

    final lower = q1 - (1.5 * iqr);
    final upper = q3 + (1.5 * iqr);
    return sales
        .where((s) => s.priceSek >= lower && s.priceSek <= upper)
        .toList(growable: false);
  }
}

int _medianInt(List<int> sorted) {
  final n = sorted.length;
  final mid = n ~/ 2;
  if (n.isOdd) return sorted[mid];
  return ((sorted[mid - 1] + sorted[mid]) / 2).round();
}

int _quartile(List<int> sorted, double p) {
  final n = sorted.length;
  if (n == 0) throw const FormatException('No data');

  final idx = (p * (n - 1));
  final lo = idx.floor();
  final hi = idx.ceil();
  if (lo == hi) return sorted[lo];
  final t = idx - lo;
  final v = (sorted[lo] * (1 - t)) + (sorted[hi] * t);
  return v.round();
}
