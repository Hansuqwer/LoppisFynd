import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/book_market_data.dart';

part 'book_market_data_dao.g.dart';

@DriftAccessor(tables: [BookMarketData])
class BookMarketDataDao extends DatabaseAccessor<AppDatabase>
    with _$BookMarketDataDaoMixin {
  BookMarketDataDao(super.db);

  Future<List<BookMarketDataData>> getByBookId(String bookId) {
    return (select(bookMarketData)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm.desc(t.soldAt)]))
        .get();
  }

  Future<List<BookMarketDataData>> getByIsbn(String isbn) {
    return (select(bookMarketData)
          ..where((t) => t.isbn.equals(isbn))
          ..orderBy([(t) => OrderingTerm.desc(t.soldAt)]))
        .get();
  }

  Future<List<BookMarketDataData>> getFreshByIsbn(
    String isbn, {
    required DateTime now,
    Duration ttl = const Duration(days: 7),
  }) async {
    final cutoff = now.subtract(ttl);
    return (select(bookMarketData)
          ..where(
            (t) =>
                t.isbn.equals(isbn) & t.fetchedAt.isBiggerOrEqualValue(cutoff),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.soldAt)]))
        .get();
  }

  Future<void> upsertBatch({
    required String bookId,
    required String isbn,
    required List<
      ({
        String id,
        String platform,
        int priceSek,
        DateTime soldAt,
        String? listingUrl,
        DateTime fetchedAt,
      })
    >
    items,
  }) async {
    await batch((batch) {
      for (final item in items) {
        batch.insert(
          bookMarketData,
          BookMarketDataCompanion(
            id: Value(item.id),
            bookId: Value(bookId),
            isbn: Value(isbn),
            platform: Value(item.platform),
            priceSek: Value(item.priceSek),
            soldAt: Value(item.soldAt),
            listingUrl: Value(item.listingUrl),
            fetchedAt: Value(item.fetchedAt),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<int> deleteByBookId(String bookId) {
    return (delete(bookMarketData)..where((t) => t.bookId.equals(bookId))).go();
  }
}
