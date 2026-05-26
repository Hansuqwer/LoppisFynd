import '../market/vinted_market_data_source.dart';
import 'aggregated_book_market_service.dart';
import 'book_market_data_service.dart';

class VintedBookMarketSource implements BookMarketSource {
  const VintedBookMarketSource({required this.dataSource});

  final VintedMarketDataSource dataSource;

  @override
  Future<List<BookSale>> search({required String query, DateTime? now}) {
    return dataSource.search(query: query, now: now);
  }
}
