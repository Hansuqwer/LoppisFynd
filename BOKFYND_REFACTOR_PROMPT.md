# BokFynd Refactoring Prompt

**Objective:** Refactor the LoppisFynd Flutter application into BokFynd, a specialized book scanning and pricing app for second-hand book resellers.

---

## Product Vision

### What is BokFynd?

BokFynd is a mobile app that helps second-hand book sellers (at flea markets, thrift stores, etc.) quickly evaluate whether a book is worth buying by:

1. **Scanning ISBN barcodes** to instantly identify books
2. **Showing market data** from multiple Swedish second-hand platforms (Tradera, Vinted, Bokbörsen, etc.)
3. **Quick pricing decisions** with configurable price buttons (5kr, 10kr, 15kr, 20kr, 25kr, 30kr)
4. **Profit calculation** showing potential earnings after platform fees
5. **Building an inventory** of books to sell

### Core User Flow

```
1. User scans ISBN barcode at flea market
2. App fetches book cover + metadata (title, author, year)
3. App shows market data:
   - Highest sold price (last 12 months)
   - Current average price
   - Lowest sold price (last 12 months)
   - Number of sales per month
4. User sees quick price buttons: [5kr] [10kr] [15kr] [20kr] [25kr] [30kr]
5. User taps "10kr" → App calculates profit margin
6. User taps "Yes" to save or "No" to skip
7. Book added to inventory list with purchase price and potential profit
```

---

## Architecture Changes from LoppisFynd

### What to Keep (Reuse)

✅ **Core Architecture:**
- Offline-first Drift database
- Riverpod state management
- Feature-first organization
- Background sync with Workmanager
- Supabase cloud sync (optional)
- Serial task queues
- State machine pattern

✅ **Infrastructure:**
- `lib/core/database/` (adapt tables)
- `lib/core/app/providers.dart` (adapt providers)
- `lib/core/config/` (update config keys)
- `lib/core/navigation/` (simplify to book-focused tabs)
- `lib/core/theme/` (rebrand colors/fonts)

✅ **Services:**
- Analytics service
- Cloud sync coordinator (adapt for books)
- Background sync scheduler
- Privacy/export services

### What to Remove

❌ **AI Inference:**
- Remove `lib/services/ai/**` (no AI needed for ISBN lookup)
- Remove `flutter_gemma` dependency
- Remove model download/management

❌ **Camera Capture:**
- Remove `lib/features/scanner/scanner_screen.dart` (replace with barcode-only)
- Remove image storage (no photos needed)
- Remove thumbnail generation

❌ **Complex Features:**
- Remove `lib/features/analyzer/` (simplified to book detail)
- Remove `lib/features/drafts/` (not needed for books)
- Remove `lib/features/hauls/` (rename to "inventory")

### What to Transform

🔄 **Scanner → ISBN Scanner:**
- Replace camera capture with barcode scanner only
- Focus on ISBN-10 and ISBN-13 formats
- Instant lookup (no AI processing)

🔄 **Market Data → Book Market Data:**
- Replace Tradera-only with multi-platform aggregation
- Add Vinted, Bokbörsen, Adlibris, Bokus APIs
- Focus on sold prices (not active listings)

🔄 **Item Detail → Book Detail:**
- Show book cover, title, author, year
- Display price statistics (high/avg/low)
- Show sales velocity (books sold per month)
- Quick price buttons with profit calculator

🔄 **History → Inventory:**
- List of scanned books with purchase prices
- Filter by: saved/skipped, profit margin, date
- Export inventory for accounting

---

## New Data Model

### Core Entities

