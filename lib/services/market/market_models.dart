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
    required this.p25Sek,
    required this.minSek,
    required this.medianSek,
    required this.p75Sek,
    required this.maxSek,
    required this.lastUpdated,
  });

  final int count;
  final int p25Sek;
  final int minSek;
  final int medianSek;
  final int p75Sek;
  final int maxSek;
  final DateTime lastUpdated;
}

class MarketComps {
  const MarketComps({required this.sales, required this.stats});

  final List<MarketSale> sales;
  final MarketStats stats;

  Map<String, Object?> toJson() => {
    'sales': sales.map((s) => s.toJson()).toList(),
    'stats': {
      'count': stats.count,
      'p25Sek': stats.p25Sek,
      'minSek': stats.minSek,
      'medianSek': stats.medianSek,
      'p75Sek': stats.p75Sek,
      'maxSek': stats.maxSek,
      'lastUpdated': stats.lastUpdated.toIso8601String(),
    },
  };
}
