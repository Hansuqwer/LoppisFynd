export type TraderaItemStatus =
  | "All"
  | "Active"
  | "Inactive"
  | string;

export type TraderaOrderBy =
  | "Relevance"
  | "PriceAscending"
  | "PriceDescending"
  | "EndDateAscending"
  | "EndDateDescending"
  | string;

export interface TraderaProxyRequest {
  searchWords: string;
  categoryId?: number;
  searchInDescription?: boolean;
  itemStatus?: TraderaItemStatus;
  orderBy?: TraderaOrderBy;
  itemsPerPage?: number;
  pageNumber?: number;
  onlyItemsWithThumbnail?: boolean;
}

export interface TraderaProxyItem {
  id: number;
  shortDescription: string;
  endDate: string | null;
  maxBid: number | null;
  buyItNowPrice: number | null;
  itemType:
    | "Auction"
    | "AuctionWithBuyItNow"
    | "PureBuyItNow"
    | "ShopItem"
    | null;
  totalBids: number | null;
  hasBids: boolean | null;
  isEnded: boolean | null;
  itemLink: string | null;
  thumbnailLink: string | null;
}

export interface TraderaProxyResponse {
  totalNumberOfItems: number | null;
  totalNumberOfPages: number | null;
  items: TraderaProxyItem[];
}

export interface TraderaProxyError {
  code: string;
  message: string;
  retryAfterSeconds?: number;
}

export interface TraderaProxyErrorResponse {
  error: TraderaProxyError;
}
