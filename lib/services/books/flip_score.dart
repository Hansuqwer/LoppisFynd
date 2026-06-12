class FlipScore {
  const FlipScore._();

  static int fromPrices({
    required double? purchasePrice,
    required double? medianPrice,
  }) {
    if (purchasePrice == null || medianPrice == null || purchasePrice <= 0) {
      return 0;
    }

    final ratio = medianPrice / purchasePrice;
    if (ratio < 1.0) return ((ratio * 40).clamp(0, 39)).round();
    if (ratio < 1.3) return (40 + ((ratio - 1.0) / 0.3) * 29).round();
    if (ratio < 2.0) return (69 + ((ratio - 1.3) / 0.7) * 21).round();
    return (90 + (ratio - 2.0) * 5).clamp(0, 100).round();
  }
}
