import 'package:drift/drift.dart';

import 'scan_items.dart';

class DraftListings extends Table {
  // One draft per scan item for v1.0.
  TextColumn get scanItemId =>
      text().references(ScanItems, #id, onDelete: KeyAction.cascade)();

  TextColumn get platform => text().withDefault(const Constant('tradera'))();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  RealColumn get askingPriceSek => real().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {scanItemId};
}
