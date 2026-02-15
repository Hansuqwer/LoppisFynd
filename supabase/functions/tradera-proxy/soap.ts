import type { TraderaProxyRequest } from "./types.ts";

export function buildSearchAdvancedRequestXml(req: TraderaProxyRequest): string {
  const searchWords = escapeXml(req.searchWords);

  const categoryId = req.categoryId ?? 0;
  const searchInDescription = req.searchInDescription ?? false;
  const itemStatus = req.itemStatus ?? "Ended";
  const orderBy = req.orderBy ?? "EndDateDescending";
  const onlyItemsWithThumbnail = req.onlyItemsWithThumbnail ?? true;

  const itemsPerPage = clampInt(req.itemsPerPage ?? 50, 1, 200);
  const pageNumber = clampInt(req.pageNumber ?? 1, 1, 1000);

  return (
    `<SearchWords>${searchWords}</SearchWords>` +
    `<CategoryId>${categoryId}</CategoryId>` +
    `<SearchInDescription>${searchInDescription}</SearchInDescription>` +
    `<Mode>And</Mode>` +
    `<BidsMinimum>1</BidsMinimum>` +
    `<OrderBy>${escapeXml(orderBy)}</OrderBy>` +
    `<ItemStatus>${escapeXml(itemStatus)}</ItemStatus>` +
    `<ItemType>All</ItemType>` +
    `<OnlyAuctionsWithBuyNow>false</OnlyAuctionsWithBuyNow>` +
    `<OnlyItemsWithThumbnail>${onlyItemsWithThumbnail}</OnlyItemsWithThumbnail>` +
    `<ItemsPerPage>${itemsPerPage}</ItemsPerPage>` +
    `<PageNumber>${pageNumber}</PageNumber>` +
    `<ItemCondition>All</ItemCondition>` +
    `<SellerType>All</SellerType>`
  );
}

export function buildSearchAdvancedEnvelope(params: {
  appId: number;
  appKey: string;
  sandbox: number;
  maxResultAge: number;
  requestXml: string;
}): string {
  return `<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Header>
    <AuthenticationHeader xmlns="http://api.tradera.com">
      <AppId>${params.appId}</AppId>
      <AppKey>${escapeXml(params.appKey)}</AppKey>
    </AuthenticationHeader>
    <ConfigurationHeader xmlns="http://api.tradera.com">
      <Sandbox>${params.sandbox}</Sandbox>
      <MaxResultAge>${params.maxResultAge}</MaxResultAge>
    </ConfigurationHeader>
  </soap:Header>
  <soap:Body>
    <SearchAdvanced xmlns="http://api.tradera.com">
      <request>${params.requestXml}</request>
    </SearchAdvanced>
  </soap:Body>
</soap:Envelope>`;
}

export function escapeXml(input: string): string {
  return input
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&apos;");
}

function clampInt(value: number, min: number, max: number): number {
  if (!Number.isFinite(value)) return min;
  const v = Math.trunc(value);
  return Math.min(max, Math.max(min, v));
}
