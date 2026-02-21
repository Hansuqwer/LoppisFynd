import 'package:drift/drift.dart';

class SyncQuotas extends Table {
  TextColumn get dayKey => text()();
  IntColumn get used => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {dayKey};
}
