import '../market/blocket_market_data_source.dart';
import 'aggregated_book_market_service.dart';
import 'book_market_data_service.dart';

/// Adapts [BlocketMarketDataSource] to the [BookMarketSource] interface.
class BlocketBookMarketSource implements BookMarketSource {
  const BlocketBookMarketSource({required this.dataSource});

  final BlocketMarketDataSource dataSource;

  @override
  Future<List<BookSale>> search({required String query, DateTime? now}) {
    return dataSource.search(query: query, now: now);
  }
}
