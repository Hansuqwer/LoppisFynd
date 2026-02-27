import { parseSearchAdvancedResponse } from "../parse.ts";

const kSoapFixture =
  `<SearchAdvancedResponse><SearchAdvancedResult><TotalNumberOfItems>2</TotalNumberOfItems><TotalNumberOfPages>1</TotalNumberOfPages><Items><Id>1001</Id><ShortDescription>Rorstrand plate</ShortDescription><EndDate>2026-02-16T20:00:00</EndDate><MaxBid>245</MaxBid><BuyItNowPrice>299</BuyItNowPrice><ItemType>AuctionWithBuyItNow</ItemType><BidCount>3</BidCount><HasBids>true</HasBids><IsEnded>true</IsEnded><ItemUrl>https://tradera.example/item/1001</ItemUrl><ThumbnailLink>https://tradera.example/thumb/1001.jpg</ThumbnailLink></Items><Items><Id>1002</Id><ShortDescription>Mon amie plate</ShortDescription><EndDate>2026-02-16T21:00:00</EndDate><MaxBid>130</MaxBid><BuyItNowPrice></BuyItNowPrice><ItemType>Auction</ItemType><BidCount>2</BidCount><HasBids>true</HasBids><IsEnded>true</IsEnded><ItemUrl>https://tradera.example/item/1002</ItemUrl><ThumbnailLink>https://tradera.example/thumb/1002.jpg</ThumbnailLink></Items></SearchAdvancedResult></SearchAdvancedResponse>`;

Deno.test("parseSearchAdvancedResponse parses items", () => {
  const xml = kSoapFixture;

  const parsed = parseSearchAdvancedResponse(xml);

  if (parsed.totalNumberOfItems !== 2) {
    throw new Error("Expected totalNumberOfItems=2");
  }
  if (parsed.items.length !== 2) {
    throw new Error("Expected 2 items");
  }

  const first = parsed.items[0];
  if (first.id !== 1001) throw new Error("Expected id=1001");
  if (first.hasBids !== true) throw new Error("Expected hasBids=true");
  if (first.maxBid !== 245) throw new Error("Expected maxBid=245");
  if (first.buyItNowPrice !== 299) {
    throw new Error("Expected buyItNowPrice=299");
  }
  if (first.itemType !== "AuctionWithBuyItNow") {
    throw new Error("Expected itemType=AuctionWithBuyItNow");
  }
});
