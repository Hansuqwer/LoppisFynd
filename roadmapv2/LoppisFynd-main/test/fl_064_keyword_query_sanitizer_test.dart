import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/text/keyword_query_sanitizer.dart';

void main() {
  group('sanitizeKeywordQuery', () {
    test('returns null for null/blank', () {
      expect(sanitizeKeywordQuery(null), isNull);
      expect(sanitizeKeywordQuery(''), isNull);
      expect(sanitizeKeywordQuery('   '), isNull);
    });

    test('splits whitespace and keeps up to 5 tokens', () {
      expect(sanitizeKeywordQuery('a  b\n c\t d  e  f'), 'a b c d e');
    });

    test('returns null when result is shorter than 2 chars', () {
      expect(sanitizeKeywordQuery('a'), isNull);
    });

    test('trims and caps length at 80 chars', () {
      final long = 'x' * 200;
      final out = sanitizeKeywordQuery(long);
      expect(out, isNotNull);
      expect(out!.length, lessThanOrEqualTo(80));
    });
  });
}
