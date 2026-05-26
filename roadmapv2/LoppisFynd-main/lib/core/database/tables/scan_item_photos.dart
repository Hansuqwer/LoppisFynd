import 'package:drift/drift.dart';

import 'scan_items.dart';

class ScanItemPhotos extends Table {
  TextColumn get id => text()();

  TextColumn get scanItemId =>
      text().references(ScanItems, #id, onDelete: KeyAction.cascade)();

  TextColumn get localPath => text()();
  TextColumn get thumbPath => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
