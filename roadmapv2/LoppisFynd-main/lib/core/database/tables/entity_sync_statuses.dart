import 'package:drift/drift.dart';

class EntitySyncStatuses extends Table {
  // Stable key, e.g. `haul:<id>` or `scan_item:<id>`.
  TextColumn get entityKey => text()();

  TextColumn get status => text()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {entityKey};
}