```dart
// Replace ScanItems with Books
class Books extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get isbn => text()(); // ISBN-10 or ISBN-13
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get publisher => text().nullable()();
  IntColumn get publishYear => integer().nullable()();
  TextColumn get coverUrl => text().nullable()();
  
  // Purchase decision
  IntColumn get purchasePriceSek => integer().nullable()(); // What user paid
  BoolColumn get saved => boolean().withDefault(const Constant(false))();
  
  // Market data (cached)
  IntColumn get highestSoldPriceSek => integer().nullable()();
  IntColumn get averageSoldPriceSek => integer().nullable()();
  IntColumn get lowestSoldPriceSek => integer().nullable()();
  IntColumn get salesPerMonth => integer().nullable()();
  
  DateTimeColumn get scannedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Market data from multiple platforms
class BookMarketData extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()(); // FK to Books
  TextColumn get platform => text()(); // 'tradera', 'vinted', 'bokborsen'
  IntColumn get soldPriceSek => integer()();
  DateTimeColumn get soldAt => dateTime()();
  TextColumn get listingUrl => text().nullable()();
  
  DateTimeColumn get fetchedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// User's price button configuration
class PriceButtonConfig extends Table {
  IntColumn get position => integer()(); // 0-5
  IntColumn get priceSek => integer()(); // e.g., 5, 10, 15, 20, 25, 30
  
  @override
  Set<Column> get primaryKey => {position};
}

// Replace Hauls with InventoryBatches (optional grouping)
class InventoryBatches extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()(); // e.g., "Loppis Södermalm 2026-04-28"
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

### Status State Machine

```dart
enum BookStatus {
  scanning,      // Barcode scanned, fetching data
  priceDecision, // Showing market data, waiting for user decision
  saved,         // User saved to inventory
  skipped,       // User skipped
  failed,        // ISBN lookup failed
}
```

---

## New Services Architecture

### 1. ISBN Lookup Service

```dart
class IsbnLookupService {
  // Fetch book metadata from ISBN
  Future<BookMetadata?> lookupIsbn(String isbn) async {
    // Try multiple sources in order:
    // 1. Google Books API (free, comprehensive)
    // 2. Open Library API (fallback)
    // 3. Local cache
  }
}

class BookMetadata {
  final String isbn;
  final String title;
  final String? author;
  final String? publisher;
  final int? publishYear;
  final String? coverUrl;
}
```

### 2. Book Market Data Service

```dart
class BookMarketDataService {
  // Aggregate market data from multiple platforms
  Future<BookMarketStats?> fetchMarketStats({
    required String isbn,
    Duration period = const Duration(days: 365),
  }) async {
    // Fetch from:
    // - Tradera (via existing proxy)
    // - Vinted API
    // - Bokbörsen scraper
    // - Adlibris/Bokus (if available)
    
    // Aggregate and calculate stats
  }
}

class BookMarketStats {
  final int highestSoldPriceSek;
  final int averageSoldPriceSek;
  final int lowestSoldPriceSek;
  final int totalSales;
  final double salesPerMonth;
  final List<BookSale> recentSales;
}

class BookSale {
  final String platform;
  final int priceSek;
  final DateTime soldAt;
  final String? listingUrl;
}
```

### 3. Profit Calculator Service

```dart
class ProfitCalculatorService {
  // Calculate profit after platform fees
  ProfitEstimate calculateProfit({
    required int purchasePriceSek,
    required int sellPriceSek,
    required String platform,
  }) {
    final fees = _getPlatformFees(platform);
    final netProfit = sellPriceSek - purchasePriceSek - fees;
    final profitMargin = (netProfit / purchasePriceSek) * 100;
    
    return ProfitEstimate(
      purchasePrice: purchasePriceSek,
      sellPrice: sellPriceSek,
      platformFees: fees,
      netProfit: netProfit,
      profitMarginPercent: profitMargin,
    );
  }
  
  int _getPlatformFees(String platform) {
    // Tradera: ~8% + listing fee
    // Vinted: shipping cost
    // Bokbörsen: fixed fee
    // etc.
  }
}
```

### 4. Barcode Scanner Service

```dart
class BarcodeIsbnScannerService {
  // Simplified scanner focused on ISBN barcodes
  Stream<String> scanIsbn() async* {
    // Use google_mlkit_barcode_scanning
    // Filter for EAN-13 (ISBN-13) and EAN-8 (ISBN-10)
    // Validate ISBN checksum
  }
  
