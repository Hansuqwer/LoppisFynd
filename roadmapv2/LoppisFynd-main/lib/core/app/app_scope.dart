import 'package:flutter/widgets.dart';

import '../database/app_database.dart';
import '../storage/scan_image_storage.dart';
import '../../services/ai/model_manager.dart';
import '../../services/ai/inference/inference_isolate_service.dart';
import '../config/app_config.dart';
import '../../services/sync/sync_scheduler.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.db,
    required this.imageStorage,
    required this.defaultHaulId,
    required this.modelManager,
    required this.modelAutoInstall,
    required this.aiInference,
    required this.config,
    required this.syncScheduler,
    required super.child,
  });

  final AppDatabase db;
  final ScanImageStorage imageStorage;
  final String defaultHaulId;
  final ModelManager modelManager;
  final Future<void>? modelAutoInstall;
  final AiInferenceIsolateService aiInference;
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
        imageStorage != oldWidget.imageStorage ||
        defaultHaulId != oldWidget.defaultHaulId ||
        modelManager != oldWidget.modelManager ||
        modelAutoInstall != oldWidget.modelAutoInstall ||
        aiInference != oldWidget.aiInference ||
        config != oldWidget.config ||
        syncScheduler != oldWidget.syncScheduler;
  }
}
