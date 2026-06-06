import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { handleRequest, parseAdlibrisHtml } from "../index.ts";

// ── Fixture HTML (representative Adlibris product-card markup) ──────────────

const FIXTURE_SINGLE_ARTICLE = `
<html><body>
<article class="product-item used-item">
  <a href="/se/bok/pippi-langstrump/p123456">
    <span itemprop="name">Pippi Långstrump</span>
  </a>
  <span class="price">89 kr</span>
  <span class="condition">Bra skick</span>
</article>
<article class="product-item used-item">
  <a href="/se/bok/pippi-nya/p789">
    <span itemprop="name">Pippi i Söderhavet</span>
  </a>
  <span class="price">0 kr</span>
</article>
<article class="product-item used-item">
  <a href="/se/bok/kris-karin-boye/p555">
    <span itemprop="name">Kris</span>
  </a>
  <span itemprop="price" content="220"></span>
  <span class="condition">Gott skick</span>
</article>
</body></html>
`;

const FIXTURE_EMPTY =
  `<html><body><p>Inga resultat hittades.</p></body></html>`;

const FIXTURE_JSON_LD = `
<html><body>
<script type="application/ld+json">
{
  "@type": "Product",
  "name": "Doktor Glas",
  "offers": { "price": 145, "url": "https://www.adlibris.com/se/bok/doktor-glas/p999" }
}
</script>
</body></html>
`;

// ── Tests ────────────────────────────────────────────────────────────────────

Deno.test("parseAdlibrisHtml: extracts items from article blocks", () => {
  const items = parseAdlibrisHtml(FIXTURE_SINGLE_ARTICLE, 10);
  // 3 articles, but price=0 is filtered out → 2 items
  assertEquals(items.length, 2);

  const first = items[0];
  assertEquals(first.platform, "adlibris");
  assertEquals(first.price, 89);
  assertEquals(first.title, "Pippi Långstrump");
  assertEquals(
    first.url,
    "https://www.adlibris.com/se/bok/pippi-langstrump/p123456",
  );
  assertEquals(first.condition, "Bra skick");
  assertEquals(first.soldAt, null);

  const second = items[1];
  assertEquals(second.price, 220);
  assertEquals(second.title, "Kris");
  assertEquals(second.condition, "Gott skick");
});

Deno.test("parseAdlibrisHtml: respects maxResults cap", () => {
  const items = parseAdlibrisHtml(FIXTURE_SINGLE_ARTICLE, 1);
  assertEquals(items.length, 1);
});

Deno.test("parseAdlibrisHtml: returns empty for no matches", () => {
  const items = parseAdlibrisHtml(FIXTURE_EMPTY, 50);
  assertEquals(items.length, 0);
});

Deno.test("parseAdlibrisHtml: falls back to JSON-LD when no article blocks", () => {
  const items = parseAdlibrisHtml(FIXTURE_JSON_LD, 10);
  assertEquals(items.length, 1);
  assertEquals(items[0].price, 145);
  assertEquals(items[0].title, "Doktor Glas");
  assertEquals(items[0].soldAt, null);
});

Deno.test("handleRequest: OPTIONS returns 204", async () => {
  const req = new Request("http://localhost/", { method: "OPTIONS" });
  const res = await handleRequest(req);
  assertEquals(res.status, 204);
});

Deno.test("handleRequest: non-POST returns 405", async () => {
  const req = new Request("http://localhost/", { method: "GET" });
  const res = await handleRequest(req);
  assertEquals(res.status, 405);
});

Deno.test("handleRequest: short query returns 400", async () => {
  const req = new Request("http://localhost/", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ query: "a" }),
  });
  const res = await handleRequest(req);
  assertEquals(res.status, 400);
});

Deno.test("handleRequest: returns items from mocked fetch", async () => {
  const mockFetch: typeof fetch = (_url) =>
    Promise.resolve(
      new Response(FIXTURE_SINGLE_ARTICLE, { status: 200 }),
    );

  const req = new Request("http://localhost/", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ query: "Pippi Långstrump", maxResults: 10 }),
  });

  const res = await handleRequest(req, { fetch: mockFetch });
  assertEquals(res.status, 200);

  const body = (await res.json()) as {
    items: unknown[];
    source: string;
    query: string;
  };
  assertEquals(body.source, "adlibris");
  assertEquals(body.query, "Pippi Långstrump");
  assertEquals((body.items as unknown[]).length, 2);
});

Deno.test("handleRequest: upstream 503 returns 502", async () => {
  const mockFetch: typeof fetch = (_url) =>
    Promise.resolve(new Response("", { status: 503 }));

  const req = new Request("http://localhost/", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ query: "Astrid Lindgren" }),
  });

  const res = await handleRequest(req, { fetch: mockFetch });
  assertEquals(res.status, 502);
});

Deno.test("handleRequest: anti-bot checkpoint returns explicit code", async () => {
  const mockFetch: typeof fetch = (_url) =>
    Promise.resolve(
      new Response("<title>Vercel Security Checkpoint</title>", {
        status: 429,
      }),
    );

  const req = new Request("http://localhost/", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ query: "Astrid Lindgren" }),
  });

  const res = await handleRequest(req, { fetch: mockFetch });
  assertEquals(res.status, 502);
  const body = await res.json() as { error: { code: string } };
  assertEquals(body.error.code, "bot_challenge");
});
