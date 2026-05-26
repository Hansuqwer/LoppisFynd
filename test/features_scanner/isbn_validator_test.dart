import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/features/scanner/isbn/isbn_validator.dart';

void main() {
  const validator = IsbnValidator();

  group('IsbnValidator', () {
    test('normalizes spaces, hyphens, and lowercase x', () {
      expect(validator.normalize(' 0-306-40615-x '), '030640615X');
      expect(validator.normalize('978 91 0012888 3'), '9789100128883');
    });

    test('accepts valid ISBN-13 values with book prefixes', () {
      expect(validator.isValid('9789100128883'), isTrue);
      expect(validator.isValid('978-0-306-40615-7'), isTrue);
    });

    test('accepts valid ISBN-10 values', () {
      expect(validator.isValid('0306406152'), isTrue);
      expect(validator.isValid('0-306-40615-2'), isTrue);
      expect(validator.isValid('080442957X'), isTrue);
    });

    test('rejects invalid checksum values', () {
      expect(validator.isValid('9789100128884'), isFalse);
      expect(validator.isValid('0306406153'), isFalse);
    });

    test('rejects non-book EAN-13 prefixes', () {
      expect(validator.isValid('4006381333931'), isFalse);
    });

    test('rejects malformed manual entry input', () {
      expect(validator.isValid(''), isFalse);
      expect(validator.isValid('97891'), isFalse);
      expect(validator.isValid('978ABCDEFGHIJ'), isFalse);
    });
  });
}
