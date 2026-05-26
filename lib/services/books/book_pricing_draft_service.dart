import 'book_market_data_service.dart';
import 'book_market_service.dart';
import 'isbn_lookup_service.dart';

class BookPricingDraft {
  const BookPricingDraft({
    required this.isbn,
    required this.metadata,
    required this.marketQuery,
    this.marketStats,
  });

  final String isbn;
  final BookMetadata metadata;
  final String marketQuery;
  final BookMarketStats? marketStats;

  bool get hasMarketStats => marketStats != null;

  int? get suggestedListPriceSek => marketStats?.averageSoldPriceSek;
}

abstract class BookPricingDraftCreator {
  Future<BookPricingDraft?> createDraftForIsbn({
    required String isbn,
    DateTime? now,
  });
}

class BookPricingDraftService implements BookPricingDraftCreator {
  const BookPricingDraftService({
    required BookMetadataLookup metadataLookup,
    BookMarketStatsLookup? marketLookup,
  }) : _metadataLookup = metadataLookup,
       _marketLookup = marketLookup;

  final BookMetadataLookup _metadataLookup;
  final BookMarketStatsLookup? _marketLookup;

  @override
  Future<BookPricingDraft?> createDraftForIsbn({
    required String isbn,
    DateTime? now,
  }) async {
    final metadata = await _metadataLookup.lookupIsbn(isbn);
    if (metadata == null) return null;

    final marketQuery = _marketQueryFor(metadata);
    final marketStats = await _marketLookup?.fetchStatsForBookQuery(
      query: marketQuery,
      now: now,
    );

    return BookPricingDraft(
      isbn: metadata.isbn,
      metadata: metadata,
      marketQuery: marketQuery,
      marketStats: marketStats,
    );
  }
}

String _marketQueryFor(BookMetadata metadata) {
  final title = metadata.title.trim();
  final firstAuthor = metadata.authors
      .map((author) => author.trim())
      .where((author) => author.isNotEmpty)
      .firstOrNull;
  if (firstAuthor == null) return title;
  return '$title $firstAuthor';
}
