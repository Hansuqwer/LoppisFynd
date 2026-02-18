import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/features/auth/email_otp_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeEmailOtpAuthApi implements EmailOtpAuthApi {
  _FakeEmailOtpAuthApi({this.onSendOtp, this.onVerifyOtp});

  Future<void> Function(String email, bool shouldCreateUser)? onSendOtp;
  Future<void> Function(String email, String code)? onVerifyOtp;

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
    await onSendOtp?.call(email, shouldCreateUser);
  }

  @override
  Future<void> verifyOtp({required String email, required String code}) async {
    verifyCalls += 1;
    lastEmail = email;
    lastCode = code;
    await onVerifyOtp?.call(email, code);
  }
}

void main() {
  group('EmailOtpAuth', () {
    test('sendOtp success (trims email, delegates)', () async {
      final api = _FakeEmailOtpAuthApi();
      final svc = EmailOtpAuth(api: api);

      await svc.sendOtp('  user@example.com  ');

      expect(api.sendCalls, 1);
      expect(api.lastEmail, 'user@example.com');
    });

    test('verifyOtp success (trims inputs, delegates)', () async {
      final api = _FakeEmailOtpAuthApi();
      final svc = EmailOtpAuth(api: api);

      await svc.verifyOtp('  user@example.com  ', '  123456  ');

      expect(api.verifyCalls, 1);
      expect(api.lastEmail, 'user@example.com');
      expect(api.lastCode, '123456');
    });

    test('sendOtp empty email throws and does not call api', () async {
      final api = _FakeEmailOtpAuthApi();
      final svc = EmailOtpAuth(api: api);

      await expectLater(
        svc.sendOtp('   '),
        throwsA(
          isA<EmailOtpAuthException>().having(
            (e) => e.code,
            'code',
            'empty_email',
          ),
        ),
      );

      expect(api.sendCalls, 0);
    });

    test('verifyOtp empty code throws and does not call api', () async {
      final api = _FakeEmailOtpAuthApi();
      final svc = EmailOtpAuth(api: api);

      await expectLater(
        svc.verifyOtp('user@example.com', '  '),
        throwsA(
          isA<EmailOtpAuthException>().having(
            (e) => e.code,
            'code',
            'empty_code',
          ),
        ),
      );

      expect(api.verifyCalls, 0);
    });

    test('invalid code error path (AuthException-like) is surfaced', () async {
      final api = _FakeEmailOtpAuthApi(
        onVerifyOtp: (email, code) async {
          throw AuthException('Invalid token');
        },
      );
      final svc = EmailOtpAuth(api: api);

      await expectLater(
        svc.verifyOtp('user@example.com', '123456'),
        throwsA(isA<AuthException>()),
      );

      expect(api.verifyCalls, 1);
    });

    test('network error path (generic exception) is surfaced', () async {
      final api = _FakeEmailOtpAuthApi(
        onSendOtp: (email, _) async {
          throw Exception('Network down');
        },
      );
      final svc = EmailOtpAuth(api: api);

      await expectLater(
        svc.sendOtp('user@example.com'),
        throwsA(isA<Exception>()),
      );

      expect(api.sendCalls, 1);
    });
  });
}
