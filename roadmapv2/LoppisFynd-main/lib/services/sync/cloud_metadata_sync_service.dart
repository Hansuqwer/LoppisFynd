import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/database/app_database.dart';
import 'cloud/entity_keys.dart';
import 'cloud/conflict_detector.dart';

class CloudMetadataSyncService {
  CloudMetadataSyncService({required AppDatabase db, required AppConfig config})
    : _db = db,
      _config = config;

  final AppDatabase _db;
  final AppConfig _config;

  static const _kLastSyncMs = 'cloud_metadata_last_sync_ms';

  static const _kTypeHaul = 'haul';
  static const _kTypeScanItem = 'scan_item';

  Future<void> syncAll() async {
    await syncBidirectional();
  }

  Future<void> syncBidirectional() async {
    final now = DateTime.now();
    final lastMs = await _db.appSettingsDao.getInt(_kLastSyncMs) ?? 0;
    final lastSync = lastMs <= 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(lastMs);

    await pushLocalToCloud();
    await pullCloudToLocal(lastSync: lastSync);
    await _db.appSettingsDao.setInt(_kLastSyncMs, now.millisecondsSinceEpoch);
  }

  Future<void> pushLocalToCloud() async {
    if (!_config.hasSupabase) {
      throw const _CloudSyncNotConfigured();
    }

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      throw const _CloudSyncNotSignedIn();
    }

    final dirtyHauls = await _db.pendingCloudSyncEntitiesDao.listByType(
      _kTypeHaul,
    );
    final dirtyScanItems = await _db.pendingCloudSyncEntitiesDao.listByType(
      _kTypeScanItem,
    );

    final haulIds = dirtyHauls
        .map((d) => _idFromKey(prefix: 'haul:', key: d.entityKey))
        .whereType<String>()
        .toList(growable: false);
    final scanItemIds = dirtyScanItems
        .map((d) => _idFromKey(prefix: 'scan_item:', key: d.entityKey))
        .whereType<String>()
        .toList(growable: false);

    final hauls = await _db.haulsDao.listByIds(haulIds, userId: user.id);
    final scanItems = await _db.scanItemsDao.listByIds(
      scanItemIds,
      userId: user.id,
    );

    for (final h in hauls) {
      await _db.entitySyncStatusesDao.set(
        entityKey: haulEntityKey(h.id),
        status: 'syncing',
      );
    }
    for (final s in scanItems) {
      await _db.entitySyncStatusesDao.set(
        entityKey: scanItemEntityKey(s.id),
        status: 'syncing',
      );
    }

    final haulRows = hauls
        .map(
          (h) => {
            'id': h.id,
            'user_id': user.id,
            'title': h.title,
            'started_at': h.startedAt.toIso8601String(),
            'ended_at': h.endedAt?.toIso8601String(),
            'lat': h.lat,
            'lng': h.lng,
            'total_invested': h.totalInvested,
            'gross_value': h.grossValue,
            'net_profit': h.netProfit,
            'co2_saved_kg': h.co2SavedKg,
            'updated_at': h.updatedAt.toIso8601String(),
          },
        )
        .toList();

    final scanRows = scanItems
        .map(
          (s) => {
            'id': s.id,
            'user_id': user.id,
            'haul_id': s.haulId,
            'ai_json': s.aiJson,
            'query': s.query,
            'desc': s.desc,
            'confidence': s.confidence,
            'purchase_price': s.purchasePrice,
            'condition_multiplier': s.conditionMultiplier,
            'median_price': s.medianPrice,
            'min_price': s.minPrice,
            'max_price': s.maxPrice,
            'demand_score': s.demandScore,
            'days_to_sell_est': s.daysToSellEst,
            'status': s.status.name,
            'updated_at': s.updatedAt.toIso8601String(),
          },
        )
        .toList();

    final dirtyKeys = <String>{
      ...dirtyHauls.map((d) => d.entityKey),
      ...dirtyScanItems.map((d) => d.entityKey),
    };

