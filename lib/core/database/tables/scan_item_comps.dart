import 'package:drift/drift.dart';

import 'scan_items.dart';

class ScanItemComps extends Table {
  TextColumn get scanItemId =>
      text().references(ScanItems, #id, onDelete: KeyAction.cascade)();

  // Raw sold-listings snapshot (shape decided by the Tradera proxy).
  TextColumn get rawJson => text()();

  RealColumn get medianPrice => real().nullable()();
  RealColumn get minPrice => real().nullable()();
  RealColumn get maxPrice => real().nullable()();
  IntColumn get demandScore => integer().nullable()();
  IntColumn get daysToSellEst => integer().nullable()();

  DateTimeColumn get fetchedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {scanItemId};
}
