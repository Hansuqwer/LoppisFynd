import 'package:drift/drift.dart';

import 'scan_items.dart';

class ScanItemSyncStates extends Table {
  TextColumn get scanItemId =>
      text().references(ScanItems, #id, onDelete: KeyAction.cascade)();

  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {scanItemId};
}
