class FlipFactor {
  static String grade({
    required double purchasePrice,
    required double expectedSalePrice,
  }) {
    if (purchasePrice <= 0 || expectedSalePrice <= 0) return '—';
    final ratio = expectedSalePrice / purchasePrice;
    if (ratio < 1.0) return 'No';
    if (ratio < 1.3) return 'Maybe';
    if (ratio < 1.8) return 'Good';
    return 'Hot';
  }
}
