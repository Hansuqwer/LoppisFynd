import 'dart:convert';

import 'package:http/http.dart' as http;

import 'tradera_proxy_models.dart';

class TraderaClient {
  TraderaClient({
    required Uri functionUrl,
    http.Client? httpClient,
    String? anonKey,
  }) : _functionUrl = functionUrl,
       _httpClient = httpClient ?? http.Client(),
       _anonKey = anonKey;

  final Uri _functionUrl;
  final http.Client _httpClient;
  final String? _anonKey;

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

    final resp = await _httpClient.post(
      _functionUrl,
      headers: headers,
      body: jsonEncode({
        'searchWords': searchWords,
        'itemStatus': 'Ended',
        'orderBy': 'EndDateDescending',
        'itemsPerPage': itemsPerPage,
        'pageNumber': pageNumber,
      }),
    );

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

class TraderaClientException implements Exception {
  const TraderaClientException(this.message);
  final String message;
  @override
  String toString() => 'TraderaClientException: $message';
}
