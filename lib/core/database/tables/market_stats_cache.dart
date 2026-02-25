import 'package:drift/drift.dart';

class MarketStatsCache extends Table {
  TextColumn get queryKey => text()();
  IntColumn get count => integer()();
  RealColumn get p25Sek => real().nullable()();
  RealColumn get minSek => real()();
  RealColumn get medianSek => real()();
  RealColumn get p75Sek => real().nullable()();
  RealColumn get maxSek => real()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {queryKey};
}
