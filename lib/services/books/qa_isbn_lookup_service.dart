import 'isbn_lookup_service.dart';

class QaStableIsbnLookupService implements BookMetadataLookup {
  const QaStableIsbnLookupService();

  static const successIsbn = '9780306406157';
  static const notFoundIsbn = '9780143127796';
  static const errorIsbn = '0306406152';

  @override
  Future<BookMetadata?> lookupIsbn(String isbn) async {
    final normalized = isbn.trim().toUpperCase().replaceAll(
      RegExp(r'[\s-]'),
      '',
    );

    return switch (normalized) {
      successIsbn => const BookMetadata(
        isbn: successIsbn,
        title: 'BokFynd QA Stable Book',
        source: 'qa_stable',
        authors: ['BokFynd QA'],
        publisher: 'QA Press',
        publishYear: 2026,
      ),
      notFoundIsbn => null,
      errorIsbn => throw StateError('QA forced ISBN lookup failure.'),
      _ => null,
    };
  }
}
