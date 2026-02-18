import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fynd_loppis/core/app/providers.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/theme/app_theme.dart';
import 'package:fynd_loppis/features/auth/email_masking.dart';
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
    testWidgets('shows “Fortsätt som …” when last email exists (masked)', (
      tester,
    ) async {
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
      final masked = maskEmailForUi(lastEmail);

      expect(find.text(l10n.loginContinueAs(masked)), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets(
      'primary CTA on email step sends OTP and transitions to code step',
      (tester) async {
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
          _textFieldWithLabel(l10n.loginEmailLabel),
          'user@example.com',
        );

        await tester.tap(find.text(l10n.loginSendCode));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(api.sendCalls, 1);
        expect(api.lastEmail, 'user@example.com');
        expect(find.text('Kod'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );

    testWidgets('entering 6 digits and tapping primary CTA calls verifyOtp', (
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
        _textFieldWithLabel(l10n.loginEmailLabel),
        'user@example.com',
      );
      await tester.tap(find.text(l10n.loginSendCode));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(
        _textFieldWithLabel(l10n.loginCodeLabel),
        '123456',
      );
      await tester.tap(find.text(l10n.loginSignIn));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(api.verifyCalls, 1);
      expect(api.lastEmail, 'user@example.com');
      expect(api.lastCode, '123456');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });
}
