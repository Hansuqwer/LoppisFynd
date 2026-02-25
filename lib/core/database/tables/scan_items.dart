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

  // Optional. When Supabase auth is enabled, local data is scoped to a user id.
  TextColumn get userId => text().nullable()();

  TextColumn get haulId =>
      text().references(Hauls, #id, onDelete: KeyAction.cascade)();

  TextColumn get imagePath => text().nullable()();
  TextColumn get thumbPath => text().nullable()();

  TextColumn get aiJson => text().nullable()();
  TextColumn get offlineDetectionsJson => text().nullable()();
  DateTimeColumn get offlineDetectionsFetchedAt => dateTime().nullable()();
  TextColumn get query => text().nullable()();
  TextColumn get desc => text().nullable()();

  // Optional. User-defined inventory category (free text).
  TextColumn get category => text().nullable()();

  TextColumn get notes => text().nullable()();

  RealColumn get confidence => real().nullable()();
  RealColumn get purchasePrice => real().nullable()();
  RealColumn get fixedFeesSek => real().nullable()();
  RealColumn get shippingPaidBySellerSek => real().nullable()();

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
