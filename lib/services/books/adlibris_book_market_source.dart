import '../market/adlibris_market_data_source.dart';
import 'aggregated_book_market_service.dart';
import 'book_market_data_service.dart';

/// Adapts [AdlibrisMarketDataSource] to the [BookMarketSource] interface
/// used by [AggregatedBookMarketService].
class AdlibrisBookMarketSource implements BookMarketSource {
  const AdlibrisBookMarketSource({required this.dataSource});

  final AdlibrisMarketDataSource dataSource;

  @override
  Future<List<BookSale>> search({required String query, DateTime? now}) {
    return dataSource.search(query: query, now: now);
  }
}
