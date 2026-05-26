// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_listings_dao.dart';

// ignore_for_file: type=lint
mixin _$DraftListingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $HaulsTable get hauls => attachedDatabase.hauls;
  $ScanItemsTable get scanItems => attachedDatabase.scanItems;
  $DraftListingsTable get draftListings => attachedDatabase.draftListings;
  DraftListingsDaoManager get managers => DraftListingsDaoManager(this);
}

class DraftListingsDaoManager {
  final _$DraftListingsDaoMixin _db;
  DraftListingsDaoManager(this._db);
  $$HaulsTableTableManager get hauls =>
      $$HaulsTableTableManager(_db.attachedDatabase, _db.hauls);
  $$ScanItemsTableTableManager get scanItems =>
      $$ScanItemsTableTableManager(_db.attachedDatabase, _db.scanItems);
  $$DraftListingsTableTableManager get draftListings =>
      $$DraftListingsTableTableManager(_db.attachedDatabase, _db.draftListings);
}
