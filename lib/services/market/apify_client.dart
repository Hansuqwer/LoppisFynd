import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApifyRunResult {
  const ApifyRunResult({
    required this.id,
    required this.status,
    required this.datasetId,
  });

  final String id;
  final String status;
  final String datasetId;

  bool get isSucceeded => status == 'SUCCEEDED';
  bool get isFailed =>
      status == 'FAILED' || status == 'ABORTED' || status == 'TIMED-OUT';
  bool get isTerminal => isSucceeded || isFailed;

  factory ApifyRunResult.fromJson(Map<String, Object?> json) {
    final data = json['data'];
    if (data is! Map) {
      throw const ApifyClientException(
        'Expected "data" object in run response',
      );
    }
    final id = data['id'];
    final status = data['status'];
    final datasetId = data['defaultDatasetId'];
    if (id is! String || status is! String || datasetId is! String) {
      throw const ApifyClientException(
        'Missing required fields in run response',
      );
    }
    return ApifyRunResult(id: id, status: status, datasetId: datasetId);
  }
}

class ApifyClient {
  ApifyClient({
    required String apiToken,
    http.Client? httpClient,
    Uri? baseUrl,
    Duration timeout = const Duration(seconds: 30),
    Duration pollInterval = const Duration(seconds: 2),
    int maxPollAttempts = 30,
  }) : _apiToken = apiToken,
       _httpClient = httpClient ?? http.Client(),
       _baseUrl = baseUrl ?? Uri.parse('https://api.apify.com/v2'),
       _timeout = timeout,
       _pollInterval = pollInterval,
       _maxPollAttempts = maxPollAttempts;

  final String _apiToken;
  final http.Client _httpClient;
  final Uri _baseUrl;
  final Duration _timeout;
  final Duration _pollInterval;
  final int _maxPollAttempts;

  Future<ApifyRunResult> startRun({
    required String actorId,
    required Map<String, Object?> input,
    int? memoryMbytes,
    Duration? timeout,
  }) async {
    final queryParameters = <String, String>{};
    if (memoryMbytes != null) {
      queryParameters['memory'] = memoryMbytes.toString();
    }
    if (timeout != null) {
      queryParameters['timeout'] = timeout.inSeconds.toString();
    }

    final uri = _baseUrl.replace(
      path: '/v2/acts/$actorId/runs',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final response = await _postJson(uri, input);
    return ApifyRunResult.fromJson(response);
  }

  Future<ApifyRunResult> getRun(String runId) async {
    final uri = _baseUrl.replace(path: '/v2/actor-runs/$runId');
    final response = await _getJson(uri);
    return ApifyRunResult.fromJson(response);
  }

  Future<List<Map<String, Object?>>> getDatasetItems(String datasetId) async {
    final uri = _baseUrl.replace(
      path: '/v2/datasets/$datasetId/items',
      queryParameters: {'format': 'json'},
    );

    final response = await _httpClient
        .get(uri, headers: _authHeaders())
        .timeout(_timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApifyClientException(
        'Failed to fetch dataset items: HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const ApifyClientException('Expected array of dataset items');
    }

    return decoded
        .whereType<Map>()
        .map((item) {
          return item.cast<String, Object?>();
        })
        .toList(growable: false);
  }

  Future<List<Map<String, Object?>>> runActorAndWait({
    required String actorId,
    required Map<String, Object?> input,
    int? memoryMbytes,
    Duration? runTimeout,
  }) async {
    final run = await startRun(
      actorId: actorId,
      input: input,
      memoryMbytes: memoryMbytes,
      timeout: runTimeout,
    );

    final completedRun = await _pollUntilTerminal(run.id);

    if (completedRun.isFailed) {
      throw ApifyClientException(
        'Actor run ${run.id} failed with status: ${completedRun.status}',
      );
    }

    return getDatasetItems(completedRun.datasetId);
  }

  Future<ApifyRunResult> _pollUntilTerminal(String runId) async {
    for (var attempt = 0; attempt < _maxPollAttempts; attempt++) {
      await Future<void>.delayed(_pollInterval);
      final run = await getRun(runId);
      if (run.isTerminal) return run;
    }
    throw ApifyClientException(
      'Actor run $runId did not complete within ${_maxPollAttempts * _pollInterval.inSeconds}s',
    );
  }

  Map<String, String> _authHeaders() {
    return {
      'Authorization': 'Bearer $_apiToken',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, Object?>> _postJson(
    Uri uri,
    Map<String, Object?> body,
  ) async {
    final response = await _httpClient
        .post(uri, headers: _authHeaders(), body: jsonEncode(body))
        .timeout(_timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApifyClientException(
        'Apify API error: HTTP ${response.statusCode} — ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const ApifyClientException('Expected JSON object from Apify API');
    }
    return decoded.cast<String, Object?>();
  }

  Future<Map<String, Object?>> _getJson(Uri uri) async {
    final response = await _httpClient
        .get(uri, headers: _authHeaders())
        .timeout(_timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApifyClientException(
        'Apify API error: HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const ApifyClientException('Expected JSON object from Apify API');
    }
    return decoded.cast<String, Object?>();
  }
}

class ApifyClientException implements Exception {
  const ApifyClientException(this.message);
  final String message;
  @override
  String toString() => 'ApifyClientException: $message';
}
