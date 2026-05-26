// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hauls_dao.dart';

// ignore_for_file: type=lint
mixin _$HaulsDaoMixin on DatabaseAccessor<AppDatabase> {
  $HaulsTable get hauls => attachedDatabase.hauls;
  HaulsDaoManager get managers => HaulsDaoManager(this);
}

class HaulsDaoManager {
  final _$HaulsDaoMixin _db;
  HaulsDaoManager(this._db);
  $$HaulsTableTableManager get hauls =>
      $$HaulsTableTableManager(_db.attachedDatabase, _db.hauls);
}
