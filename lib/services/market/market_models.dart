class MarketSale {
  const MarketSale({required this.priceSek, required this.endDate});

  final int priceSek;
  final DateTime endDate;

  Map<String, Object?> toJson() => {
    'priceSek': priceSek,
    'endDate': endDate.toIso8601String(),
  };
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

class MarketComps {
  const MarketComps({required this.sales, required this.stats});

  final List<MarketSale> sales;
  final MarketStats stats;

  Map<String, Object?> toJson() => {
    'sales': sales.map((s) => s.toJson()).toList(),
    'stats': {
      'count': stats.count,
      'minSek': stats.minSek,
      'medianSek': stats.medianSek,
      'maxSek': stats.maxSek,
    },
  };
}