  bool isValidIsbn(String code) {
    // Validate ISBN-10 or ISBN-13 checksum
  }
}
```

---

## New UI/UX Flow

### 1. Scanner Screen (Simplified)

```dart
class IsbnScannerScreen extends ConsumerStatefulWidget {
  // Barcode scanner overlay
  // Show last scanned ISBN
  // Quick feedback: "Looking up book..."
  // Navigate to BookDecisionScreen on success
}
```

### 2. Book Decision Screen (New)

```dart
class BookDecisionScreen extends ConsumerWidget {
  // Top: Book cover + metadata
  // Middle: Market stats card
  //   - Highest: 150 kr
  //   - Average: 85 kr
  //   - Lowest: 30 kr
  //   - Sales: 12/month
  // Bottom: Quick price buttons
  //   [5kr] [10kr] [15kr] [20kr] [25kr] [30kr]
  // On tap: Show profit calculation modal
  //   "Buy for 10kr, sell for 85kr avg"
  //   "Profit: 75kr (750%)"
  //   [Yes, Save] [No, Skip]
}
```

### 3. Inventory Screen (Transformed from History)

```dart
class InventoryScreen extends ConsumerWidget {
  // List of saved books
  // Show: cover, title, purchase price, potential profit
  // Filter: All / High Profit / Low Profit
  // Sort: Date / Profit / Title
  // Actions: Export CSV, Delete, Edit price
}
```

### 4. Book Detail Screen (Simplified from ItemDetailScreen)

```dart
class BookDetailScreen extends ConsumerWidget {
  // Full book metadata
  // Detailed market data chart (price over time)
  // Recent sales list (platform, price, date)
  // Edit purchase price
  // Mark as sold
  // Delete from inventory
}
```

### 5. Settings Screen (Updated)

```dart
class SettingsScreen extends ConsumerWidget {
  // Configure price buttons
  //   [Edit Prices] → PriceButtonConfigScreen
  // Platform fee settings
  // Market data refresh interval
  // Export/import inventory
  // Account settings (if using Supabase)
}
```

---

## API Integrations

### Required APIs

1. **Google Books API** (Free)
   - Endpoint: `https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}`
   - Returns: title, author, publisher, year, cover image
   - Rate limit: 1000 requests/day (free tier)

2. **Open Library API** (Free, fallback)
   - Endpoint: `https://openlibrary.org/api/books?bibkeys=ISBN:{isbn}&format=json&jscmd=data`
   - Returns: similar metadata
   - No rate limit

3. **Tradera API** (Existing)
   - Keep existing proxy
   - Search by book title + author
   - Filter for sold items only

4. **Vinted API** (Unofficial)
   - Scrape or use unofficial API
   - Search by ISBN or title
   - Extract sold prices

5. **Bokbörsen** (Scraping)
   - Web scraping (no official API)
   - Search by ISBN
   - Extract sold listings

### New Edge Functions

```typescript
// supabase/functions/book-market-aggregator/index.ts
export async function handleRequest(req: Request): Promise<Response> {
  const { isbn } = await req.json();
  
  // Fetch from multiple sources in parallel
  const [tradera, vinted, bokborsen] = await Promise.allSettled([
    fetchTraderaSales(isbn),
    fetchVintedSales(isbn),
    fetchBokborsenSales(isbn),
  ]);
  
  // Aggregate results
  const sales = [...tradera, ...vinted, ...bokborsen];
  const stats = calculateStats(sales);
  
  return json({ stats, sales });
}
```

---

## Configuration Changes

### App Config

```dart
class AppConfig {
  // Remove AI-related config
  // Remove Gemma model URL
  
  // Add book-specific config
  final String googleBooksApiKey;
  final String bookMarketAggregatorUrl;
  
  // Keep existing
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String traderaProxyUrl;
  final String sentryDsn;
}
```

### Feature Flags

```dart
class FeatureFlags {
  final bool enableCloudSync;
  final bool enableMarketData;
  final bool enableAnalytics;
  
  // New flags
  final bool enableVintedIntegration;
  final bool enableBokborsenIntegration;
  final bool enableProfitCalculator;
}
```

### User Settings

```dart
// New settings keys
const kPriceButton0 = 'price_button_0'; // Default: 5
const kPriceButton1 = 'price_button_1'; // Default: 10
const kPriceButton2 = 'price_button_2'; // Default: 15
const kPriceButton3 = 'price_button_3'; // Default: 20
const kPriceButton4 = 'price_button_4'; // Default: 25
const kPriceButton5 = 'price_button_5'; // Default: 30

const kDefaultPlatformForFees = 'default_platform'; // 'tradera', 'vinted', etc.
const kMarketDataRefreshIntervalHours = 'market_refresh_hours'; // Default: 24
```

---

## Migration Strategy

### Phase 1: Core Refactoring (Week 1-2)

**Day 1-3: Data Model**
- [ ] Create new Drift tables (Books, BookMarketData, PriceButtonConfig)
- [ ] Write migration from ScanItems to Books
- [ ] Create new DAOs (BooksDao, BookMarketDataDao, PriceButtonConfigDao)
- [ ] Remove AI-related tables

**Day 4-5: Services**
- [ ] Implement IsbnLookupService (Google Books + Open Library)
- [ ] Implement BarcodeIsbnScannerService
- [ ] Remove AI inference services
- [ ] Remove image storage services

