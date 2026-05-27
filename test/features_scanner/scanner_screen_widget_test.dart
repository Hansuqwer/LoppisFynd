import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fynd_loppis/core/app/providers.dart';
import 'package:fynd_loppis/core/config/app_config.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/theme/app_theme.dart';
import 'package:fynd_loppis/features/scanner/scanner_screen.dart';
import 'package:fynd_loppis/gen/app_localizations.dart';

const _permissionChannel = MethodChannel('flutter.baseflow.com/permissions/methods');

const _testAppConfig = AppConfig(
  appEnv: 'test',
  traderaProxyUrl: '',
  cloudAiProxyUrl: '',
  supabaseUrl: '',
  supabaseAnonKey: '',
  sentryDsn: '',
);

Widget _wrap({
  required AppDatabase db,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      appConfigProvider.overrideWithValue(_testAppConfig),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const ScannerScreen(),
    ),
  );
}

/// Returns [PermissionStatus.denied] (0) for all permission checks.
void _mockPermissionDenied() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    _permissionChannel,
    (methodCall) async {
      switch (methodCall.method) {
        case 'checkPermissionStatus':
          return 0; // PermissionStatus.denied
        case 'requestPermissions':
          return <int, int>{1: 0}; // Permission.camera (1) -> denied (0)
        case 'shouldShowRequestRationale':
          return false;
        default:
          return null;
      }
    },
  );
}

/// Throws on any permission call to simulate a camera init failure.
void _mockPermissionError() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    _permissionChannel,
    (methodCall) async {
      throw PlatformException(code: 'camera_error', message: 'mock camera error');
    },
  );
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _permissionChannel,
      null,
    );
  });

  group('ScannerScreen', () {
    testWidgets('shows camera permission denied state (English)', (
      tester,
    ) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      await db.appSettingsDao.setInt('camera_permission_educated_v1', 1);
      _mockPermissionDenied();

      await tester.pumpWidget(_wrap(db: db));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(ScannerScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.errorCameraTitle), findsOneWidget);
      expect(find.text(l10n.scannerCameraPermissionDenied), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('shows camera permission denied state (Swedish)', (
      tester,
    ) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      await db.appSettingsDao.setInt('camera_permission_educated_v1', 1);
      _mockPermissionDenied();

      await tester.pumpWidget(_wrap(db: db, locale: const Locale('sv')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(ScannerScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.errorCameraTitle), findsOneWidget);
      expect(find.text(l10n.scannerCameraPermissionDenied), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('shows error state when camera init fails (English)', (
      tester,
    ) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      _mockPermissionError();

      await tester.pumpWidget(_wrap(db: db));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(ScannerScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.errorCameraTitle), findsOneWidget);
      expect(
        find.textContaining(l10n.scannerCameraInitFailed('')),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('shows error state when camera init fails (Swedish)', (
      tester,
    ) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      _mockPermissionError();

      await tester.pumpWidget(_wrap(db: db, locale: const Locale('sv')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(ScannerScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.errorCameraTitle), findsOneWidget);
      expect(
        find.textContaining(l10n.scannerCameraInitFailed('')),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('shows done scanning button (English)', (tester) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      _mockPermissionError();

      await tester.pumpWidget(_wrap(db: db));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(ScannerScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.scannerDoneScanning), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('shows done scanning button (Swedish)', (tester) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      _mockPermissionError();

      await tester.pumpWidget(_wrap(db: db, locale: const Locale('sv')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(ScannerScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.scannerDoneScanning), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('shows scanner title and subtitle (English)', (tester) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      _mockPermissionError();

      await tester.pumpWidget(_wrap(db: db));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(ScannerScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.scannerTitle), findsOneWidget);
      expect(find.text(l10n.scannerSubtitle), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('shows scanner title and subtitle (Swedish)', (tester) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      _mockPermissionError();

      await tester.pumpWidget(_wrap(db: db, locale: const Locale('sv')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(ScannerScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.scannerTitle), findsOneWidget);
      expect(find.text(l10n.scannerSubtitle), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });
}
