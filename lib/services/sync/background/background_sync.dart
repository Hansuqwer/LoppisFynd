import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/config/app_config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/settings/app_settings_keys.dart';
import '../../market/market_bridge.dart';
import '../../market/tradera_client.dart';
import '../sync_scheduler.dart';

const _taskName = 'market_sync';

class BackgroundSync {
  static bool get isSupported {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => true,
      TargetPlatform.iOS => true,
      _ => false,
    };
  }

  static Future<void> initialize() async {
    if (!isSupported) return;
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> scheduleIfConfigured({required AppDatabase db}) async {
    if (!isSupported) return;

    final enabled =
        (await db.appSettingsDao.getInt(
          kPrivacyFetchSoldPriceCompsEnabledKeyV1,
        )) ??
        1;
    if (enabled != 1) {
      await Workmanager().cancelByUniqueName(_taskName);
      return;
    }

    final config = AppConfig.fromEnvironment();
    if (!config.hasTraderaProxy) {
      // Avoid leaving stale periodic work scheduled when the app is run without
      // a Tradera proxy configuration (common when switching flavors/dev envs).
      await Workmanager().cancelByUniqueName(_taskName);
      return;
    }

    final hours =
        (await db.appSettingsDao.getInt('market_sync_interval_hours')) ?? 6;

    if (hours <= 0) {
      await Workmanager().cancelByUniqueName(_taskName);
      return;
    }

    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: Duration(hours: hours),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    final config = AppConfig.fromEnvironment();
    if (!config.hasTraderaProxy) return true;

    final db = AppDatabase.open();
    try {
      final enabled =
          (await db.appSettingsDao.getInt(
            kPrivacyFetchSoldPriceCompsEnabledKeyV1,
          )) ??
          1;
      if (enabled != 1) return true;

      final market = MarketBridge(
        tradera: TraderaClient(functionUrl: Uri.parse(config.traderaProxyUrl)),
        db: db,
      );
      final scheduler = SyncScheduler(db: db, market: market);

      await scheduler.syncOnce();
      return true;
    } catch (_) {
      return true;
    } finally {
      await db.close();
    }
  });
}
