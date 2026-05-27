import { handleRequest } from "../index.ts";

Deno.test("OPTIONS returns 204 with CORS headers", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/vinted-scraper", { method: "OPTIONS" }),
  );

  if (resp.status !== 204) throw new Error(`expected 204, got ${resp.status}`);
  if (resp.headers.get("access-control-allow-origin") !== "*") {
    throw new Error("missing CORS origin header");
  }
});

Deno.test("GET returns 405 method not allowed", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/vinted-scraper", { method: "GET" }),
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
    new Request("http://localhost/vinted-scraper", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: "{",
    }),
    {
      env: {
        get: (k: string) => {
          if (k === "APIFY_API_TOKEN") return "test-token";
          if (k === "VINTED_SCRAPER_ACTOR_ID") return "test-actor";
          return undefined;
        },
      },
    },
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
    new Request("http://localhost/vinted-scraper", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "a" }),
    }),
    {
      env: {
        get: (k: string) => {
          if (k === "APIFY_API_TOKEN") return "test-token";
          if (k === "VINTED_SCRAPER_ACTOR_ID") return "test-actor";
          return undefined;
        },
      },
    },
  );

  if (resp.status !== 400) throw new Error(`expected 400, got ${resp.status}`);

  const body = await resp.json();
  const err = (body as Record<string, unknown>)["error"] as
    | Record<string, unknown>
    | undefined;
  if (!err) throw new Error("missing error object");
  if (err["code"] !== "invalid_request") throw new Error("wrong code");
});

Deno.test("missing env vars returns 500", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/vinted-scraper", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "test book" }),
    }),
    {
      env: { get: () => undefined },
    },
  );

  if (resp.status !== 500) throw new Error(`expected 500, got ${resp.status}`);

  const body = await resp.json();
  const err = (body as Record<string, unknown>)["error"] as
    | Record<string, unknown>
    | undefined;
  if (!err) throw new Error("missing error object");
  if (err["code"] !== "server_not_configured") throw new Error("wrong code");
});

Deno.test("Apify start failure returns 502", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/vinted-scraper", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "test book" }),
    }),
    {
      env: {
        get: (k: string) => {
          if (k === "APIFY_API_TOKEN") return "test-token";
          if (k === "VINTED_SCRAPER_ACTOR_ID") return "test-actor";
          return undefined;
        },
      },
      fetch: async () => new Response("Unauthorized", { status: 401 }),
    },
  );

  if (resp.status !== 502) throw new Error(`expected 502, got ${resp.status}`);

  const body = await resp.json();
  const err = (body as Record<string, unknown>)["error"] as
    | Record<string, unknown>
    | undefined;
  if (!err) throw new Error("missing error object");
  if (err["code"] !== "apify_start_failed") throw new Error("wrong code");
});

Deno.test("success path returns parsed items", async () => {
  let callCount = 0;
  const mockFetch = async (url: string | URL | Request) => {
    const urlStr = typeof url === "string" ? url : url.toString();
    callCount++;

    // First call: start Apify run
    if (urlStr.includes("/runs")) {
      return new Response(
        JSON.stringify({
          data: { id: "run-123", defaultDatasetId: "dataset-456" },
        }),
        { status: 200 },
      );
    }

    // Second call: check run status
    if (urlStr.includes("/actor-runs/")) {
      return new Response(
        JSON.stringify({ data: { status: "SUCCEEDED" } }),
        { status: 200 },
      );
    }

    // Third call: get dataset items
    if (urlStr.includes("/datasets/")) {
      return new Response(
        JSON.stringify([
          {
            id: "item-1",
            title: "Test Book",
            price: 150,
            currency: "SEK",
            url: "https://vinted.se/item/1",
            status: "sold",
            soldAt: "2024-01-15",
          },
          {
            id: "item-2",
            title: "Another Book",
            price: { amount: 200 },
            currency: "SEK",
            url: "https://vinted.se/item/2",
            status: "completed",
            sold_at: "2024-01-16",
          },
        ]),
        { status: 200 },
      );
    }

    throw new Error(`Unexpected URL: ${urlStr}`);
  };

  const resp = await handleRequest(
    new Request("http://localhost/vinted-scraper", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "test book", maxResults: 10 }),
    }),
    {
      env: {
        get: (k: string) => {
          if (k === "APIFY_API_TOKEN") return "test-token";
          if (k === "VINTED_SCRAPER_ACTOR_ID") return "test-actor";
          return undefined;
        },
      },
      fetch: mockFetch,
    },
  );

  if (resp.status !== 200) throw new Error(`expected 200, got ${resp.status}`);
  if (resp.headers.get("cache-control") !== "no-store") {
    throw new Error("missing cache-control: no-store");
  }

  const body = await resp.json();
  const root = body as Record<string, unknown>;
  if (root["source"] !== "vinted") throw new Error("wrong source");
  if (root["query"] !== "test book") throw new Error("wrong query");

  const items = root["items"] as Array<Record<string, unknown>>;
  if (!Array.isArray(items) || items.length !== 2) {
    throw new Error(`expected 2 items, got ${items?.length ?? 0}`);
  }

  if (items[0]["platform"] !== "vinted") throw new Error("wrong platform");
  if (items[0]["price"] !== 150) throw new Error("wrong price");
  if (items[0]["title"] !== "Test Book") throw new Error("wrong title");

  if (items[1]["price"] !== 200) throw new Error("wrong price for item 2");
});
