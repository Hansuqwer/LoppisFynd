// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_item_comps_dao.dart';

// ignore_for_file: type=lint
mixin _$ScanItemCompsDaoMixin on DatabaseAccessor<AppDatabase> {
  $HaulsTable get hauls => attachedDatabase.hauls;
  $ScanItemsTable get scanItems => attachedDatabase.scanItems;
  $ScanItemCompsTable get scanItemComps => attachedDatabase.scanItemComps;
  ScanItemCompsDaoManager get managers => ScanItemCompsDaoManager(this);
}

class ScanItemCompsDaoManager {
  final _$ScanItemCompsDaoMixin _db;
  ScanItemCompsDaoManager(this._db);
  $$HaulsTableTableManager get hauls =>
      $$HaulsTableTableManager(_db.attachedDatabase, _db.hauls);
  $$ScanItemsTableTableManager get scanItems =>
      $$ScanItemsTableTableManager(_db.attachedDatabase, _db.scanItems);
  $$ScanItemCompsTableTableManager get scanItemComps =>
      $$ScanItemCompsTableTableManager(_db.attachedDatabase, _db.scanItemComps);
}