**Day 6-10: UI Refactoring**
- [ ] Create IsbnScannerScreen (simplified scanner)
- [ ] Create BookDecisionScreen (new)
- [ ] Transform HistoryScreen → InventoryScreen
- [ ] Transform ItemDetailScreen → BookDetailScreen
- [ ] Update navigation (remove unused tabs)

### Phase 2: Market Data Integration (Week 3-4)

**Week 3: Backend**
- [ ] Create book-market-aggregator edge function
- [ ] Integrate Tradera search (adapt existing proxy)
- [ ] Add Vinted integration (scraping or API)
- [ ] Add Bokbörsen integration (scraping)

**Week 4: Frontend**
- [ ] Implement BookMarketDataService
- [ ] Add market stats display in BookDecisionScreen
- [ ] Add price history chart in BookDetailScreen
- [ ] Implement background market data refresh

### Phase 3: Profit Calculator & Polish (Week 5-6)

**Week 5: Features**
- [ ] Implement ProfitCalculatorService
- [ ] Add profit calculation modal
- [ ] Implement price button configuration screen
- [ ] Add platform fee settings

**Week 6: Polish**
- [ ] Update branding (colors, fonts, logo)
- [ ] Add onboarding flow for book sellers
- [ ] Implement inventory export (CSV)
- [ ] Add analytics events
- [ ] Write user documentation

### Phase 4: Testing & Launch (Week 7-8)

**Week 7: Testing**
- [ ] Unit tests for new services
- [ ] Widget tests for new screens
- [ ] Integration tests for ISBN lookup flow
- [ ] Manual testing with real books

**Week 8: Launch**
- [ ] Beta testing with book sellers
- [ ] Fix bugs and polish UX
- [ ] Prepare Play Store listing
- [ ] Launch BokFynd v1.0

---

## Dependency Changes

### Remove

```yaml
# Remove from pubspec.yaml
flutter_gemma: ^0.12.4  # No AI needed
camera: 0.11.4          # Use barcode scanner only
image: ^4.7.2           # No image processing
tflite_flutter: ^0.12.1 # No ML models
```

### Add

```yaml
# Add to pubspec.yaml
http: ^1.6.0            # Already present, use for APIs
google_mlkit_barcode_scanning: ^0.14.2  # Already present
charts_flutter: ^0.12.0 # For price history charts (optional)
csv: ^6.0.0             # For inventory export
```

### Keep

```yaml
# Keep existing
drift: 2.31.0
flutter_riverpod: 3.2.1
supabase_flutter: ^2.12.0
workmanager: 0.9.0+3
connectivity_plus: ^6.1.4
# ... other infrastructure deps
```

---

## Example Code Snippets

### ISBN Lookup Service

```dart
class IsbnLookupService {
  final http.Client _client;
  
  Future<BookMetadata?> lookupIsbn(String isbn) async {
    // Try Google Books first
    try {
      final response = await _client.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn'),
      );
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['totalItems'] > 0) {
          final book = json['items'][0]['volumeInfo'];
          return BookMetadata(
            isbn: isbn,
            title: book['title'],
            author: book['authors']?.first,
            publisher: book['publisher'],
            publishYear: int.tryParse(book['publishedDate']?.substring(0, 4) ?? ''),
            coverUrl: book['imageLinks']?['thumbnail'],
          );
        }
      }
    } catch (e) {
      // Fall through to Open Library
    }
    
    // Fallback to Open Library
    try {
      final response = await _client.get(
        Uri.parse('https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&format=json&jscmd=data'),
      );
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final book = json['ISBN:$isbn'];
        if (book != null) {
          return BookMetadata(
            isbn: isbn,
            title: book['title'],
            author: book['authors']?.first?['name'],
            publisher: book['publishers']?.first?['name'],
            publishYear: int.tryParse(book['publish_date'] ?? ''),
            coverUrl: book['cover']?['medium'],
          );
        }
      }
    } catch (e) {
      return null;
    }
    
    return null;
  }
}
```

### Book Decision Screen

