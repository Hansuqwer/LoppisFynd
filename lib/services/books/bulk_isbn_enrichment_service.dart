import '../../core/database/app_database.dart';
import 'book_market_data_service.dart';
import 'book_market_service.dart';
import 'isbn_lookup_service.dart';

/// Enriches the [Books] table with market data for ISBNs that have already
/// been scanned and saved but lack sold-price statistics.
///
/// This is a pure Dart service with no Flutter imports.
///
/// Typical call sites:
///   - Settings screen "Fetch market data for all books" button.
///   - Background sync (future).
class BulkIsbnEnrichmentService {
  BulkIsbnEnrichmentService({
    required AppDatabase db,
    required BookMetadataLookup isbnLookup,
    BookMarketStatsLookup? market,
    int maxCallsPerDay = 50,
    String quotaDayKeyPrefix = 'bulk_enrich',
  }) : _db = db,
       _isbnLookup = isbnLookup,
       _market = market,
       _maxCallsPerDay = maxCallsPerDay,
       _quotaDayKeyPrefix = quotaDayKeyPrefix;

  final AppDatabase _db;
  final BookMetadataLookup _isbnLookup;
  final BookMarketStatsLookup? _market;
  final int _maxCallsPerDay;
  final String _quotaDayKeyPrefix;

  /// Enrich up to [batchSize] saved books that have no average sold price
  /// and have not been updated in the last [staleBefore] period.
  ///
  /// Returns the number of books successfully updated.
  Future<int> enrichStale({
    int batchSize = 20,
    Duration staleBefore = const Duration(days: 7),
  }) async {
    final market = _market;
    if (market == null) return 0;

    final olderThan = DateTime.now().subtract(staleBefore);
    final stale = await _db.booksDao.listStaleMarketStats(
      limit: batchSize,
      olderThan: olderThan,
    );
    if (stale.isEmpty) return 0;

    return _enrichBooks(stale.map((b) => b.isbn).toList(), market: market);
  }

  /// Enrich a specific list of ISBNs regardless of their current staleness.
  ///
  /// Returns the number of books successfully updated.
  Future<int> enrichIsbnList(List<String> isbns) async {
    final market = _market;
    if (market == null || isbns.isEmpty) return 0;
    return _enrichBooks(isbns, market: market);
  }

  Future<int> _enrichBooks(
    List<String> isbns, {
    required BookMarketStatsLookup market,
  }) async {
    final now = DateTime.now();
    final dayKey = _dayKey(now, _quotaDayKeyPrefix);
    var used = await _db.syncQuotasDao.getUsed(dayKey);
    var enriched = 0;

    for (final isbn in isbns) {
      if (used >= _maxCallsPerDay) break;

      // 1. Resolve metadata: title + author needed to build query.
      final meta = await _isbnLookup.lookupIsbn(isbn);
      if (meta == null) continue;

      final author = meta.authors.isNotEmpty ? meta.authors.first : '';
      final query = '${meta.title} $author'.trim().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      if (query.length < 3) continue;

      // 2. Fetch market stats.
      BookMarketStats? stats;
      try {
        stats = await market.fetchStatsForBookQuery(query: query);
      } catch (_) {
        continue;
      } finally {
        await _db.syncQuotasDao.incrementUsed(dayKey, 1);
        used += 1;
      }

      if (stats == null) continue;

      // 3. Find the book row by ISBN and update it.
      final book = await _db.booksDao.getByIsbn(isbn);
      if (book == null) continue;

      await _db.booksDao.setMarketStats(
        id: book.id,
        highestSoldPriceSek: stats.highestSoldPriceSek,
        averageSoldPriceSek: stats.averageSoldPriceSek,
        lowestSoldPriceSek: stats.lowestSoldPriceSek,
        salesPerMonth: stats.salesPerMonth,
        totalSales: stats.totalSales,
      );

      enriched += 1;
    }

    return enriched;
  }
}

String _dayKey(DateTime dt, String prefix) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '${prefix}_$y-$m-$d';
}
