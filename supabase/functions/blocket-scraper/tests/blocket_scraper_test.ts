import {
  assertEquals,
  assertNotEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { BlocketItem, handleRequest, parseBlocketHtml } from "../index.ts";

// ── Fixtures ─────────────────────────────────────────────────────────────────

// Realistic JSON-LD block as seen in Blocket SSR HTML (research 2025-06)
const FIXTURE_JSON_LD = `
<html><head>
<script id="seoStructuredData" type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "CollectionPage",
  "mainEntity": {
    "@type": "ItemList",
    "itemListElement": [
      {
        "@type": "ListItem",
        "position": 1,
        "item": {
          "@type": "Product",
          "name": "Pippi Långstrump - Astrid Lindgren",
          "url": "https://www.blocket.se/recommerce/forsale/item/23745120",
          "offers": {
            "@type": "Offer",
            "price": 75,
            "priceCurrency": "SEK",
            "availability": "https://schema.org/InStock"
          }
        }
      },
      {
        "@type": "ListItem",
        "position": 2,
        "item": {
          "@type": "Product",
          "name": "Emil i Lönneberga",
          "url": "https://www.blocket.se/recommerce/forsale/item/23745121",
          "offers": {
            "@type": "Offer",
            "price": 0,
            "priceCurrency": "SEK",
            "availability": "https://schema.org/InStock"
          }
        }
      },
      {
        "@type": "ListItem",
        "position": 3,
        "item": {
          "@type": "Product",
          "name": "Kalle Blomkvist",
          "url": "https://www.blocket.se/recommerce/forsale/item/23745122",
          "offers": {
            "@type": "Offer",
            "price": 50,
            "priceCurrency": "SEK",
            "availability": "https://schema.org/InStock"
          }
        }
      }
    ]
  }
}
</script>
</head><body></body></html>
`;

// Fallback article HTML (when JSON-LD absent)
const FIXTURE_ARTICLE_HTML = `
<html><body>
<article class="relative isolate sf-search-ad card">
  <a class="sf-search-ad-link absolute inset-0"
     href="https://www.blocket.se/recommerce/forsale/item/99001"></a>
  <div class="m-8">
    <div class="flex justify-between sm:mt-8 text-m space-x-12 font-bold">
      <span>120 kr</span>
    </div>
    <h2 class="h4 mb-0">Doktor Glas</h2>
  </div>
</article>
<article class="relative isolate sf-search-ad card">
  <a class="sf-search-ad-link absolute inset-0"
     href="https://www.blocket.se/recommerce/forsale/item/99002"></a>
  <div class="m-8">
    <div class="flex justify-between sm:mt-8 text-m space-x-12 font-bold">
      <span>1 500 kr</span>
    </div>
    <h2 class="h4 mb-0">Samlade verk</h2>
  </div>
</article>
<article class="relative isolate sf-search-ad card">
  <a class="sf-search-ad-link absolute inset-0"
     href="https://www.blocket.se/recommerce/forsale/item/99003"></a>
  <div class="m-8">
    <!-- no price span → should be filtered out -->
    <h2 class="h4 mb-0">Okänd bok</h2>
  </div>
</article>
</body></html>
`;

const FIXTURE_EMPTY = `<html><body><p>Inga annonser</p></body></html>`;

// ── Unit tests ────────────────────────────────────────────────────────────────

Deno.test("parseBlocketHtml: extracts items from JSON-LD (primary path)", () => {
  const items = parseBlocketHtml(FIXTURE_JSON_LD, 10);
  // position 2 has price=0 → filtered; positions 1 and 3 pass
  assertEquals(items.length, 2);

  const first = items[0];
  assertEquals(first.platform, "blocket");
  assertEquals(first.price, 75);
  assertEquals(first.title, "Pippi Långstrump - Astrid Lindgren");
  assertEquals(
    first.url,
    "https://www.blocket.se/recommerce/forsale/item/23745120",
  );
  assertEquals(first.soldAt, null);

  const second = items[1];
  assertEquals(second.price, 50);
  assertEquals(second.title, "Kalle Blomkvist");
});

Deno.test("parseBlocketHtml: respects maxResults cap on JSON-LD", () => {
  const items = parseBlocketHtml(FIXTURE_JSON_LD, 1);
  assertEquals(items.length, 1);
});

Deno.test("parseBlocketHtml: falls back to article HTML when no JSON-LD", () => {
  const items = parseBlocketHtml(FIXTURE_ARTICLE_HTML, 10);
  assertEquals(items.length, 2); // 3 articles, 1 has no price

  assertEquals(items[0].price, 120);
  assertEquals(items[0].title, "Doktor Glas");
  assertEquals(
    items[0].url,
    "https://www.blocket.se/recommerce/forsale/item/99001",
  );
  assertEquals(items[0].soldAt, null);

  // "1 500 kr" → 1500
  assertEquals(items[1].price, 1500);
  assertEquals(items[1].title, "Samlade verk");
});

Deno.test("parseBlocketHtml: returns empty for no-match page", () => {
  const items = parseBlocketHtml(FIXTURE_EMPTY, 50);
  assertEquals(items.length, 0);
});

Deno.test("handleRequest: OPTIONS returns 204", async () => {
  const res = await handleRequest(
    new Request("http://x/", { method: "OPTIONS" }),
  );
  assertEquals(res.status, 204);
});

Deno.test("handleRequest: GET returns 405", async () => {
  const res = await handleRequest(new Request("http://x/", { method: "GET" }));
  assertEquals(res.status, 405);
});

Deno.test("handleRequest: 1-char query returns 400", async () => {
  const res = await handleRequest(
    new Request("http://x/", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "a" }),
    }),
  );
  assertEquals(res.status, 400);
});

Deno.test("handleRequest: returns items via mock fetch", async () => {
  const mockFetch: typeof fetch = (_url) =>
    Promise.resolve(new Response(FIXTURE_JSON_LD, { status: 200 }));

  const res = await handleRequest(
    new Request("http://x/", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "Pippi Långstrump", maxResults: 10 }),
    }),
    { fetch: mockFetch },
  );

  assertEquals(res.status, 200);
  const body = await res.json() as { items: BlocketItem[]; source: string };
  assertEquals(body.source, "blocket");
  assertEquals(body.items.length, 2);
});

Deno.test("handleRequest: upstream 500 returns 502", async () => {
  const mockFetch: typeof fetch = (_url) =>
    Promise.resolve(new Response("", { status: 500 }));

  const res = await handleRequest(
    new Request("http://x/", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "Pippi" }),
    }),
    { fetch: mockFetch },
  );
  assertEquals(res.status, 502);
});
