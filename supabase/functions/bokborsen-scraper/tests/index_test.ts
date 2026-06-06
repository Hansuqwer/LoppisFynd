import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { handleRequest, parseBokborsenHtml } from "../index.ts";

// ── Fixtures — confirmed HTML/JSON-LD structure from research 2025-06 ─────────

// JSON-LD Product blocks (schema.org — preferred path)
const FIXTURE_JSON_LD = `
<html><head>
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Pippi Långstrump har julgransplundring",
  "offers": {
    "@type": "Offer",
    "price": "66",
    "priceCurrency": "SEK",
    "url": "/view/Lindgren-Astrid/Pippi/15048593"
  }
}
</script>
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Book",
  "name": "Kris",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "SEK",
    "url": "/view/Boye-Karin/Kris/999"
  }
}
</script>
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Book",
  "name": "Doktor Glas",
  "offers": {
    "@type": "Offer",
    "price": "89",
    "priceCurrency": "SEK",
    "url": "/view/Soderberg/Doktor-Glas/555"
  }
}
</script>
</head></html>
`;

// Confirmed CSS selector HTML (research 2025-06)
const FIXTURE_CSS = `
<html><body>
<li class="group book single_image">
  <div class="single-product content item group">
    <div class="content-primary">
      <div class="header">
        <h2>
          <a href="/view/Lindgren-Astrid/Pippi/15048593">
            <span itemprop="name">Pippi Långstrump</span>
          </a>
        </h2>
      </div>
    </div>
    <div class="content-secondary">
      <button class="button buy" itemprop="price" content="66 SEK">
        <span class="price">66 SEK</span>
      </button>
    </div>
  </div>
</li>
<li class="group book single_image">
  <div class="single-product content item group">
    <div class="content-primary">
      <div class="header">
        <h2>
          <a href="/view/Boye/Kris/888">
            <span itemprop="name">Kris</span>
          </a>
        </h2>
      </div>
    </div>
    <div class="content-secondary">
      <button class="button buy">
        <span class="price">0 SEK</span>
      </button>
    </div>
  </div>
</li>
</body></html>
`;

const FIXTURE_EMPTY = `<html><body><p>Inga böcker hittades</p></body></html>`;

// ── Tests ─────────────────────────────────────────────────────────────────────

Deno.test("parseBokborsenHtml: extracts items from JSON-LD blocks", () => {
  const now = new Date("2025-06-06T10:00:00Z");
  const items = parseBokborsenHtml(FIXTURE_JSON_LD, 10, now);
  // price=0 filtered; 2 valid items
  assertEquals(items.length, 2);

  const first = items[0];
  assertEquals(first.platform, "bokborsen");
  assertEquals(first.price, 66);
  assertEquals(first.title, "Pippi Långstrump har julgransplundring");
  assertEquals(
    first.url,
    "https://www.bokborsen.se/view/Lindgren-Astrid/Pippi/15048593",
  );
  assertEquals(first.soldAt, now.toISOString());

  assertEquals(items[1].price, 89);
  assertEquals(items[1].title, "Doktor Glas");
});

Deno.test("parseBokborsenHtml: respects maxResults in JSON-LD path", () => {
  const items = parseBokborsenHtml(FIXTURE_JSON_LD, 1);
  assertEquals(items.length, 1);
});

Deno.test("parseBokborsenHtml: falls back to CSS selectors when no JSON-LD", () => {
  const now = new Date("2025-06-06T10:00:00Z");
  const items = parseBokborsenHtml(FIXTURE_CSS, 10, now);
  // price=0 filtered; 1 valid
  assertEquals(items.length, 1);
  assertEquals(items[0].price, 66);
  assertEquals(items[0].title, "Pippi Långstrump");
  assertEquals(
    items[0].url,
    "https://www.bokborsen.se/view/Lindgren-Astrid/Pippi/15048593",
  );
  assertEquals(items[0].soldAt, now.toISOString());
});

Deno.test("parseBokborsenHtml: returns empty for no-match HTML", () => {
  const items = parseBokborsenHtml(FIXTURE_EMPTY, 50);
  assertEquals(items.length, 0);
});

Deno.test("handleRequest: OPTIONS returns 204", async () => {
  const res = await handleRequest(
    new Request("http://x/", { method: "OPTIONS" }),
  );
  assertEquals(res.status, 204);
});

Deno.test("handleRequest: bad method returns 405", async () => {
  const res = await handleRequest(new Request("http://x/", { method: "GET" }));
  assertEquals(res.status, 405);
});

Deno.test("handleRequest: short query returns 400", async () => {
  const res = await handleRequest(
    new Request("http://x/", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "x" }),
    }),
  );
  assertEquals(res.status, 400);
});

Deno.test("handleRequest: returns items from mock fetch", async () => {
  const mockFetch: typeof fetch = (_url) =>
    Promise.resolve(new Response(FIXTURE_JSON_LD, { status: 200 }));

  const res = await handleRequest(
    new Request("http://x/", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "Pippi Långstrump" }),
    }),
    { fetch: mockFetch },
  );
  assertEquals(res.status, 200);
  const body = await res.json() as { items: unknown[]; source: string };
  assertEquals(body.source, "bokborsen");
  assertEquals((body.items as unknown[]).length, 2);
});

Deno.test("handleRequest: upstream error returns 502", async () => {
  const mockFetch: typeof fetch = (_url) =>
    Promise.resolve(new Response("error", { status: 503 }));

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
