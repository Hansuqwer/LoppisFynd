import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/ai/inference/ai_json_parser.dart';

void main() {
  test('parseSingleItem accepts valid JSON', () {
    final raw =
        '{'
        '"desc":"Rorstrand plate",'
        '"query":"Rorstrand Mon Amie tallrik",'
        '"confidence":0.72,'
        '"attributes":{"brand":"Rorstrand","model":"Mon Amie","material":"porcelain","era":"1970s"}'
        '}';

    final parsed = AiJsonParser.parseSingleItem(raw);
    expect(parsed.query, contains('tallrik'));
    expect(parsed.confidence, closeTo(0.72, 0.0001));
  });

  test('parseBatchShelf enforces max 5 items', () {
    final raw =
        '{"items":['
        '{"desc":"a","query":"b","confidence":0.1},'
        '{"desc":"a","query":"b","confidence":0.1},'
        '{"desc":"a","query":"b","confidence":0.1},'
        '{"desc":"a","query":"b","confidence":0.1},'
        '{"desc":"a","query":"b","confidence":0.1},'
        '{"desc":"a","query":"b","confidence":0.1}'
        ']}';

    expect(() => AiJsonParser.parseBatchShelf(raw), throwsException);
  });
}
