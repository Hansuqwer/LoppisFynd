import 'package:flutter/widgets.dart';

import '../database/app_database.dart';
import '../config/app_config.dart';
import '../../services/sync/sync_scheduler.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.db,
    required this.config,
    required this.syncScheduler,
    required super.child,
  });

  final AppDatabase db;
  final AppConfig config;
  final SyncScheduler syncScheduler;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null) {
      throw StateError('AppScope not found in widget tree');
    }
    return scope;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return db != oldWidget.db ||
        config != oldWidget.config ||
        syncScheduler != oldWidget.syncScheduler;
  }
}
