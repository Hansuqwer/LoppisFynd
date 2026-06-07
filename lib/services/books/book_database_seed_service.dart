import '../../core/database/app_database.dart';

part 'book_database_seed_data.dart';

class BookDatabaseSeedService {
  BookDatabaseSeedService({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  Future<void> ensureSeeded() async {
    // Vi kollar bara om tabellen har några rader i allmänhet, men listStaleMarketStats
    // kollar 'saved == true', så vi gör en direkt kontroll mot books tabellen om den är tom.
    final count = await _db
        .customSelect('SELECT COUNT(1) AS c FROM books')
        .getSingle();
    final total = count.read<int>('c');

    if (total > 0) return;

    final now = DateTime.now();

    await _db.transaction(() async {
      for (final b in _seedBooks) {
        await _db.booksDao.upsert(
          id: b
              .isbn, // We use isbn as internal id for seeded books to prevent duplicates
          isbn: b.isbn,
          title: b.title,
          author: b.author,
          coverUrl: b.coverUrl,
          scannedAt: now,
          updatedAt: now,
        );
      }
    });
  }
}
