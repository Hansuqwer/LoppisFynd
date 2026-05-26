// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_market_data_dao.dart';

// ignore_for_file: type=lint
mixin _$BookMarketDataDaoMixin on DatabaseAccessor<AppDatabase> {
  $BookMarketDataTable get bookMarketData => attachedDatabase.bookMarketData;
  BookMarketDataDaoManager get managers => BookMarketDataDaoManager(this);
}

class BookMarketDataDaoManager {
  final _$BookMarketDataDaoMixin _db;
  BookMarketDataDaoManager(this._db);
  $$BookMarketDataTableTableManager get bookMarketData =>
      $$BookMarketDataTableTableManager(
        _db.attachedDatabase,
        _db.bookMarketData,
      );
}
