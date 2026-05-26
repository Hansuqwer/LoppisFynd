// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_quotas_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncQuotasDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncQuotasTable get syncQuotas => attachedDatabase.syncQuotas;
  SyncQuotasDaoManager get managers => SyncQuotasDaoManager(this);
}

class SyncQuotasDaoManager {
  final _$SyncQuotasDaoMixin _db;
  SyncQuotasDaoManager(this._db);
  $$SyncQuotasTableTableManager get syncQuotas =>
      $$SyncQuotasTableTableManager(_db.attachedDatabase, _db.syncQuotas);
}
