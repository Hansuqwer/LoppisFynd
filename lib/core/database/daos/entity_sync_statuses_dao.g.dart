// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_sync_statuses_dao.dart';

// ignore_for_file: type=lint
mixin _$EntitySyncStatusesDaoMixin on DatabaseAccessor<AppDatabase> {
  $EntitySyncStatusesTable get entitySyncStatuses =>
      attachedDatabase.entitySyncStatuses;
  EntitySyncStatusesDaoManager get managers =>
      EntitySyncStatusesDaoManager(this);
}

class EntitySyncStatusesDaoManager {
  final _$EntitySyncStatusesDaoMixin _db;
  EntitySyncStatusesDaoManager(this._db);
  $$EntitySyncStatusesTableTableManager get entitySyncStatuses =>
      $$EntitySyncStatusesTableTableManager(
        _db.attachedDatabase,
        _db.entitySyncStatuses,
      );
}
