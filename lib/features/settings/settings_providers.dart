import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app/providers.dart';
import '../../services/privacy/cloud_data_deletion_service.dart';
import '../../services/privacy/data_export_service.dart';
import '../../services/privacy/local_data_deletion_service.dart';
import '../../services/sync/cloud_metadata_sync_service.dart';

// ---------------------------------------------------------------------------
// Settings screen providers
// ---------------------------------------------------------------------------

final syncNowProvider = AsyncNotifierProvider<SyncNowNotifier, void>(
  SyncNowNotifier.new,
);

class SyncNowNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> run() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final syncScheduler = ref.read(syncSchedulerProvider);
      await syncScheduler.syncOnce();
    });
  }
}

final cloudSyncNowProvider = AsyncNotifierProvider<CloudSyncNowNotifier, void>(
  CloudSyncNowNotifier.new,
);

class CloudSyncNowNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> run() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(appDatabaseProvider);
      final config = ref.read(appConfigProvider);
      final service = CloudMetadataSyncService(db: db, config: config);
      await service.syncBidirectional();
    });
  }
}

final signOutProvider = AsyncNotifierProvider<SignOutNotifier, void>(
  SignOutNotifier.new,
);

class SignOutNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> run() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Supabase.instance.client.auth.signOut();
    });
  }
}

// ---------------------------------------------------------------------------
// Privacy screen providers
// ---------------------------------------------------------------------------

final exportDataProvider = AsyncNotifierProvider<ExportDataNotifier, String>(
  ExportDataNotifier.new,
);

class ExportDataNotifier extends AsyncNotifier<String> {
  @override
  FutureOr<String> build() => '';

  Future<void> exportJson() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(appDatabaseProvider);
      final userId = ref.read(activeUserIdProvider);
      final file = await DataExportService().exportJson(db: db, userId: userId);
      return file.path;
    });
  }

  Future<void> exportCsv() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(appDatabaseProvider);
      final userId = ref.read(activeUserIdProvider);
      final file = await DataExportService().exportCsv(db: db, userId: userId);
      return file.path;
    });
  }
}

final deleteLocalDataProvider =
    AsyncNotifierProvider<DeleteLocalDataNotifier, void>(
  DeleteLocalDataNotifier.new,
);

class DeleteLocalDataNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> run() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(appDatabaseProvider);
      final userId = ref.read(activeUserIdProvider);
      final haulId = ref.read(defaultHaulIdProvider);
      await LocalDataDeletionService(db: db).deleteAllLocalData(
        userId: userId,
      );
      await db.haulsDao.ensureCurrentHaul(
        id: haulId,
        title: '',
        userId: userId,
      );
    });
  }
}

final deleteCloudDataProvider =
    AsyncNotifierProvider<DeleteCloudDataNotifier, CloudDeleteOutcome?>(
  DeleteCloudDataNotifier.new,
);

class DeleteCloudDataNotifier extends AsyncNotifier<CloudDeleteOutcome?> {
  @override
  FutureOr<CloudDeleteOutcome?> build() => null;

  Future<void> run() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final config = ref.read(appConfigProvider);
      return CloudDataDeletionService(config: config).deleteAllCloudData();
    });
  }
}

final clearScanCacheProvider =
    AsyncNotifierProvider<ClearScanCacheNotifier, int>(
  ClearScanCacheNotifier.new,
);

class ClearScanCacheNotifier extends AsyncNotifier<int> {
  @override
  FutureOr<int> build() => 0;

  Future<void> run() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(appDatabaseProvider);
      final userId = ref.read(activeUserIdProvider);
      final items = await db.scanItemsDao.listAll(userId: userId);
      return items.length;
    });
  }
}

final copyDiagnosticsProvider =
    AsyncNotifierProvider<CopyDiagnosticsNotifier, String>(
  CopyDiagnosticsNotifier.new,
);

class CopyDiagnosticsNotifier extends AsyncNotifier<String> {
  @override
  FutureOr<String> build() => '';

  Future<void> run() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final config = ref.read(appConfigProvider);
      final userId = ref.read(activeUserIdProvider);
      final info = await PackageInfo.fromPlatform();
      return [
        'app=${info.appName}',
        'package=${info.packageName}',
        'version=${info.version}+${info.buildNumber}',
        'env=${config.appEnv}',
        'hasSupabase=${config.hasSupabase}',
        'hasTraderaProxy=${config.hasTraderaProxy}',
        'userScope=${userId ?? 'guest'}',
      ].join('\n');
    });
  }
}

// ---------------------------------------------------------------------------
// Account deletion screen providers
// ---------------------------------------------------------------------------

final deleteAccountProvider =
    AsyncNotifierProvider<DeleteAccountNotifier, void>(
  DeleteAccountNotifier.new,
);

class DeleteAccountNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> run() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Supabase.instance.client.functions.invoke('account-delete');
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
      final db = ref.read(appDatabaseProvider);
      final userId = ref.read(activeUserIdProvider);
      if (userId != null) {
        await LocalDataDeletionService(db: db).deleteAllLocalData(
          userId: userId,
        );
      }
    });
  }
}