```dart
class BookDecisionScreen extends ConsumerWidget {
  final String bookId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookProvider(bookId));
    final marketStats = ref.watch(bookMarketStatsProvider(bookId));
    final priceButtons = ref.watch(priceButtonConfigProvider);
    
    return Scaffold(
      body: Column(
        children: [
          // Book cover + metadata
          BookCoverCard(book: book),
          
          // Market stats
          if (marketStats.hasValue)
            MarketStatsCard(stats: marketStats.value!),
          
          // Quick price buttons
          Padding(
            padding: EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: priceButtons.map((config) {
                return ElevatedButton(
                  onPressed: () => _showProfitCalculation(
                    context,
                    ref,
                    purchasePrice: config.priceSek,
                    book: book,
                    stats: marketStats.value!,
                  ),
                  child: Text('${config.priceSek} kr'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showProfitCalculation(
    BuildContext context,
    WidgetRef ref,
    {required int purchasePrice, required Book book, required BookMarketStats stats}
  ) {
    final profit = ref.read(profitCalculatorProvider).calculateProfit(
      purchasePriceSek: purchasePrice,
      sellPriceSek: stats.averageSoldPriceSek,
      platform: 'tradera',
    );
    
    showModalBottomSheet(
      context: context,
      builder: (context) => ProfitCalculationSheet(
        book: book,
        profit: profit,
        onSave: () async {
          await ref.read(booksDao).updatePurchasePrice(
            bookId: book.id,
            priceSek: purchasePrice,
            saved: true,
          );
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onSkip: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

---

## Success Metrics

### Technical Metrics

- [ ] ISBN lookup < 2 seconds (95th percentile)
- [ ] Barcode scan to decision screen < 3 seconds
- [ ] Market data aggregation < 5 seconds
- [ ] Offline mode works for previously scanned books
- [ ] App size < 50 MB
- [ ] Crash-free rate > 99%

### Product Metrics

- [ ] User can scan and decide on a book in < 10 seconds
- [ ] 80% of ISBNs successfully looked up
- [ ] 60% of books have market data available
- [ ] Users save 30%+ of scanned books
- [ ] Average profit margin > 100%

### User Feedback

- [ ] "Much faster than manually searching each platform"
- [ ] "Helps me make quick decisions at flea markets"
- [ ] "Profit calculator is super useful"
- [ ] "Love the quick price buttons"

---

## Risks & Mitigations

### Risk 1: API Rate Limits

**Risk:** Google Books API has 1000 req/day limit (free tier)

**Mitigation:**
- Cache all ISBN lookups in local DB
- Implement exponential backoff
- Fallback to Open Library API
- Consider paid tier if needed ($0.50/1000 requests)

### Risk 2: Market Data Availability

**Risk:** Not all books have recent sales data

**Mitigation:**
- Show "No recent sales data" message
- Allow manual price entry
- Suggest checking other platforms manually
- Build up historical database over time

### Risk 3: Platform API Changes

**Risk:** Vinted/Bokbörsen may block scraping

**Mitigation:**
- Use official APIs where available
- Implement graceful degradation
- Focus on Tradera (official API via proxy)
- Add user-contributed data option

### Risk 4: ISBN Validation

**Risk:** Some books have invalid/missing ISBNs

**Mitigation:**
- Implement robust ISBN validation
- Support both ISBN-10 and ISBN-13
- Allow manual ISBN entry
- Support title/author search as fallback

---

## Future Enhancements (Post-MVP)

### Phase 2 Features

- [ ] Bulk scanning mode (scan multiple books quickly)
- [ ] Price history charts (track market trends)
- [ ] Selling platform integration (auto-list on Tradera)
- [ ] Inventory management (mark as sold, track profit)
- [ ] Barcode label printing (for pricing books)

### Phase 3 Features

- [ ] AI-powered book condition assessment (photo of book)
- [ ] Competitor analysis (what other sellers are listing)
- [ ] Seasonal trends (best time to sell certain genres)
- [ ] Multi-user support (for book store teams)
- [ ] Web dashboard (desktop inventory management)

---

## Conclusion

This refactoring transforms LoppisFynd from a general-purpose reseller app into a specialized book scanning tool. The core architecture remains solid (offline-first, Riverpod, Drift), but the domain shifts from "scan anything" to "scan books and make quick pricing decisions."

**Key Benefits:**
- ✅ Faster workflow (no AI processing, instant ISBN lookup)
- ✅ Better market data (multi-platform aggregation)
- ✅ Clearer value prop (profit calculator, quick decisions)
- ✅ Simpler UX (focused on books only)

**Estimated Effort:** 6-8 weeks for full refactoring and launch

**Next Steps:**
1. Review and approve this refactoring plan
2. Set up new project structure (or branch)
3. Begin Phase 1: Core Refactoring
4. Iterate based on user feedback

---

**Document Version:** 1.0  
**Created:** April 28, 2026  
**Author:** AI Architecture Assistant
