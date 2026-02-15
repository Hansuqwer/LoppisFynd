import 'package:drift/drift.dart';

import 'hauls.dart';

enum ScanItemStatus { pendingIdentify, pendingSync, syncing, complete, failed }

class ScanItemStatusConverter extends TypeConverter<ScanItemStatus, String> {
  const ScanItemStatusConverter();

  @override
  ScanItemStatus fromSql(String fromDb) {
    return ScanItemStatus.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => ScanItemStatus.pendingIdentify,
    );
  }

  @override
  String toSql(ScanItemStatus value) => value.name;
}

class ScanItems extends Table {
  TextColumn get id => text()();

  TextColumn get haulId =>
      text().references(Hauls, #id, onDelete: KeyAction.cascade)();

  TextColumn get imagePath => text().nullable()();
  TextColumn get thumbPath => text().nullable()();

  TextColumn get aiJson => text().nullable()();
  TextColumn get query => text().nullable()();
  TextColumn get desc => text().nullable()();

  RealColumn get confidence => real().nullable()();
  RealColumn get purchasePrice => real().nullable()();

  RealColumn get conditionMultiplier =>
      real().withDefault(const Constant(1.0))();

  RealColumn get medianPrice => real().nullable()();
  RealColumn get minPrice => real().nullable()();
  RealColumn get maxPrice => real().nullable()();
  IntColumn get demandScore => integer().nullable()();
  IntColumn get daysToSellEst => integer().nullable()();

  TextColumn get status => text()
      .map(const ScanItemStatusConverter())
      .withDefault(const Constant('pendingIdentify'))();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
