// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_item_photos_dao.dart';

// ignore_for_file: type=lint
mixin _$ScanItemPhotosDaoMixin on DatabaseAccessor<AppDatabase> {
  $HaulsTable get hauls => attachedDatabase.hauls;
  $ScanItemsTable get scanItems => attachedDatabase.scanItems;
  $ScanItemPhotosTable get scanItemPhotos => attachedDatabase.scanItemPhotos;
  ScanItemPhotosDaoManager get managers => ScanItemPhotosDaoManager(this);
}

class ScanItemPhotosDaoManager {
  final _$ScanItemPhotosDaoMixin _db;
  ScanItemPhotosDaoManager(this._db);
  $$HaulsTableTableManager get hauls =>
      $$HaulsTableTableManager(_db.attachedDatabase, _db.hauls);
  $$ScanItemsTableTableManager get scanItems =>
      $$ScanItemsTableTableManager(_db.attachedDatabase, _db.scanItems);
  $$ScanItemPhotosTableTableManager get scanItemPhotos =>
      $$ScanItemPhotosTableTableManager(
        _db.attachedDatabase,
        _db.scanItemPhotos,
      );
}
