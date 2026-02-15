import { parseSearchAdvancedResponse } from "../parse.ts";

Deno.test("parseSearchAdvancedResponse parses items", async () => {
  const xml = await Deno.readTextFile(
    new URL("../fixtures/get_search_result_advanced_xml_response.xml", import.meta.url),
  );

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
});
