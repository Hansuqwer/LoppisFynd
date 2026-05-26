import '../market/bokborsen_market_data_source.dart';
import 'aggregated_book_market_service.dart';
import 'book_market_data_service.dart';

class BokborsenBookMarketSource implements BookMarketSource {
  const BokborsenBookMarketSource({required this.dataSource});

  final BokborsenMarketDataSource dataSource;

  @override
  Future<List<BookSale>> search({required String query, DateTime? now}) {
    return dataSource.search(query: query, now: now);
  }
}
