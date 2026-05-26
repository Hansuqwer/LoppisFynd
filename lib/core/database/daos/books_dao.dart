import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/books.dart';

part 'books_dao.g.dart';

@DriftAccessor(tables: [Books])
class BooksDao extends DatabaseAccessor<AppDatabase> with _$BooksDaoMixin {
  BooksDao(super.db);

  Future<Book?> getById(String id) {
    return (select(books)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Book?> getByIsbn(String isbn) {
    return (select(books)..where((t) => t.isbn.equals(isbn))).getSingleOrNull();
  }

  Stream<List<Book>> watchAll() {
    return (select(
      books,
    )..orderBy([(t) => OrderingTerm.desc(t.scannedAt)])).watch();
  }

  Stream<List<Book>> watchSaved() {
    return (select(books)
          ..where((t) => t.saved.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.scannedAt)]))
        .watch();
  }

  Future<void> upsert({
    required String id,
    String? userId,
    required String isbn,
    required String title,
    String? author,
    String? publisher,
    int? publishYear,
    String? coverUrl,
    String? categories,
    required DateTime scannedAt,
    required DateTime updatedAt,
  }) {
    return into(books).insertOnConflictUpdate(
      BooksCompanion(
        id: Value(id),
        userId: Value(userId),
        isbn: Value(isbn),
        title: Value(title),
        author: Value(author),
        publisher: Value(publisher),
        publishYear: Value(publishYear),
        coverUrl: Value(coverUrl),
        categories: Value(categories),
        scannedAt: Value(scannedAt),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> setPurchasePrice({
    required String id,
    required int priceSek,
    required bool saved,
  }) {
    return (update(books)..where((t) => t.id.equals(id))).write(
      BooksCompanion(
        purchasePriceSek: Value(priceSek),
        saved: Value(saved),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setMarketStats({
    required String id,
    int? highestSoldPriceSek,
    int? averageSoldPriceSek,
    int? lowestSoldPriceSek,
    double? salesPerMonth,
    int? totalSales,
  }) {
    return (update(books)..where((t) => t.id.equals(id))).write(
      BooksCompanion(
        highestSoldPriceSek: Value(highestSoldPriceSek),
        averageSoldPriceSek: Value(averageSoldPriceSek),
        lowestSoldPriceSek: Value(lowestSoldPriceSek),
        salesPerMonth: Value(salesPerMonth),
        totalSales: Value(totalSales),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteById(String id) {
    return (delete(books)..where((t) => t.id.equals(id))).go();
  }
}
