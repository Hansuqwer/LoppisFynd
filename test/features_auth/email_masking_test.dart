import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/features/auth/email_masking.dart';

void main() {
  group('maskEmailForUi', () {
    test('keeps domain visible and masks local-part', () {
      expect(maskEmailForUi('anna@gmail.com'), 'ann•••@gmail.com');
    });

    test('trims input', () {
      expect(maskEmailForUi('  anna@gmail.com  '), 'ann•••@gmail.com');
    });

    test('handles plus addressing by masking base local-part', () {
      expect(maskEmailForUi('anna+tag@gmail.com'), 'ann•••@gmail.com');
    });

    test('handles very short local-part', () {
      expect(maskEmailForUi('a@gmail.com'), 'a•@gmail.com');
      expect(maskEmailForUi('ab@gmail.com'), 'a•@gmail.com');
      expect(maskEmailForUi('abc@gmail.com'), 'ab•@gmail.com');
    });

    test('handles missing @ or empty pieces', () {
      expect(maskEmailForUi(''), '');
      expect(maskEmailForUi('   '), '');
      expect(maskEmailForUi('no-at-sign'), 'no-•••');
      expect(maskEmailForUi('@gmail.com'), '•••@gmail.com');
      expect(maskEmailForUi('anna@'), 'ann•••');
    });
  });
}
