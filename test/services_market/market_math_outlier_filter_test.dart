import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/market/market_math.dart';
import 'package:fynd_loppis/services/market/market_models.dart';

void main() {
  test('MarketMath filterSalesOutliersIqr removes extreme outliers', () {
    final baseDate = DateTime(2026, 2, 1);
    final sales = <MarketSale>[
      for (final p in [100, 110, 120, 130, 140, 150, 160, 170, 10000])
        MarketSale(priceSek: p, endDate: baseDate),
    ];

    final filtered = MarketMath.filterSalesOutliersIqr(sales);
    expect(filtered.length, lessThan(sales.length));
    expect(filtered.any((s) => s.priceSek == 10000), isFalse);
  });
}
