import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/features/analyzer/flip_factor.dart';
import 'package:fynd_loppis/features/analyzer/profit_calculator.dart';

void main() {
  test('ProfitCalculator grossProfit works', () {
    expect(
      ProfitCalculator.grossProfit(purchasePrice: 100, expectedSalePrice: 250),
      150,
    );
    expect(
      ProfitCalculator.grossProfit(purchasePrice: null, expectedSalePrice: 250),
      null,
    );
  });

  test('ProfitCalculator netProfit applies fee rate', () {
    expect(
      ProfitCalculator.netProfit(purchasePrice: 100, expectedSalePrice: 250),
      closeTo(125, 0.0001),
    );
    expect(
      ProfitCalculator.netProfit(
        purchasePrice: 100,
        expectedSalePrice: 250,
        platformFeeRate: 0.2,
      ),
      closeTo(100, 0.0001),
    );
  });

  test('FlipFactor grade buckets', () {
    expect(FlipFactor.grade(purchasePrice: 100, expectedSalePrice: 90), 'No');
    expect(
      FlipFactor.grade(purchasePrice: 100, expectedSalePrice: 120),
      'Maybe',
    );
    expect(
      FlipFactor.grade(purchasePrice: 100, expectedSalePrice: 150),
      'Good',
    );
    expect(FlipFactor.grade(purchasePrice: 100, expectedSalePrice: 200), 'Hot');
  });
}
