import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/features/analyzer/profit_calculator.dart';
import 'package:fynd_loppis/services/books/flip_score.dart';

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

  test('FlipScore maps price ratios to score buckets', () {
    expect(
      FlipScore.fromPrices(purchasePrice: 100, medianPrice: 90),
      lessThan(40),
    );
    expect(
      FlipScore.fromPrices(purchasePrice: 100, medianPrice: 120),
      inInclusiveRange(40, 68),
    );
    expect(
      FlipScore.fromPrices(purchasePrice: 100, medianPrice: 150),
      inInclusiveRange(69, 89),
    );
    expect(
      FlipScore.fromPrices(purchasePrice: 100, medianPrice: 200),
      greaterThanOrEqualTo(90),
    );
  });
}
