import 'package:drift/drift.dart';

class BookMarketData extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()();
  TextColumn get isbn => text()();
  TextColumn get platform => text()();
  IntColumn get priceSek => integer()();
  DateTimeColumn get soldAt => dateTime()();
  TextColumn get listingUrl => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
