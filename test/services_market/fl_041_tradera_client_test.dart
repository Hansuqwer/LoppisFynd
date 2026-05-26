import 'package:flutter_test/flutter_test.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:fynd_loppis/services/market/tradera_client.dart';

void main() {
  test('TraderaClient parses proxy response', () async {
    final client = TraderaClient(
      functionUrl: Uri.parse('https://example.com/functions/v1/tradera-proxy'),
      httpClient: MockClient((req) async {
        return http.Response(
          '{"totalNumberOfItems":1,"totalNumberOfPages":1,"items":[{"id":1,"shortDescription":"x","endDate":"2026-02-01T12:00:00","maxBid":123,"totalBids":4,"hasBids":true,"isEnded":true,"itemLink":"https://t","thumbnailLink":"https://img"}]}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final resp = await client.searchEnded(searchWords: 'glassvas');
    expect(resp.items.single.maxBid, 123);
  });

  test(
    'TraderaClient maps rate-limited proxy error into actionable exception',
    () async {
      final client = TraderaClient(
        functionUrl: Uri.parse(
          'https://example.com/functions/v1/tradera-proxy',
        ),
        httpClient: MockClient((req) async {
          return http.Response(
            '{"error":{"code":"rate_limited","message":"Too many requests","retryAfterSeconds":12}}',
            429,
            headers: {'content-type': 'application/json', 'retry-after': '12'},
          );
        }),
      );

      await expectLater(
        client.searchEnded(searchWords: 'glassvas'),
        throwsA(
          isA<TraderaClientException>().having(
            (e) => e.message,
            'message',
            allOf(contains('Too many requests'), contains('12s')),
          ),
        ),
      );
    },
  );

  test('TraderaClient retries on transient 5xx and can recover', () async {
    var call = 0;
    final client = TraderaClient(
      functionUrl: Uri.parse('https://example.com/functions/v1/tradera-proxy'),
      maxAttempts: 2,
      httpClient: MockClient((req) async {
        call += 1;
        if (call == 1) {
          return http.Response(
            '{"error":{"code":"upstream_failed","message":"temporary"}}',
            502,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response(
          '{"totalNumberOfItems":1,"totalNumberOfPages":1,"items":[{"id":1,"shortDescription":"x","endDate":"2026-02-01T12:00:00","maxBid":123,"totalBids":4,"hasBids":true,"isEnded":true,"itemLink":"https://t","thumbnailLink":"https://img"}]}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final resp = await client.searchEnded(searchWords: 'glassvas');
    expect(resp.items.single.maxBid, 123);
    expect(call, 2);
  });
}
