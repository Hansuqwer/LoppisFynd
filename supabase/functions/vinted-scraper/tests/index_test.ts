import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { handleRequest } from "../index.ts";

function jsonResponse(data: unknown, init: ResponseInit = {}) {
  return new Response(JSON.stringify(data), {
    status: init.status ?? 200,
    headers: { "content-type": "application/json", ...(init.headers ?? {}) },
  });
}

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

Deno.test("handleRequest: invalid query returns 400", async () => {
  const res = await handleRequest(
    new Request("http://x/", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "x" }),
    }),
  );
  assertEquals(res.status, 400);
});

Deno.test("handleRequest: direct API parses active and sold items", async () => {
  const mockFetch = (input: RequestInfo | URL) => {
    const url = String(input);
    if (url.includes("/catalog?")) {
      return Promise.resolve(
        new Response("<html>ok</html>", {
          status: 200,
          headers: {
            "set-cookie": "access_token_web=jwt123; Path=/; Max-Age=604800",
          },
        }),
      );
    }
    if (url.includes("/api/v2/catalog/items")) {
      return Promise.resolve(jsonResponse({
        items: [
          {
            id: 1,
            title: "Pippi Långstrump",
            price: { amount: "120.0", currency_code: "SEK" },
            path: "/items/1-pippi-langstrump",
            sold_at: 1717400000,
          },
          {
            id: 2,
            title: "Doktor Glas",
            price: { amount: "80.5", currency_code: "SEK" },
            url: "https://www.vinted.se/items/2-doktor-glas",
            sold_at: null,
          },
          { id: 3, title: "Bad", price: { amount: "0" } },
        ],
      }));
    }
    return Promise.resolve(new Response("not found", { status: 404 }));
  };

  const res = await handleRequest(
    new Request("http://x/", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "pippi", maxResults: 50 }),
    }),
    { fetch: mockFetch },
  );

  assertEquals(res.status, 200);
  const body = await res.json() as {
    items: Array<Record<string, unknown>>;
    source: string;
  };
  assertEquals(body.source, "vinted");
  assertEquals(body.items.length, 2);
  assertEquals(body.items[0].price, 120);
  assertEquals(body.items[0].soldAt, "2024-06-03T07:33:20.000Z");
  assertEquals(
    body.items[0].url,
    "https://www.vinted.se/items/1-pippi-langstrump",
  );
  assertEquals(body.items[1].price, 81);
  assertEquals(body.items[1].soldAt, null);
});

Deno.test("handleRequest: soldOnly filters by sold_at but can fallback through status candidates", async () => {
  let apiCalls = 0;
  const mockFetch = (input: RequestInfo | URL) => {
    const url = String(input);
    if (url.includes("/catalog?")) {
      return Promise.resolve(
        new Response("<html>ok</html>", {
          status: 200,
          headers: { "set-cookie": "access_token_web=jwt123; Path=/" },
        }),
      );
    }
    if (url.includes("/api/v2/catalog/items")) {
      apiCalls += 1;
      return Promise.resolve(jsonResponse({
        items: apiCalls === 1
          ? [{ id: 1, title: "active", price: { amount: "10" }, sold_at: null }]
          : [{
            id: 2,
            title: "sold",
            price: { amount: "20" },
            sold_at: "2025-01-01T00:00:00Z",
          }],
      }));
    }
    return Promise.resolve(new Response("not found", { status: 404 }));
  };

  const res = await handleRequest(
    new Request("http://x/", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "pippi", soldOnly: true }),
    }),
    { fetch: mockFetch },
  );

  assertEquals(res.status, 200);
  const body = await res.json() as { items: Array<Record<string, unknown>> };
  assertEquals(body.items.length, 1);
  assertEquals(body.items[0].title, "sold");
});

Deno.test("handleRequest: bot challenge with no Apify config returns 502", async () => {
  const mockFetch = (input: RequestInfo | URL) => {
    const url = String(input);
    if (url.includes("/catalog?")) {
      return Promise.resolve(new Response("DataDome captcha", { status: 200 }));
    }
    return Promise.resolve(new Response("not found", { status: 404 }));
  };

  const res = await handleRequest(
    new Request("http://x/", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "pippi" }),
    }),
    { fetch: mockFetch, env: { get: () => undefined } },
  );

  assertEquals(res.status, 502);
});
