import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'gen/app_localizations.dart';

import 'package:path_provider/path_provider.dart';

import 'core/app/providers.dart';
import 'core/config/app_config.dart';
import 'core/database/app_database.dart';
import 'core/storage/scan_image_storage.dart';
import 'core/theme/app_theme.dart';
import 'services/ai/model_manager.dart';
import 'services/ai/inference/inference_isolate_service.dart';
import 'services/market/market_bridge.dart';
import 'services/market/market_data_source.dart';
import 'services/market/tradera_client.dart';
import 'services/sync/sync_scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/onboarding/onboarding_gate.dart';
import 'services/sync/background/background_sync.dart';
import 'services/notifications/app_notifications.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Offline-first: require fonts to be bundled in assets.
  GoogleFonts.config.allowRuntimeFetching = false;

  final docsDir = await getApplicationDocumentsDirectory();

  final db = AppDatabase.open();
  const defaultHaulId = 'default-haul';
  await db.haulsDao.upsert(id: defaultHaulId, title: 'Current haul');

  final config = AppConfig.fromEnvironment();

  if (config.hasSupabase) {
    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
    );
  }

  await BackgroundSync.initialize();
  await BackgroundSync.scheduleIfConfigured(db: db);

  if (config.hasTraderaProxy) {
    await AppNotifications.initialize(requestPermissions: true);
  }
  final market = config.hasTraderaProxy
      ? MarketBridge(
          tradera: TraderaClient(
            functionUrl: Uri.parse(config.traderaProxyUrl),
          ),
          db: db,
        )
      : const NoopMarketDataSource();

  final syncScheduler = SyncScheduler(db: db, market: market);

  final modelManager = ModelManager(
    spec: const ModelSpec(id: 'gemma_vision', fileName: 'gemma_vision.task'),
  );

  () async {
    try {
      final state = await modelManager.state();
      if (state.installed) return;
      if (!config.hasGemmaModelUrl) return;
      await modelManager.downloadFromUrl(url: Uri.parse(config.gemmaModelUrl));
    } catch (_) {
      // Best-effort; model download should not block app startup.
    }
  }();

  final modelFile = await modelManager.modelFile();
  final aiInference = AiInferenceIsolateService(
    backendKind: AiBackendKind.flutterGemma,
    modelPath: modelFile.path,
  );

  runApp(
    _AppRoot(
      db: db,
      imageStorage: ScanImageStorage(rootDir: docsDir),
      defaultHaulId: defaultHaulId,
      modelManager: modelManager,
      config: config,
      syncScheduler: syncScheduler,
      aiInference: aiInference,
    ),
  );
}

class _AppRoot extends StatefulWidget {
  const _AppRoot({
    required this.db,
    required this.imageStorage,
    required this.defaultHaulId,
    required this.modelManager,
    required this.config,
    required this.syncScheduler,
    required this.aiInference,
  });

  final AppDatabase db;
  final ScanImageStorage imageStorage;
  final String defaultHaulId;
  final ModelManager modelManager;
  final AppConfig config;
  final SyncScheduler syncScheduler;
  final AiInferenceIsolateService aiInference;

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  @override
  void dispose() {
    widget.db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(widget.db),
        scanImageStorageProvider.overrideWithValue(widget.imageStorage),
        defaultHaulIdProvider.overrideWithValue(widget.defaultHaulId),
        modelManagerProvider.overrideWithValue(widget.modelManager),
        appConfigProvider.overrideWithValue(widget.config),
        syncSchedulerProvider.overrideWithValue(widget.syncScheduler),
        aiInferenceProvider.overrideWithValue(widget.aiInference),
      ],
      child: const LoppisfyndApp(),
    );
  }
}

class LoppisfyndApp extends ConsumerWidget {
  const LoppisfyndApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highContrast = ref
        .watch(highContrastEnabledProvider)
        .maybeWhen(data: (v) => v, orElse: () => false);

    return MaterialApp(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'Loppisfynd',
      theme: highContrast ? AppTheme.highContrast() : AppTheme.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('sv'),
      home: const OnboardingGate(),
    );
  }
}
