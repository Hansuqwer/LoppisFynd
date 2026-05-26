import type { TraderaProxyItem, TraderaProxyResponse } from "./types.ts";

export function parseSearchAdvancedResponse(soapXml: string): TraderaProxyResponse {
  if (soapXml.includes("<Fault") || soapXml.includes(":Fault")) {
    throw new Error("SOAP Fault");
  }

  const resultXml = extractTag(soapXml, "SearchAdvancedResult") ?? soapXml;

  const totalNumberOfItems = parseNullableInt(
    extractTag(resultXml, "TotalNumberOfItems"),
  );
  const totalNumberOfPages = parseNullableInt(
    extractTag(resultXml, "TotalNumberOfPages"),
  );

  const itemsXml = extractAllTags(resultXml, "Items");
  const items = itemsXml
    .map(parseItem)
    .filter((x): x is TraderaProxyItem => x != null);

  return {
    totalNumberOfItems,
    totalNumberOfPages,
    items,
  };
}

function parseItem(itemXml: string): TraderaProxyItem | null {
  const id = parseNullableInt(extractTag(itemXml, "Id"));
  if (id == null) return null;

  const shortDescription = (extractTag(itemXml, "ShortDescription") ?? "").trim();
  const endDate = (extractTag(itemXml, "EndDate") ?? "").trim() || null;

  const maxBid = parseNullableInt(extractTag(itemXml, "MaxBid"));
  const totalBids =
    parseNullableInt(extractTag(itemXml, "BidCount")) ??
    parseNullableInt(extractTag(itemXml, "TotalBids"));

  const hasBids = parseNullableBool(extractTag(itemXml, "HasBids"));
  const isEnded = parseNullableBool(extractTag(itemXml, "IsEnded"));

  const itemLink =
    (extractTag(itemXml, "ItemUrl") ?? extractTag(itemXml, "ItemLink") ?? "")
      .trim() || null;

  const thumbnailLink = (extractTag(itemXml, "ThumbnailLink") ?? "").trim() || null;

  return {
    id,
    shortDescription,
    endDate,
    maxBid,
    totalBids,
    hasBids,
    isEnded,
    itemLink,
    thumbnailLink,
  };
}

function extractTag(xml: string, tagName: string): string | null {
  const re = new RegExp(
    `<${tagName}(\\s[^>]*)?>([\\s\\S]*?)</${tagName}>`,
    "i",
  );
  const match = xml.match(re);
  return match?.[2] ?? null;
}

function extractAllTags(xml: string, tagName: string): string[] {
  const re = new RegExp(
    `<${tagName}(\\s[^>]*)?>([\\s\\S]*?)</${tagName}>`,
    "gi",
  );
  const out: string[] = [];
  for (const match of xml.matchAll(re)) {
    out.push(match[2] ?? "");
  }
  return out;
}

function parseNullableInt(text: string | null): number | null {
  if (text == null) return null;
  const trimmed = text.trim();
  if (!trimmed) return null;
  const v = Number.parseInt(trimmed, 10);
  return Number.isFinite(v) ? v : null;
}

function parseNullableBool(text: string | null): boolean | null {
  if (text == null) return null;
  const trimmed = text.trim().toLowerCase();
  if (trimmed === "true") return true;
  if (trimmed === "false") return false;
  return null;
}