    try {
      if (haulRows.isNotEmpty) {
        await client.from('hauls').upsert(haulRows, onConflict: 'id');
      }
      if (scanRows.isNotEmpty) {
        await client.from('scan_items').upsert(scanRows, onConflict: 'id');
      }

      await _db.pendingCloudSyncEntitiesDao.deleteByKeys(dirtyKeys);

      for (final h in hauls) {
        await _db.entitySyncStatusesDao.set(
          entityKey: haulEntityKey(h.id),
          status: 'synced',
          lastError: null,
        );
      }
      for (final s in scanItems) {
        await _db.entitySyncStatusesDao.set(
          entityKey: scanItemEntityKey(s.id),
          status: 'synced',
          lastError: null,
        );
      }
    } catch (e) {
      final err = e.toString();
      for (final h in hauls) {
        await _db.entitySyncStatusesDao.set(
          entityKey: haulEntityKey(h.id),
          status: 'failed',
          lastError: err,
        );
      }
      for (final s in scanItems) {
        await _db.entitySyncStatusesDao.set(
          entityKey: scanItemEntityKey(s.id),
          status: 'failed',
          lastError: err,
        );
      }
      rethrow;
    }
  }

  String? _idFromKey({required String prefix, required String key}) {
    if (!key.startsWith(prefix)) return null;
    final id = key.substring(prefix.length).trim();
    if (id.isEmpty) return null;
    return id;
  }

  Future<void> pullCloudToLocal({required DateTime? lastSync}) async {
    if (!_config.hasSupabase) {
      throw const _CloudSyncNotConfigured();
    }

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      throw const _CloudSyncNotSignedIn();
    }

    final haulsResp = await client
        .from('hauls')
        .select()
        .eq('user_id', user.id)
        .order('updated_at', ascending: false);

    final scanResp = await client
        .from('scan_items')
        .select()
        .eq('user_id', user.id)
        .order('updated_at', ascending: false);

    final hauls = _asList(haulsResp);
    for (final rowAny in hauls) {
      final row = _asMap(rowAny);
      final id = _readString(row['id']);
      final title = _readString(row['title']);
      final startedAt = _readDateTime(row['started_at']);
      final endedAt = _readNullableDateTime(row['ended_at']);
      final lat = _readNullableDouble(row['lat']);
      final lng = _readNullableDouble(row['lng']);
      final totalInvested = _readNullableDouble(row['total_invested']);
      final grossValue = _readNullableDouble(row['gross_value']);
      final netProfit = _readNullableDouble(row['net_profit']);
      final co2SavedKg = _readNullableDouble(row['co2_saved_kg']);
      final updatedAt = _readDateTime(row['updated_at']);

      final local = await _db.haulsDao.getById(id, userId: user.id);
      if (local != null && !updatedAt.isAfter(local.updatedAt)) {
        continue;
      }

      final conflict =
          local != null &&
          lastSync != null &&
          isLwwConflict(
            localUpdatedAt: local.updatedAt,
            cloudUpdatedAt: updatedAt,
            lastSyncAt: lastSync,
          );

      await _db.haulsDao.upsertFromCloud(
        id: id,
        userId: user.id,
        title: title,
        startedAt: startedAt,
        endedAt: endedAt,
        lat: lat,
        lng: lng,
        totalInvested: totalInvested,
        grossValue: grossValue,
        netProfit: netProfit,
        co2SavedKg: co2SavedKg,
        updatedAt: updatedAt,
      );

      await _db.entitySyncStatusesDao.set(
        entityKey: haulEntityKey(id),
        status: conflict ? 'conflict' : 'synced',
        lastError: conflict
            ? 'Cloud overwrote local changes (LWW). Review this haul.'
            : null,
      );
    }

    final scanItems = _asList(scanResp);
    for (final rowAny in scanItems) {
      final row = _asMap(rowAny);
      final id = _readString(row['id']);
      final haulId = _readString(row['haul_id']);
      final updatedAt = _readDateTime(row['updated_at']);

      final local = await _db.scanItemsDao.getById(id, userId: user.id);
      if (local != null && !updatedAt.isAfter(local.updatedAt)) {
        continue;
      }

      final conflict =
          local != null &&
          lastSync != null &&
          isLwwConflict(
            localUpdatedAt: local.updatedAt,
            cloudUpdatedAt: updatedAt,
            lastSyncAt: lastSync,
          );

      await _db.scanItemsDao.upsertFromCloud(
        id: id,
        userId: user.id,
        haulId: haulId,
        aiJson: _readNullableString(row['ai_json']),
        query: _readNullableString(row['query']),
        desc: _readNullableString(row['desc']),
        confidence: _readNullableDouble(row['confidence']),
        purchasePrice: _readNullableDouble(row['purchase_price']),
        conditionMultiplier: _readNullableDouble(row['condition_multiplier']),
        medianPrice: _readNullableDouble(row['median_price']),
        minPrice: _readNullableDouble(row['min_price']),
        maxPrice: _readNullableDouble(row['max_price']),
        demandScore: _readNullableInt(row['demand_score']),
        daysToSellEst: _readNullableInt(row['days_to_sell_est']),
        status: _readNullableString(row['status']),
        updatedAt: updatedAt,
      );

      await _db.entitySyncStatusesDao.set(
        entityKey: scanItemEntityKey(id),
        status: conflict ? 'conflict' : 'synced',
        lastError: conflict
            ? 'Cloud overwrote local changes (LWW). Review this item.'
            : null,
      );
    }
  }
}

List<Object?> _asList(Object? value) {
  if (value is List) return value.cast<Object?>();
  return const [];
}

Map<String, Object?> _asMap(Object? value) {
  if (value is Map) return value.cast<String, Object?>();
  return const {};
}

String _readString(Object? value) {
  if (value is String) return value;
  throw const FormatException('Expected string');
}

String? _readNullableString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  return null;
}

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

double? _readNullableDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return null;
}

DateTime _readDateTime(Object? value) {
  if (value is String) {
    final dt = DateTime.tryParse(value);
    if (dt != null) return dt;
  }
  throw const FormatException('Expected datetime string');
}

DateTime? _readNullableDateTime(Object? value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class _CloudSyncNotConfigured implements Exception {
  const _CloudSyncNotConfigured();
  @override
  String toString() => 'Cloud sync not configured';
}

class _CloudSyncNotSignedIn implements Exception {
  const _CloudSyncNotSignedIn();
  @override
  String toString() => 'Not signed in';
}
