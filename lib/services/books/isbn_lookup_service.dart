import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class BookMetadata {
  const BookMetadata({
    required this.isbn,
    required this.title,
    required this.source,
    this.authors = const [],
    this.publisher,
    this.publishYear,
    this.coverUrl,
    this.categories = const [],
  });

  final String isbn;
  final String title;
  final String source;
  final List<String> authors;
  final String? publisher;
  final int? publishYear;
  final String? coverUrl;
  final List<String> categories;

  bool get isChildrensBook => _isChildrensCategory(categories);

  static bool _isChildrensCategory(List<String> categories) {
    if (categories.isEmpty) return false;
    final childrenKeywords = [
      'Juvenile Fiction',
      'Juvenile Nonfiction',
      'Childrens Fiction',
      'Childrens Nonfiction',
      'Children',
      'Young Adult',
      'Young Adult Fiction',
      'Young Adult Nonfiction',
      'Barn',
      'Barnbok',
      'Barnböcker',
      'Ungdom',
      'Ungdomsbok',
      'Ungdomsböcker',
      'Bildbok',
      'Bilderböcker',
    ];
    for (final category in categories) {
      final lower = category.toLowerCase();
      for (final keyword in childrenKeywords) {
        if (lower.contains(keyword.toLowerCase())) {
          return true;
        }
      }
    }
    return false;
  }
}

abstract class IsbnMetadataCache {
  Future<BookMetadata?> get(String isbn);
  Future<void> put(BookMetadata metadata);
}

abstract class BookMetadataLookup {
  Future<BookMetadata?> lookupIsbn(String isbn);
}

class MemoryIsbnMetadataCache implements IsbnMetadataCache {
  final Map<String, BookMetadata> _items = {};

  @override
  Future<BookMetadata?> get(String isbn) async => _items[isbn];

  @override
  Future<void> put(BookMetadata metadata) async {
    _items[metadata.isbn] = metadata;
  }
}

class IsbnLookupService implements BookMetadataLookup {
  IsbnLookupService({
    http.Client? httpClient,
    IsbnMetadataCache? cache,
    String? googleBooksApiKey,
    Uri? googleBooksBaseUrl,
    Uri? openLibraryBaseUrl,
    Duration timeout = const Duration(seconds: 8),
  }) : _httpClient = httpClient ?? http.Client(),
       _cache = cache,
       _googleBooksApiKey = googleBooksApiKey,
       _googleBooksBaseUrl =
           googleBooksBaseUrl ??
           Uri.parse('https://www.googleapis.com/books/v1/volumes'),
       _openLibraryBaseUrl =
           openLibraryBaseUrl ?? Uri.parse('https://openlibrary.org/api/books'),
       _timeout = timeout;

  final http.Client _httpClient;
  final IsbnMetadataCache? _cache;
  final String? _googleBooksApiKey;
  final Uri _googleBooksBaseUrl;
  final Uri _openLibraryBaseUrl;
  final Duration _timeout;

  @override
  Future<BookMetadata?> lookupIsbn(String isbn) async {
    final normalized = _normalizeIsbn(isbn);
    if (normalized.isEmpty) return null;

    final cached = await _cache?.get(normalized);
    if (cached != null) return cached;

    final googleResult = await _lookupGoogleBooks(normalized);
    if (googleResult != null) {
      await _cache?.put(googleResult);
      return googleResult;
    }

    final openLibraryResult = await _lookupOpenLibrary(normalized);
    if (openLibraryResult != null) {
      await _cache?.put(openLibraryResult);
    }
    return openLibraryResult;
  }

  Future<BookMetadata?> _lookupGoogleBooks(String isbn) async {
    final queryParameters = <String, String>{'q': 'isbn:$isbn'};
    final apiKey = _googleBooksApiKey?.trim();
    if (apiKey != null && apiKey.isNotEmpty) {
      queryParameters['key'] = apiKey;
    }
    final uri = _googleBooksBaseUrl.replace(queryParameters: queryParameters);

    final decoded = await _getJsonObject(uri);
    if (decoded == null || decoded['totalItems'] == 0) return null;

    final items = decoded['items'];
    if (items is! List || items.isEmpty) return null;
    final first = items.first;
    if (first is! Map) return null;
    final volumeInfo = first['volumeInfo'];
    if (volumeInfo is! Map) return null;

    final title = volumeInfo['title'];
    if (title is! String || title.trim().isEmpty) return null;

    return BookMetadata(
      isbn: isbn,
      title: title,
      source: 'google_books',
      authors: _stringList(volumeInfo['authors']),
      publisher: _optionalString(volumeInfo['publisher']),
      publishYear: _parseYear(_optionalString(volumeInfo['publishedDate'])),
      coverUrl: _imageLink(volumeInfo['imageLinks']),
      categories: _stringList(volumeInfo['categories']),
    );
  }

  Future<BookMetadata?> _lookupOpenLibrary(String isbn) async {
    final uri = _openLibraryBaseUrl.replace(
      queryParameters: {
        'bibkeys': 'ISBN:$isbn',
        'format': 'json',
        'jscmd': 'data',
      },
    );

    final decoded = await _getJsonObject(uri);
    if (decoded == null) return null;
    final book = decoded['ISBN:$isbn'];
    if (book is! Map) return null;

    final title = book['title'];
    if (title is! String || title.trim().isEmpty) return null;

    return BookMetadata(
      isbn: isbn,
      title: title,
      source: 'open_library',
      authors: _namedItems(book['authors']),
      publisher: _namedItems(book['publishers']).firstOrNull,
      publishYear: _parseYear(_optionalString(book['publish_date'])),
      coverUrl: _imageLink(book['cover']),
    );
  }

  Future<Map<String, Object?>?> _getJsonObject(Uri uri) async {
    try {
      final response = await _httpClient.get(uri).timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;
      return decoded.cast<String, Object?>();
    } on FormatException {
      return null;
    } on TimeoutException {
      return null;
    } on http.ClientException {
      return null;
    }
  }
}

String _normalizeIsbn(String raw) {
  return raw.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<String>()
      .where((item) => item.trim().isNotEmpty)
      .toList();
}

List<String> _namedItems(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => item['name'])
      .whereType<String>()
      .where((item) => item.trim().isNotEmpty)
      .toList();
}

String? _optionalString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _imageLink(Object? value) {
  if (value is! Map) return null;
  final thumbnail = _optionalString(value['thumbnail']);
  if (thumbnail != null) return thumbnail;
  return _optionalString(value['medium']);
}

int? _parseYear(String? value) {
  if (value == null || value.length < 4) return null;
  return int.tryParse(value.substring(0, 4));
}
