import 'package:drift/drift.dart';

class Books extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get isbn => text()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get publisher => text().nullable()();
  IntColumn get publishYear => integer().nullable()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get categories => text().nullable()();
  IntColumn get purchasePriceSek => integer().nullable()();
  BoolColumn get saved => boolean().withDefault(const Constant(false))();
  IntColumn get highestSoldPriceSek => integer().nullable()();
  IntColumn get averageSoldPriceSek => integer().nullable()();
  IntColumn get lowestSoldPriceSek => integer().nullable()();
  RealColumn get salesPerMonth => real().nullable()();
  IntColumn get totalSales => integer().nullable()();
  DateTimeColumn get scannedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
