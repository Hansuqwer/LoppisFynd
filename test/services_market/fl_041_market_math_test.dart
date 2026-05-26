import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/market/market_math.dart';
import 'package:fynd_loppis/services/market/market_models.dart';

void main() {
  test('MarketMath median odd/even', () {
    final salesOdd = [
      MarketSale(priceSek: 100, endDate: DateTime(2026, 1, 1)),
      MarketSale(priceSek: 200, endDate: DateTime(2026, 1, 2)),
      MarketSale(priceSek: 300, endDate: DateTime(2026, 1, 3)),
    ];
    final oddStats = MarketMath.statsFromSales(salesOdd);
    expect(oddStats.medianSek, 200);

    final salesEven = [
      MarketSale(priceSek: 100, endDate: DateTime(2026, 1, 1)),
      MarketSale(priceSek: 200, endDate: DateTime(2026, 1, 2)),
      MarketSale(priceSek: 300, endDate: DateTime(2026, 1, 3)),
      MarketSale(priceSek: 400, endDate: DateTime(2026, 1, 4)),
    ];
    final evenStats = MarketMath.statsFromSales(salesEven);
    expect(evenStats.medianSek, 250);
  });
}
