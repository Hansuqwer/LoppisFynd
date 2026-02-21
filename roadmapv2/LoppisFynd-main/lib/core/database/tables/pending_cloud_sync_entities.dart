import 'package:drift/drift.dart';

class PendingCloudSyncEntities extends Table {
  TextColumn get entityKey => text()();
  TextColumn get entityType => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {entityKey};
}
