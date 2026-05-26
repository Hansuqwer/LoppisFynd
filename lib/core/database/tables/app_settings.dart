import 'package:drift/drift.dart';

class AppSettings extends Table {
  TextColumn get key => text()();
  IntColumn get intValue => integer().nullable()();
  TextColumn get textValue => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
