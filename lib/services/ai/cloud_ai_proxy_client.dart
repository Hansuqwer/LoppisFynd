import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudAiProxyException implements Exception {
  const CloudAiProxyException(this.message);

  final String message;

  @override
  String toString() => 'CloudAiProxyException: $message';
}

class CloudAiProxyClient {
  CloudAiProxyClient({required this.functionUrl, http.Client? client})
    : _client = client;

  final Uri functionUrl;
  final http.Client? _client;

  Future<String> generate({
    required String prompt,
    required Uint8List imageJpegBytes,
    int? maxTokens,
    String? requestId,
    Future<void>? cancel,
  }) async {
    final client = _client ?? http.Client();

    var cancelled = false;
    cancel?.then((_) {
      cancelled = true;
      client.close();
    });

    try {
      final body = <String, Object?>{
        'prompt': prompt,
        'maxTokens': maxTokens,
        'imageBase64Jpeg': base64Encode(imageJpegBytes),
        ...?(requestId == null
            ? null
            : <String, Object?>{'requestId': requestId}),
      };

      final resp = await client.post(
        functionUrl,
        headers: const {
          'content-type': 'application/json',
          'cache-control': 'no-store',
        },
        body: jsonEncode(body),
      );

      if (cancelled) {
        throw const CloudAiProxyException('Cancelled');
      }

      final decoded = _tryDecodeJson(resp.body);
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        final error = (decoded is Map && decoded['error'] is String)
            ? decoded['error'] as String
            : 'HTTP ${resp.statusCode}';
        throw CloudAiProxyException(error);
      }

      if (decoded is Map && decoded['text'] is String) {
        final text = (decoded['text'] as String).trim();
        if (text.isEmpty) throw const CloudAiProxyException('Empty response');
        return text;
      }

      throw const CloudAiProxyException('Unexpected proxy response');
    } catch (e) {
      if (cancelled) {
        throw const CloudAiProxyException('Cancelled');
      }
      rethrow;
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}

Object? _tryDecodeJson(String text) {
  try {
    return jsonDecode(text);
  } catch (_) {
    return null;
  }
}
