// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_items_dao.dart';

// ignore_for_file: type=lint
mixin _$ScanItemsDaoMixin on DatabaseAccessor<AppDatabase> {
  $HaulsTable get hauls => attachedDatabase.hauls;
  $ScanItemsTable get scanItems => attachedDatabase.scanItems;
  ScanItemsDaoManager get managers => ScanItemsDaoManager(this);
}

class ScanItemsDaoManager {
  final _$ScanItemsDaoMixin _db;
  ScanItemsDaoManager(this._db);
  $$HaulsTableTableManager get hauls =>
      $$HaulsTableTableManager(_db.attachedDatabase, _db.hauls);
  $$ScanItemsTableTableManager get scanItems =>
      $$ScanItemsTableTableManager(_db.attachedDatabase, _db.scanItems);
}
