// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_button_config_dao.dart';

// ignore_for_file: type=lint
mixin _$PriceButtonConfigDaoMixin on DatabaseAccessor<AppDatabase> {
  $PriceButtonConfigTable get priceButtonConfig =>
      attachedDatabase.priceButtonConfig;
  PriceButtonConfigDaoManager get managers => PriceButtonConfigDaoManager(this);
}

class PriceButtonConfigDaoManager {
  final _$PriceButtonConfigDaoMixin _db;
  PriceButtonConfigDaoManager(this._db);
  $$PriceButtonConfigTableTableManager get priceButtonConfig =>
      $$PriceButtonConfigTableTableManager(
        _db.attachedDatabase,
        _db.priceButtonConfig,
      );
}
