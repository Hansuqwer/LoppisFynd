class MarketSale {
  const MarketSale({required this.priceSek, required this.endDate});

  final int priceSek;
  final DateTime endDate;
}

class MarketStats {
  const MarketStats({
    required this.count,
    required this.minSek,
    required this.medianSek,
    required this.maxSek,
  });

  final int count;
  final int minSek;
  final int medianSek;
  final int maxSek;
}
