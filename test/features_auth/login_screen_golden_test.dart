import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fynd_loppis/core/app/providers.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/theme/app_theme.dart';
import 'package:fynd_loppis/features/auth/email_otp_auth.dart';
import 'package:fynd_loppis/features/auth/login_screen.dart';
import 'package:fynd_loppis/gen/app_localizations.dart';

class _FakeEmailOtpAuthApi implements EmailOtpAuthApi {
  @override
  Future<void> sendOtp({
    required String email,
    required bool shouldCreateUser,
  }) async {}

  @override
  Future<void> verifyOtp({required String email, required String code}) async {}
}

void main() {
  testWidgets('LoginScreen golden', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.appSettingsDao.setString('auth_last_email_v1', 'anna@gmail.com');

    final boundaryKey = GlobalKey();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('sv'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: RepaintBoundary(
            key: boundaryKey,
            child: SizedBox(
              width: 390,
              height: 844,
              child: LoginScreen(
                authOverride: EmailOtpAuth(api: _FakeEmailOtpAuthApi()),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await expectLater(
      find.byKey(boundaryKey),
      matchesGoldenFile('../goldens/login_screen.png'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
