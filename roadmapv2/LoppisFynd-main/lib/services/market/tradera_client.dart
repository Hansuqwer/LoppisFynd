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

    http.Response? resp;
    Object? lastError;

    for (var attempt = 1; attempt <= _maxAttempts; attempt += 1) {
      try {
        resp = await _httpClient
            .post(_functionUrl, headers: headers, body: payload)
            .timeout(_timeout);

        // Retry on transient server/rate-limit errors.
        if (resp.statusCode == 429 || (resp.statusCode >= 500)) {
          throw _RetryableHttpStatus(resp.statusCode);
        }

        break;
      } on _RetryableHttpStatus catch (e) {
        lastError = e;
        if (attempt >= _maxAttempts) rethrow;
        await Future<void>.delayed(_retryDelay(attempt));
      } on TimeoutException catch (e) {
        lastError = e;
        if (attempt >= _maxAttempts) rethrow;
        await Future<void>.delayed(_retryDelay(attempt));
      } on SocketException catch (e) {
        lastError = e;
        if (attempt >= _maxAttempts) rethrow;
        await Future<void>.delayed(_retryDelay(attempt));
      } on http.ClientException catch (e) {
        lastError = e;
        if (attempt >= _maxAttempts) rethrow;
        await Future<void>.delayed(_retryDelay(attempt));
      }
    }

    if (resp == null) {
      throw lastError ?? StateError('TraderaClient: no response');
    }

    final bodyText = resp.body;
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw TraderaClientException(
        'Tradera proxy failed: ${resp.statusCode} ${bodyText.substring(0, bodyText.length > 300 ? 300 : bodyText.length)}',
      );
    }

    final decoded = jsonDecode(bodyText);
    if (decoded is! Map) {
      throw const FormatException('Expected JSON object');
    }
    return TraderaProxyResponse.fromJson(decoded.cast<String, Object?>());
  }
}

class _RetryableHttpStatus implements Exception {
  const _RetryableHttpStatus(this.statusCode);
  final int statusCode;
  @override
  String toString() => 'Retryable HTTP $statusCode';
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
