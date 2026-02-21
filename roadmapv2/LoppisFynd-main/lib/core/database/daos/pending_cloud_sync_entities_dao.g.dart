// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_cloud_sync_entities_dao.dart';

// ignore_for_file: type=lint
mixin _$PendingCloudSyncEntitiesDaoMixin on DatabaseAccessor<AppDatabase> {
  $PendingCloudSyncEntitiesTable get pendingCloudSyncEntities =>
      attachedDatabase.pendingCloudSyncEntities;
  PendingCloudSyncEntitiesDaoManager get managers =>
      PendingCloudSyncEntitiesDaoManager(this);
}

class PendingCloudSyncEntitiesDaoManager {
  final _$PendingCloudSyncEntitiesDaoMixin _db;
  PendingCloudSyncEntitiesDaoManager(this._db);
  $$PendingCloudSyncEntitiesTableTableManager get pendingCloudSyncEntities =>
      $$PendingCloudSyncEntitiesTableTableManager(
        _db.attachedDatabase,
        _db.pendingCloudSyncEntities,
      );
}
