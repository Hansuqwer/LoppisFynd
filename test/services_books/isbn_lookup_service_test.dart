import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:fynd_loppis/services/books/isbn_lookup_service.dart';

void main() {
  group('IsbnLookupService', () {
    test(
      'maps Google Books metadata and sends API key when configured',
      () async {
        Uri? requestedUri;
        final service = IsbnLookupService(
          googleBooksApiKey: 'test-key',
          httpClient: MockClient((req) async {
            requestedUri = req.url;
            return http.Response(
              '''
            {
              "totalItems": 1,
              "items": [
                {
                  "volumeInfo": {
                    "title": "Den allvarsamma leken",
                    "authors": ["Hjalmar Söderberg"],
                    "publisher": "Albert Bonniers Förlag",
                    "publishedDate": "1912-01-01",
                    "imageLinks": { "thumbnail": "https://example.com/cover.jpg" }
                  }
                }
              ]
            }
            ''',
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );

        final metadata = await service.lookupIsbn('978-91-0-012888-3');

        expect(requestedUri?.host, 'www.googleapis.com');
        expect(requestedUri?.queryParameters['q'], 'isbn:9789100128883');
        expect(requestedUri?.queryParameters['key'], 'test-key');
        expect(metadata?.source, 'google_books');
        expect(metadata?.isbn, '9789100128883');
        expect(metadata?.title, 'Den allvarsamma leken');
        expect(metadata?.authors, ['Hjalmar Söderberg']);
        expect(metadata?.publisher, 'Albert Bonniers Förlag');
        expect(metadata?.publishYear, 1912);
        expect(metadata?.coverUrl, 'https://example.com/cover.jpg');
      },
    );

    test(
      'falls back to Open Library when Google Books has no result',
      () async {
        var calls = 0;
        final service = IsbnLookupService(
          httpClient: MockClient((req) async {
            calls += 1;
            if (req.url.host == 'www.googleapis.com') {
              return http.Response('{"totalItems":0,"items":[]}', 200);
            }
            expect(req.url.host, 'openlibrary.org');
            expect(req.url.queryParameters['bibkeys'], 'ISBN:9780141439518');
            return http.Response(
              '''
            {
              "ISBN:9780141439518": {
                "title": "Pride and Prejudice",
                "authors": [{ "name": "Jane Austen" }],
                "publishers": [{ "name": "Penguin Classics" }],
                "publish_date": "2003",
                "cover": { "medium": "https://example.com/austen.jpg" }
              }
            }
            ''',
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );

        final metadata = await service.lookupIsbn('9780141439518');

        expect(calls, 2);
        expect(metadata?.source, 'open_library');
        expect(metadata?.title, 'Pride and Prejudice');
        expect(metadata?.authors, ['Jane Austen']);
        expect(metadata?.publisher, 'Penguin Classics');
        expect(metadata?.publishYear, 2003);
        expect(metadata?.coverUrl, 'https://example.com/austen.jpg');
      },
    );

    test('returns cached metadata without a network call', () async {
      final cache = MemoryIsbnMetadataCache();
      await cache.put(
        const BookMetadata(
          isbn: '9789100128883',
          title: 'Cached Book',
          source: 'cache',
        ),
      );
      final service = IsbnLookupService(
        cache: cache,
        httpClient: MockClient((req) async {
          fail('network should not be called for cached ISBN');
        }),
      );

      final metadata = await service.lookupIsbn('978-91-0-012888-3');

      expect(metadata?.title, 'Cached Book');
      expect(metadata?.source, 'cache');
    });

    test('stores successful lookup in cache', () async {
      final cache = MemoryIsbnMetadataCache();
      var calls = 0;
      final service = IsbnLookupService(
        cache: cache,
        httpClient: MockClient((req) async {
          calls += 1;
          return http.Response(
            '{"totalItems":1,"items":[{"volumeInfo":{"title":"Cached After Lookup"}}]}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final first = await service.lookupIsbn('9789100128883');
      final second = await service.lookupIsbn('9789100128883');

      expect(first?.title, 'Cached After Lookup');
      expect(second?.title, 'Cached After Lookup');
      expect(calls, 1);
    });

    test(
      'returns null for not found, non-2xx, malformed JSON, and blank input',
      () async {
        final responses = <http.Response>[
          http.Response('{"totalItems":0,"items":[]}', 200),
          http.Response('{}', 404),
          http.Response('not json', 200),
          http.Response('{}', 404),
        ];
        var index = 0;
        final service = IsbnLookupService(
          httpClient: MockClient((req) async {
            final response = responses[index];
            index += 1;
            return response;
          }),
        );

        expect(await service.lookupIsbn('9789100128883'), isNull);
        expect(await service.lookupIsbn('9789100128883'), isNull);
        expect(await service.lookupIsbn(''), isNull);
      },
    );
  });
}
