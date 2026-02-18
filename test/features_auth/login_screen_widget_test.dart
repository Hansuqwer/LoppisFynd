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
  int sendCalls = 0;
  int verifyCalls = 0;
  String? lastEmail;
  String? lastCode;
  bool? lastShouldCreateUser;

  @override
  Future<void> sendOtp({
    required String email,
    required bool shouldCreateUser,
  }) async {
    sendCalls += 1;
    lastEmail = email;
    lastShouldCreateUser = shouldCreateUser;
  }

  @override
  Future<void> verifyOtp({required String email, required String code}) async {
    verifyCalls += 1;
    lastEmail = email;
    lastCode = code;
  }
}

Widget _wrap({required AppDatabase db, required EmailOtpAuth auth}) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('sv'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: LoginScreen(authOverride: auth),
    ),
  );
}

Finder _textFieldWithLabel(String label) {
  return find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.labelText == label,
    description: 'TextField(labelText: $label)',
  );
}

void main() {
  group('LoginScreen', () {
    testWidgets('prefills email from last saved value', (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;

      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      const lastEmail = 'anna+tag@gmail.com';
      await db.appSettingsDao.setString('auth_last_email_v1', lastEmail);

      final api = _FakeEmailOtpAuthApi();
      final auth = EmailOtpAuth(api: api);

      await tester.pumpWidget(_wrap(db: db, auth: auth));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(LoginScreen));
      final l10n = AppLocalizations.of(context)!;

      final emailField = tester.widget<TextField>(
        _textFieldWithLabel(l10n.authEmailLabel),
      );
      expect(emailField.controller?.text, lastEmail);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('segmented control defaults to sign up', (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;

      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      final api = _FakeEmailOtpAuthApi();
      final auth = EmailOtpAuth(api: api);

      await tester.pumpWidget(_wrap(db: db, auth: auth));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(LoginScreen));
      final l10n = AppLocalizations.of(context)!;

      // "Skapa konto" appears both in the segmented control and as the primary CTA.
      expect(find.text(l10n.authModeSignUp), findsNWidgets(2));
      expect(find.text(l10n.authModeSignIn), findsOneWidget);
      expect(find.text(l10n.authCtaCreateAccount), findsNWidgets(2));

      await tester.tap(find.text(l10n.authModeSignIn));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      // "Logga in" appears both in the segmented control and as the primary CTA.
      expect(find.text(l10n.authCtaSignIn), findsNWidgets(2));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('trouble flow sends and verifies OTP (no user creation)', (
      tester,
    ) async {
      GoogleFonts.config.allowRuntimeFetching = false;

      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      final api = _FakeEmailOtpAuthApi();
      final auth = EmailOtpAuth(api: api);

      await tester.pumpWidget(_wrap(db: db, auth: auth));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(LoginScreen));
      final l10n = AppLocalizations.of(context)!;

      await tester.enterText(
        _textFieldWithLabel(l10n.authEmailLabel),
        'user@example.com',
      );

      await tester.tap(find.text(l10n.authTroubleLink));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.text(l10n.loginSendCode));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(api.sendCalls, 1);
      expect(api.lastEmail, 'user@example.com');
      expect(api.lastShouldCreateUser, false);

      await tester.enterText(_textFieldWithLabel(l10n.authCodeLabel), '123456');
      await tester.tap(find.text(l10n.authVerify));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(api.verifyCalls, 1);
      expect(api.lastEmail, 'user@example.com');
      expect(api.lastCode, '123456');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });
}
