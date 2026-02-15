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
}
