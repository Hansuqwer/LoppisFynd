class ProfitCalculator {
  static const defaultPlatformFeeRate = 0.10;

  static double? grossProfit({
    required double? purchasePrice,
    required double? expectedSalePrice,
  }) {
    if (purchasePrice == null || expectedSalePrice == null) return null;
    return expectedSalePrice - purchasePrice;
  }

  static double? netProfit({
    required double? purchasePrice,
    required double? expectedSalePrice,
    double platformFeeRate = defaultPlatformFeeRate,
    double fixedFeesSek = 0,
    double shippingPaidBySellerSek = 0,
  }) {
    if (purchasePrice == null || expectedSalePrice == null) return null;
    final feeRate = platformFeeRate.clamp(0.0, 0.5);
    final platformFee = expectedSalePrice * feeRate;
    return expectedSalePrice -
        platformFee -
        fixedFeesSek -
        shippingPaidBySellerSek -
        purchasePrice;
  }
}
