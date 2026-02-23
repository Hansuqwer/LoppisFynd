import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'tradera_proxy_models.dart';

class TraderaClient {
  TraderaClient({
    required Uri functionUrl,
    http.Client? httpClient,
    String? anonKey,
    Duration timeout = const Duration(seconds: 12),
    int maxAttempts = 3,
  }) : _functionUrl = functionUrl,
       _httpClient = httpClient ?? http.Client(),
       _anonKey = anonKey,
       _timeout = timeout,
       _maxAttempts = maxAttempts;

  final Uri _functionUrl;
  final http.Client _httpClient;
  final String? _anonKey;
  final Duration _timeout;
  final int _maxAttempts;

  Future<TraderaProxyResponse> searchEnded({
    required String searchWords,
    int itemsPerPage = 50,
    int pageNumber = 1,
  }) async {
    final headers = <String, String>{'content-type': 'application/json'};
    final anonKey = _anonKey;
    if (anonKey != null) {
      headers['apikey'] = anonKey;
      headers['authorization'] = 'Bearer $anonKey';
    }

    final payload = jsonEncode({
      'searchWords': searchWords,
      'itemStatus': 'Ended',
      'orderBy': 'EndDateDescending',
      'itemsPerPage': itemsPerPage,
      'pageNumber': pageNumber,
    });

    http.Response? lastResponse;
    Object? lastError;

    for (var attempt = 1; attempt <= _maxAttempts; attempt += 1) {
      http.Response resp;
      try {
        resp = await _httpClient
            .post(_functionUrl, headers: headers, body: payload)
            .timeout(_timeout);
      } on TimeoutException catch (e) {
        lastError = e;
        if (attempt >= _maxAttempts) break;
        await Future<void>.delayed(_retryDelay(attempt));
        continue;
      } on SocketException catch (e) {
        lastError = e;
        if (attempt >= _maxAttempts) break;
        await Future<void>.delayed(_retryDelay(attempt));
        continue;
      } on http.ClientException catch (e) {
        lastError = e;
        if (attempt >= _maxAttempts) break;
        await Future<void>.delayed(_retryDelay(attempt));
        continue;
      }

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body);
        if (decoded is! Map) {
          throw const FormatException('Expected JSON object');
        }
        return TraderaProxyResponse.fromJson(decoded.cast<String, Object?>());
      }

      // Rate limiting is actionable (avoid tight retry loops).
      if (resp.statusCode == 429) {
        throw _proxyErrorToException(resp);
      }

      // Retry transient server errors.
      if (resp.statusCode >= 500) {
        lastResponse = resp;
        lastError = _RetryableHttpStatus(resp.statusCode);
        if (attempt >= _maxAttempts) break;
        await Future<void>.delayed(_retryDelay(attempt));
        continue;
      }

      // Non-retryable HTTP errors.
      throw _proxyErrorToException(resp);
    }

    if (lastResponse != null) {
      throw _proxyErrorToException(lastResponse);
    }

    if (lastError is TimeoutException) {
      throw const TraderaClientException(
        'Tradera proxy timed out. Check your connection and try again.',
      );
    }
    if (lastError is SocketException) {
      throw const TraderaClientException(
        'No network connection. Try again when you are online.',
      );
    }

    throw TraderaClientException(
      'Tradera proxy request failed: ${lastError ?? 'unknown error'}',
    );
  }

  TraderaClientException _proxyErrorToException(http.Response resp) {
    final bodyText = resp.body;

    final retryAfterSecondsFromHeader = _parseRetryAfterSeconds(
      resp.headers['retry-after'],
    );

    final proxyError = _tryParseProxyError(bodyText);
    if (proxyError != null) {
      final retryAfterSeconds =
          proxyError.retryAfterSeconds ?? retryAfterSecondsFromHeader;
      final message = retryAfterSeconds != null
          ? '${proxyError.message} (try again in ${retryAfterSeconds}s)'
          : proxyError.message;
      return TraderaClientException(message);
    }

    if (resp.statusCode == 429) {
      final retryAfterSeconds = retryAfterSecondsFromHeader;
      final message = retryAfterSeconds != null
          ? 'Rate limited. Try again in ${retryAfterSeconds}s.'
          : 'Rate limited. Try again soon.';
      return TraderaClientException(message);
    }

    final snippet = bodyText.substring(
      0,
      bodyText.length > 300 ? 300 : bodyText.length,
    );
    return TraderaClientException(
      'Tradera proxy failed: ${resp.statusCode} $snippet',
    );
  }
}

class _RetryableHttpStatus implements Exception {
  const _RetryableHttpStatus(this.statusCode);
  final int statusCode;
  @override
  String toString() => 'Retryable HTTP $statusCode';
}

class _ProxyError {
  const _ProxyError({
    required this.code,
    required this.message,
    this.retryAfterSeconds,
  });

  final String code;
  final String message;
  final int? retryAfterSeconds;
}

_ProxyError? _tryParseProxyError(String bodyText) {
  Object? decoded;
  try {
    decoded = jsonDecode(bodyText);
  } catch (_) {
    return null;
  }
  if (decoded is! Map) return null;

  final errorObj = decoded['error'];
  if (errorObj is! Map) return null;

  final code = errorObj['code'];
  final message = errorObj['message'];
  if (code is! String || message is! String) return null;

  final ras = errorObj['retryAfterSeconds'];
  int? retryAfterSeconds;
  if (ras is int) retryAfterSeconds = ras;
  if (ras is num) retryAfterSeconds = ras.toInt();

  return _ProxyError(
    code: code,
    message: message,
    retryAfterSeconds: retryAfterSeconds != null && retryAfterSeconds > 0
        ? retryAfterSeconds
        : null,
  );
}

int? _parseRetryAfterSeconds(String? headerValue) {
  if (headerValue == null) return null;
  final trimmed = headerValue.trim();
  if (trimmed.isEmpty) return null;
  final v = int.tryParse(trimmed);
  if (v == null) return null;
  return v > 0 ? v : null;
}

Duration _retryDelay(int attempt) {
  final capped = attempt > 5 ? 5 : attempt;
  final ms = 250 * (1 << (capped - 1));
  return Duration(milliseconds: ms);
}

class TraderaClientException implements Exception {
  const TraderaClientException(this.message);
  final String message;
  @override
  String toString() => 'TraderaClientException: $message';
}
