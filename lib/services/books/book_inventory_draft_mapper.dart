import 'book_market_data_service.dart';
import 'book_pricing_draft_service.dart';

class BookInventoryDraftPayload {
  const BookInventoryDraftPayload({
    required this.scanItem,
    required this.listing,
  });

  final BookScanItemDraftPayload scanItem;
  final BookListingDraftPayload listing;
}

class BookScanItemDraftPayload {
  const BookScanItemDraftPayload({
    required this.query,
    required this.desc,
    required this.category,
    this.notes,
    this.medianPriceSek,
    this.minPriceSek,
    this.maxPriceSek,
  });

  final String query;
  final String desc;
  final String category;
  final String? notes;
  final double? medianPriceSek;
  final double? minPriceSek;
  final double? maxPriceSek;
}

class BookListingDraftPayload {
  const BookListingDraftPayload({
    required this.platform,
    required this.title,
    required this.description,
    this.askingPriceSek,
  });

  final String platform;
  final String title;
  final String description;
  final double? askingPriceSek;
}

class BookInventoryDraftMapper {
  const BookInventoryDraftMapper();

  BookInventoryDraftPayload map(BookPricingDraft draft) {
    final stats = draft.marketStats;
    final title = _listingTitle(draft);
    final description = _description(draft);
    final notes = _notes(stats);

    return BookInventoryDraftPayload(
      scanItem: BookScanItemDraftPayload(
        query: draft.marketQuery,
        desc: _scanDescription(draft),
        category: 'Books',
        notes: notes,
        medianPriceSek: stats?.averageSoldPriceSek.toDouble(),
        minPriceSek: stats?.lowestSoldPriceSek.toDouble(),
        maxPriceSek: stats?.highestSoldPriceSek.toDouble(),
      ),
      listing: BookListingDraftPayload(
        platform: 'tradera',
        title: title,
        description: description,
        askingPriceSek: stats?.averageSoldPriceSek.toDouble(),
      ),
    );
  }
}

String _listingTitle(BookPricingDraft draft) {
  final title = draft.metadata.title.trim();
  final firstAuthor = _firstAuthor(draft);
  if (firstAuthor == null) return title;
  return '$title - $firstAuthor';
}

String _scanDescription(BookPricingDraft draft) {
  final parts = <String>[
    draft.metadata.title.trim(),
    ...draft.metadata.authors.map((author) => author.trim()),
  ].where((part) => part.isNotEmpty).toList(growable: false);
  return parts.join(' ');
}

String _description(BookPricingDraft draft) {
  final metadata = draft.metadata;
  final authors = _authors(draft);
  final lines = <String>[
    metadata.title.trim(),
    if (authors.isNotEmpty) 'Author: ${authors.join(', ')}',
    if (metadata.publisher?.trim().isNotEmpty ?? false)
      'Publisher: ${metadata.publisher!.trim()}',
    if (metadata.publishYear != null) 'Year: ${metadata.publishYear}',
    'ISBN: ${draft.isbn}',
    if (draft.marketStats != null) _marketEvidence(draft.marketStats!),
  ];
  return lines.where((line) => line.trim().isNotEmpty).join('\n');
}

String? _notes(BookMarketStats? stats) {
  if (stats == null) return null;
  return [
    'BokFynd market stats',
    'average=${stats.averageSoldPriceSek} SEK',
    'low=${stats.lowestSoldPriceSek} SEK',
    'high=${stats.highestSoldPriceSek} SEK',
    'sales=${stats.totalSales}',
  ].join('; ');
}

String _marketEvidence(BookMarketStats stats) {
  return 'Market evidence: ${stats.totalSales} sales, '
      '${stats.lowestSoldPriceSek}-${stats.highestSoldPriceSek} SEK, '
      'avg ${stats.averageSoldPriceSek} SEK.';
}

String? _firstAuthor(BookPricingDraft draft) {
  return _authors(draft).firstOrNull;
}

List<String> _authors(BookPricingDraft draft) {
  return draft.metadata.authors
      .map((author) => author.trim())
      .where((author) => author.isNotEmpty)
      .toList(growable: false);
}
