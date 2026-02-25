import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fynd_loppis/core/app/providers.dart';
import 'package:fynd_loppis/core/config/app_config.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/storage/scan_image_storage.dart';
import 'package:fynd_loppis/core/theme/app_theme.dart';
import 'package:fynd_loppis/features/scanner/scanner_screen.dart';
import 'package:fynd_loppis/gen/app_localizations.dart';
import 'package:fynd_loppis/services/ai/inference/inference_isolate_service.dart';
import 'package:fynd_loppis/services/market/market_data_source.dart';
import 'package:fynd_loppis/services/sync/sync_scheduler.dart';

void main() {
  testWidgets('Scanner screen light+dark goldens', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final root = Directory.systemTemp;

    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    await db.haulsDao.upsert(id: 'haul_current_guest', title: 'Current haul');

    const config = AppConfig(
      appEnv: 'test',
      traderaProxyUrl: '',
      cloudAiProxyUrl: '',
      supabaseUrl: '',
      supabaseAnonKey: '',
      sentryDsn: '',
    );

    final storage = ScanImageStorage(rootDir: root);
    final aiInference = AiInferenceIsolateService();
    final syncScheduler = SyncScheduler(
      db: db,
      market: const NoopMarketDataSource(),
    );

    final boundaryKey = GlobalKey();

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            scanImageStorageProvider.overrideWithValue(storage),
            appConfigProvider.overrideWithValue(config),
            syncSchedulerProvider.overrideWithValue(syncScheduler),
            aiInferenceProvider.overrideWithValue(aiInference),
            highContrastEnabledProvider.overrideWith(
              (ref) => Stream.value(false),
            ),
            themeModePreferenceProvider.overrideWith(
              (ref) => Stream.value(mode),
            ),
            onboardingCompleteProvider.overrideWith(
              (ref) => Stream.value(true),
            ),
            isOnlineProvider.overrideWith((ref) => Stream.value(true)),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: mode,
            locale: const Locale('sv'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: RepaintBoundary(
              key: boundaryKey,
              child: const SizedBox(
                width: 390,
                height: 844,
                child: ScannerScreen(active: false),
              ),
            ),
          ),
        ),
      );

      await _pumpFrames(tester);

      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile(
          mode == ThemeMode.dark
              ? '../goldens/scanner_screen_dark.png'
              : '../goldens/scanner_screen_light.png',
        ),
      );
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpFrames(tester);
  });
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 12; i += 1) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}
