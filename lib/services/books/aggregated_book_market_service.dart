import '../books/book_market_data_service.dart';
import '../books/book_market_service.dart';

abstract class BookMarketSource {
  Future<List<BookSale>> search({required String query, DateTime? now});
}

class TraderaBookMarketSource implements BookMarketSource {
  const TraderaBookMarketSource({required this.service});

  final BookMarketStatsLookup service;

  @override
  Future<List<BookSale>> search({required String query, DateTime? now}) async {
    final stats = await service.fetchStatsForBookQuery(query: query, now: now);
    return stats?.recentSales ?? const [];
  }
}

class AggregatedBookMarketService implements BookMarketStatsLookup {
  AggregatedBookMarketService({
    required List<BookMarketSource> sources,
    BookMarketDataAggregator aggregator = const BookMarketDataAggregator(),
  }) : _sources = sources,
       _aggregator = aggregator;

  final List<BookMarketSource> _sources;
  final BookMarketDataAggregator _aggregator;

  @override
  Future<BookMarketStats?> fetchStatsForBookQuery({
    required String query,
    DateTime? now,
    int itemsPerPage = 50,
  }) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return null;

    final results = await Future.wait(
      _sources.map(
        (source) => source
            .search(query: normalized, now: now)
            .catchError((_) => <BookSale>[]),
      ),
    );

    final allSales = results.expand((sales) => sales).toList(growable: false);
    if (allSales.isEmpty) return null;

    return _aggregator.aggregate(allSales, now: now);
  }
}
