import 'package:drift/drift.dart';

class Hauls extends Table {
  TextColumn get id => text()();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get endedAt => dateTime().nullable()();

  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();

  RealColumn get totalInvested => real().nullable()();
  RealColumn get grossValue => real().nullable()();
  RealColumn get netProfit => real().nullable()();
  RealColumn get co2SavedKg => real().nullable()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
