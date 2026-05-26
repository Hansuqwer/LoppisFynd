// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_item_sync_states_dao.dart';

// ignore_for_file: type=lint
mixin _$ScanItemSyncStatesDaoMixin on DatabaseAccessor<AppDatabase> {
  $HaulsTable get hauls => attachedDatabase.hauls;
  $ScanItemsTable get scanItems => attachedDatabase.scanItems;
  $ScanItemSyncStatesTable get scanItemSyncStates =>
      attachedDatabase.scanItemSyncStates;
  ScanItemSyncStatesDaoManager get managers =>
      ScanItemSyncStatesDaoManager(this);
}

class ScanItemSyncStatesDaoManager {
  final _$ScanItemSyncStatesDaoMixin _db;
  ScanItemSyncStatesDaoManager(this._db);
  $$HaulsTableTableManager get hauls =>
      $$HaulsTableTableManager(_db.attachedDatabase, _db.hauls);
  $$ScanItemsTableTableManager get scanItems =>
      $$ScanItemsTableTableManager(_db.attachedDatabase, _db.scanItems);
  $$ScanItemSyncStatesTableTableManager get scanItemSyncStates =>
      $$ScanItemSyncStatesTableTableManager(
        _db.attachedDatabase,
        _db.scanItemSyncStates,
      );
}
