enum TraderaItemType {
  auction,
  auctionWithBuyItNow,
  pureBuyItNow,
  shopItem,
  unknown,
}

class TraderaProxyResponse {
  const TraderaProxyResponse({
    required this.totalNumberOfItems,
    required this.totalNumberOfPages,
    required this.items,
  });

  final int? totalNumberOfItems;
  final int? totalNumberOfPages;
  final List<TraderaProxyItem> items;

  factory TraderaProxyResponse.fromJson(Map<String, Object?> json) {
    return TraderaProxyResponse(
      totalNumberOfItems: _readNullableInt(json['totalNumberOfItems']),
      totalNumberOfPages: _readNullableInt(json['totalNumberOfPages']),
      items: _readList(json['items']).map(TraderaProxyItem.fromJson).toList(),
    );
  }
}

class TraderaProxyItem {
  const TraderaProxyItem({
    required this.id,
    required this.shortDescription,
    required this.endDate,
    required this.maxBid,
    required this.buyItNowPrice,
    required this.itemType,
    required this.totalBids,
    required this.hasBids,
    required this.isEnded,
    required this.itemLink,
    required this.thumbnailLink,
  });

  final int id;
  final String shortDescription;
  final DateTime? endDate;
  final int? maxBid;
  final int? buyItNowPrice;
  final TraderaItemType itemType;
  final int? totalBids;
  final bool? hasBids;
  final bool? isEnded;
  final String? itemLink;
  final String? thumbnailLink;

  factory TraderaProxyItem.fromJson(Object? value) {
    if (value is! Map) {
      throw const FormatException('TraderaProxyItem must be an object');
    }
    final json = value.cast<String, Object?>();

    final id = _readInt(json['id']);
    final shortDescription = _readString(json['shortDescription']);
    final endDate = _readNullableDateTime(json['endDate']);
    final maxBid = _readNullableInt(json['maxBid']);
    final buyItNowPrice = _readNullableInt(json['buyItNowPrice']);
    final itemType = _readItemType(json['itemType']);
    final totalBids = _readNullableInt(json['totalBids']);
    final hasBids = _readNullableBool(json['hasBids']);
    final isEnded = _readNullableBool(json['isEnded']);
    final itemLink = _readNullableString(json['itemLink']);
    final thumbnailLink = _readNullableString(json['thumbnailLink']);

    return TraderaProxyItem(
      id: id,
      shortDescription: shortDescription,
      endDate: endDate,
      maxBid: maxBid,
      buyItNowPrice: buyItNowPrice,
      itemType: itemType,
      totalBids: totalBids,
      hasBids: hasBids,
      isEnded: isEnded,
      itemLink: itemLink,
      thumbnailLink: thumbnailLink,
    );
  }
}

TraderaItemType _readItemType(Object? value) {
  if (value is! String) return TraderaItemType.unknown;
  return switch (value) {
    'Auction' => TraderaItemType.auction,
    'AuctionWithBuyItNow' => TraderaItemType.auctionWithBuyItNow,
    'PureBuyItNow' => TraderaItemType.pureBuyItNow,
    'ShopItem' => TraderaItemType.shopItem,
    _ => TraderaItemType.unknown,
  };
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw const FormatException('Expected int');
}

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

String _readString(Object? value) {
  if (value is String) return value;
  throw const FormatException('Expected string');
}

String? _readNullableString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  return null;
}

bool? _readNullableBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  return null;
}

DateTime? _readNullableDateTime(Object? value) {
  if (value == null) return null;
  if (value is! String) return null;
  return DateTime.tryParse(value);
}

List<Object?> _readList(Object? value) {
  if (value is List) return value.cast<Object?>();
  throw const FormatException('Expected list');
}
