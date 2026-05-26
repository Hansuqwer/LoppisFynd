import '../market/tradera_proxy_models.dart';
import 'book_market_data_service.dart';

class TraderaBookMarketAdapter {
  const TraderaBookMarketAdapter({
    this.aggregator = const BookMarketDataAggregator(),
  });

  final BookMarketDataAggregator aggregator;

  List<BookSale> salesFromResponse(TraderaProxyResponse response) {
    final sales = <BookSale>[];
    for (final item in response.items) {
      final price = item.maxBid;
      final endDate = item.endDate;
      if (price == null || price <= 0) continue;
      if (endDate == null) continue;
      if (item.isEnded == false) continue;
      if (item.hasBids == false) continue;

      sales.add(
        BookSale(
          platform: 'tradera',
          priceSek: price,
          soldAt: endDate,
          listingUrl: item.itemLink,
        ),
      );
    }
    return sales;
  }

  BookMarketStats? statsFromResponse(
    TraderaProxyResponse response, {
    DateTime? now,
  }) {
    return aggregator.aggregate(salesFromResponse(response), now: now);
  }
}
