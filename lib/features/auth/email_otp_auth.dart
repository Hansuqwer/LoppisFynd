import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class EmailOtpAuthApi {
  Future<void> sendOtp({required String email, required bool shouldCreateUser});

  Future<void> verifyOtp({required String email, required String code});
}

class SupabaseEmailOtpAuthApi implements EmailOtpAuthApi {
  SupabaseEmailOtpAuthApi(this._client);

  final SupabaseClient _client;

  @override
  Future<void> sendOtp({
    required String email,
    required bool shouldCreateUser,
  }) async {
    await _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: shouldCreateUser,
    );
  }

  @override
  Future<void> verifyOtp({required String email, required String code}) async {
    await _client.auth.verifyOTP(
      type: OtpType.email,
      email: email,
      token: code,
    );
  }
}

class EmailOtpAuthException implements Exception {
  const EmailOtpAuthException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'EmailOtpAuthException($code): $message';
}

/// Small, testable email OTP auth service.
class EmailOtpAuth {
  EmailOtpAuth({required EmailOtpAuthApi api}) : _api = api;

  factory EmailOtpAuth.supabase(SupabaseClient client) {
    return EmailOtpAuth(api: SupabaseEmailOtpAuthApi(client));
  }

  final EmailOtpAuthApi _api;

  Future<void> sendOtp(String email, {bool shouldCreateUser = false}) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      throw const EmailOtpAuthException('empty_email', '');
    }

    await _api.sendOtp(email: trimmedEmail, shouldCreateUser: shouldCreateUser);
  }

  Future<void> verifyOtp(String email, String code) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      throw const EmailOtpAuthException('empty_email', '');
    }

    final trimmedCode = code.trim();
    if (trimmedCode.isEmpty) {
      throw const EmailOtpAuthException('empty_code', '');
    }

    await _api.verifyOtp(email: trimmedEmail, code: trimmedCode);
  }
}
