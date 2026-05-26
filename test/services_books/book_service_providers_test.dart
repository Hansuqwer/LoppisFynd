import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fynd_loppis/core/app/providers.dart';
import 'package:fynd_loppis/core/config/app_config.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/features/scanner/barcode/mlkit_book_isbn_adapter.dart';
import 'package:fynd_loppis/services/books/book_barcode_isbn_handoff_service.dart';
import 'package:fynd_loppis/services/books/book_isbn_draft_flow_controller.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_application_service.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_mapper.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_orchestration_service.dart';
import 'package:fynd_loppis/services/books/book_market_service.dart';
import 'package:fynd_loppis/services/books/book_pricing_draft_service.dart';
import 'package:fynd_loppis/services/books/book_scanner_isbn_handoff_coordinator.dart';
import 'package:fynd_loppis/services/books/isbn_lookup_service.dart';
import 'package:fynd_loppis/services/books/qa_isbn_lookup_service.dart';

void main() {
  group('book service providers', () {
    test('provides ISBN lookup service with config seam', () {
      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            _config(googleBooksApiKey: 'books-key'),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(appConfigProvider).hasGoogleBooksApiKey, isTrue);
      expect(
        container.read(isbnLookupServiceProvider),
        isA<IsbnLookupService>(),
      );
    });

    test('uses stable BokFynd ISBN lookup data only in dev', () {
      final devContainer = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            _config(appEnv: 'dev', bokfyndQaStableIsbnData: true),
          ),
        ],
      );
      addTearDown(devContainer.dispose);

      final prodContainer = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            _config(appEnv: 'prod', bokfyndQaStableIsbnData: true),
          ),
        ],
      );
      addTearDown(prodContainer.dispose);

      expect(
        devContainer.read(isbnLookupServiceProvider),
        isA<QaStableIsbnLookupService>(),
      );
      expect(
        prodContainer.read(isbnLookupServiceProvider),
        isA<IsbnLookupService>(),
      );
    });

    test('keeps book market service disabled without Tradera proxy', () {
      final container = ProviderContainer(
        overrides: [appConfigProvider.overrideWithValue(_config())],
      );
      addTearDown(container.dispose);

      expect(container.read(bookMarketServiceProvider), isNull);
    });

    test('provides book market service when Tradera proxy is configured', () {
      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            _config(traderaProxyUrl: 'https://example.test/tradera'),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(bookMarketServiceProvider),
        isA<BookMarketService>(),
      );
    });

    test('provides book pricing draft orchestration service', () {
      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            _config(traderaProxyUrl: 'https://example.test/tradera'),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(bookPricingDraftServiceProvider),
        isA<BookPricingDraftService>(),
      );
    });

    test(
      'provides inventory draft mapper, applier, and orchestration service',
      () {
        final db = AppDatabase.inMemory();
        addTearDown(db.close);
        final container = ProviderContainer(
          overrides: [
            appConfigProvider.overrideWithValue(_config()),
            appDatabaseProvider.overrideWithValue(db),
          ],
        );
        addTearDown(container.dispose);

        expect(
          container.read(bookInventoryDraftMapperProvider),
          isA<BookInventoryDraftMapper>(),
        );
        expect(
          container.read(bookInventoryDraftApplicationServiceProvider),
          isA<BookInventoryDraftApplicationService>(),
        );
        expect(
          container.read(bookInventoryDraftOrchestrationServiceProvider),
          isA<BookInventoryDraftOrchestrationService>(),
        );
        expect(
          container.read(bookIsbnDraftFlowControllerProvider),
          isA<BookIsbnDraftFlowController>(),
        );
        expect(
          container.read(bookBarcodeIsbnHandoffServiceProvider),
          isA<BookBarcodeIsbnHandoffService>(),
        );
        expect(
          container.read(mlKitBookIsbnAdapterProvider),
          isA<MlKitBookIsbnAdapter>(),
        );
        expect(
          container.read(bookScannerIsbnHandoffCoordinatorProvider),
          isA<BookScannerIsbnHandoffCoordinator>(),
        );
      },
    );
  });
}

AppConfig _config({
  String appEnv = 'test',
  String traderaProxyUrl = '',
  String googleBooksApiKey = '',
  bool bokfyndQaStableIsbnData = false,
}) {
  return AppConfig(
    appEnv: appEnv,
    traderaProxyUrl: traderaProxyUrl,
    googleBooksApiKey: googleBooksApiKey,
    bokfyndQaStableIsbnData: bokfyndQaStableIsbnData,
    cloudAiProxyUrl: '',
    supabaseUrl: '',
    supabaseAnonKey: '',
    sentryDsn: '',
  );
}
