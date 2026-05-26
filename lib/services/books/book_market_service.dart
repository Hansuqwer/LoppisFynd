import '../market/tradera_client.dart';
import 'book_market_data_service.dart';
import 'tradera_book_market_adapter.dart';

abstract class BookMarketStatsLookup {
  Future<BookMarketStats?> fetchStatsForBookQuery({
    required String query,
    DateTime? now,
    int itemsPerPage,
  });
}

class BookMarketService implements BookMarketStatsLookup {
  const BookMarketService({
    required TraderaClient traderaClient,
    TraderaBookMarketAdapter adapter = const TraderaBookMarketAdapter(),
  }) : _traderaClient = traderaClient,
       _adapter = adapter;

  final TraderaClient _traderaClient;
  final TraderaBookMarketAdapter _adapter;

  @override
  Future<BookMarketStats?> fetchStatsForBookQuery({
    required String query,
    DateTime? now,
    int itemsPerPage = 50,
  }) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return null;

    final response = await _traderaClient.searchEnded(
      searchWords: normalized,
      itemsPerPage: itemsPerPage,
    );
    return _adapter.statsFromResponse(response, now: now);
  }
}
