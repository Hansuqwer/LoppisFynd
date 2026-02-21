// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_stats_cache_dao.dart';

// ignore_for_file: type=lint
mixin _$MarketStatsCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $MarketStatsCacheTable get marketStatsCache =>
      attachedDatabase.marketStatsCache;
  MarketStatsCacheDaoManager get managers => MarketStatsCacheDaoManager(this);
}

class MarketStatsCacheDaoManager {
  final _$MarketStatsCacheDaoMixin _db;
  MarketStatsCacheDaoManager(this._db);
  $$MarketStatsCacheTableTableManager get marketStatsCache =>
      $$MarketStatsCacheTableTableManager(
        _db.attachedDatabase,
        _db.marketStatsCache,
      );
}
