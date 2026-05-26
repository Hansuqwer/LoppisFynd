import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/books/qa_isbn_lookup_service.dart';

void main() {
  group('QaStableIsbnLookupService', () {
    const service = QaStableIsbnLookupService();

    test('returns stable metadata for the success ISBN', () async {
      final metadata = await service.lookupIsbn('978-0-306-40615-7');

      expect(metadata, isNotNull);
      expect(metadata!.isbn, QaStableIsbnLookupService.successIsbn);
      expect(metadata.title, 'BokFynd QA Stable Book');
      expect(metadata.source, 'qa_stable');
    });

    test('returns null for the valid not-found ISBN', () async {
      final metadata = await service.lookupIsbn(
        QaStableIsbnLookupService.notFoundIsbn,
      );

      expect(metadata, isNull);
    });

    test('throws a stable error for the error ISBN', () {
      expect(
        () => service.lookupIsbn(QaStableIsbnLookupService.errorIsbn),
        throwsA(isA<StateError>()),
      );
    });

    test('returns null for any other ISBN', () async {
      final metadata = await service.lookupIsbn('9789100128883');

      expect(metadata, isNull);
    });
  });
}
