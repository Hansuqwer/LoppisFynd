import { handleRequest } from "../index.ts";

Deno.test("OPTIONS returns 204 with CORS headers", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/bokborsen-scraper", { method: "OPTIONS" }),
  );

  if (resp.status !== 204) throw new Error(`expected 204, got ${resp.status}`);
  if (resp.headers.get("access-control-allow-origin") !== "*") {
    throw new Error("missing CORS origin header");
  }
});

Deno.test("GET returns 405 method not allowed", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/bokborsen-scraper", { method: "GET" }),
  );

  if (resp.status !== 405) throw new Error(`expected 405, got ${resp.status}`);
  if (resp.headers.get("cache-control") !== "no-store") {
    throw new Error("missing cache-control: no-store");
  }

  const body = await resp.json();
  const err = (body as Record<string, unknown>)["error"] as
    | Record<string, unknown>
    | undefined;
  if (!err) throw new Error("missing error object");
  if (err["code"] !== "method_not_allowed") throw new Error("wrong code");
});

Deno.test("invalid JSON returns 400", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/bokborsen-scraper", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: "{",
    }),
  );

  if (resp.status !== 400) throw new Error(`expected 400, got ${resp.status}`);

  const body = await resp.json();
  const err = (body as Record<string, unknown>)["error"] as
    | Record<string, unknown>
    | undefined;
  if (!err) throw new Error("missing error object");
  if (err["code"] !== "invalid_json") throw new Error("wrong code");
});

Deno.test("query too short returns 400", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/bokborsen-scraper", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "a" }),
    }),
  );

  if (resp.status !== 400) throw new Error(`expected 400, got ${resp.status}`);

  const body = await resp.json();
  const err = (body as Record<string, unknown>)["error"] as
    | Record<string, unknown>
    | undefined;
  if (!err) throw new Error("missing error object");
  if (err["code"] !== "invalid_request") throw new Error("wrong code");
});

Deno.test("fetch failure returns 502", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/bokborsen-scraper", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "test book" }),
    }),
    {
      fetch: async () => new Response("Server Error", { status: 500 }),
    },
  );

  if (resp.status !== 502) throw new Error(`expected 502, got ${resp.status}`);

  const body = await resp.json();
  const err = (body as Record<string, unknown>)["error"] as
    | Record<string, unknown>
    | undefined;
  if (!err) throw new Error("missing error object");
  if (err["code"] !== "fetch_failed") throw new Error("wrong code");
});

Deno.test("success path parses HTML and returns items", async () => {
  const mockHtml = `
    <html>
      <body>
        <div class="listing-item">
          <div class="listing-content">
            <h3 class="listing-title">Pippi Långstrump</h3>
            <a href="/book/123">View</a>
            <span class="price">150 kr</span>
            <span class="date">2024-01-15</span>
          </div>
        </div>
        <div class="listing-item">
          <div class="listing-content">
            <h3 class="listing-title">Emil i Lönneberga</h3>
            <a href="/book/456">View</a>
            <span class="price">200 SEK</span>
            <span class="date">2024-01-16</span>
          </div>
        </div>
      </body>
    </html>
  `;

  const resp = await handleRequest(
    new Request("http://localhost/bokborsen-scraper", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "test book", maxResults: 10 }),
    }),
    {
      fetch: async () => new Response(mockHtml, { status: 200 }),
    },
  );

  if (resp.status !== 200) throw new Error(`expected 200, got ${resp.status}`);
  if (resp.headers.get("cache-control") !== "no-store") {
    throw new Error("missing cache-control: no-store");
  }

  const body = await resp.json();
  const root = body as Record<string, unknown>;
  if (root["source"] !== "bokborsen") throw new Error("wrong source");
  if (root["query"] !== "test book") throw new Error("wrong query");

  const items = root["items"] as Array<Record<string, unknown>>;
  if (!Array.isArray(items) || items.length !== 2) {
    throw new Error(`expected 2 items, got ${items?.length ?? 0}`);
  }

  if (items[0]["platform"] !== "bokborsen") throw new Error("wrong platform");
  if (items[0]["price"] !== 150) throw new Error("wrong price");
  if (items[0]["title"] !== "Pippi Långstrump") throw new Error("wrong title");
  if (items[0]["soldAt"] !== "2024-01-15") throw new Error("wrong date");

  if (items[1]["price"] !== 200) throw new Error("wrong price for item 2");
  if (items[1]["title"] !== "Emil i Lönneberga") throw new Error("wrong title for item 2");
});

Deno.test("empty HTML returns empty items array", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/bokborsen-scraper", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "test book" }),
    }),
    {
      fetch: async () => new Response("<html><body></body></html>", { status: 200 }),
    },
  );

  if (resp.status !== 200) throw new Error(`expected 200, got ${resp.status}`);

  const body = await resp.json();
  const root = body as Record<string, unknown>;
  const items = root["items"] as Array<unknown>;
  if (!Array.isArray(items) || items.length !== 0) {
    throw new Error(`expected 0 items, got ${items?.length ?? 0}`);
  }
});
