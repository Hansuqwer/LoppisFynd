import { handleRequest } from "../index.ts";

Deno.test("OPTIONS returns 204 with CORS headers", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/book-market-aggregator", { method: "OPTIONS" }),
  );

  if (resp.status !== 204) throw new Error(`expected 204, got ${resp.status}`);
  if (resp.headers.get("access-control-allow-origin") !== "*") {
    throw new Error("missing CORS origin header");
  }
});

Deno.test("GET returns 405 method not allowed", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/book-market-aggregator", { method: "GET" }),
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
    new Request("http://localhost/book-market-aggregator", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: "{",
    }),
    {
      env: {
        get: (k: string) => {
          if (k === "SUPABASE_URL") return "https://test.supabase.co";
          if (k === "SUPABASE_SERVICE_ROLE_KEY") return "test-key";
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
    new Request("http://localhost/book-market-aggregator", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "a" }),
    }),
    {
      env: {
        get: (k: string) => {
          if (k === "SUPABASE_URL") return "https://test.supabase.co";
          if (k === "SUPABASE_SERVICE_ROLE_KEY") return "test-key";
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
    new Request("http://localhost/book-market-aggregator", {
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

Deno.test("success path aggregates results from all sources", async () => {
  const mockFetch = async (url: string | URL | Request) => {
    const urlStr = typeof url === "string" ? url : url.toString();

    // Mock tradera-proxy response
    if (urlStr.includes("/tradera-proxy")) {
      return new Response(
        JSON.stringify({
          items: [
            {
              maxBid: 100,
              isEnded: true,
              hasBids: true,
              endDate: "2024-01-15T10:00:00Z",
              itemLink: "https://tradera.com/item/1",
              title: "Tradera Book",
            },
          ],
        }),
        { status: 200 },
      );
    }

    // Mock vinted-scraper response
    if (urlStr.includes("/vinted-scraper")) {
      return new Response(
        JSON.stringify({
          items: [
            {
              platform: "vinted",
              price: 150,
              soldAt: "2024-01-16",
              url: "https://vinted.se/item/1",
              title: "Vinted Book",
            },
          ],
        }),
        { status: 200 },
      );
    }

    // Mock bokborsen-scraper response
    if (urlStr.includes("/bokborsen-scraper")) {
      return new Response(
        JSON.stringify({
          items: [
            {
              platform: "bokborsen",
              price: 200,
              soldAt: "2024-01-17",
              url: "https://bokborsen.se/book/1",
              title: "Bokbörsen Book",
            },
          ],
        }),
        { status: 200 },
      );
    }

    throw new Error(`Unexpected URL: ${urlStr}`);
  };

  const resp = await handleRequest(
    new Request("http://localhost/book-market-aggregator", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "test book", isbn: "9780123456789" }),
    }),
    {
      env: {
        get: (k: string) => {
          if (k === "SUPABASE_URL") return "https://test.supabase.co";
          if (k === "SUPABASE_SERVICE_ROLE_KEY") return "test-key";
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

  if (root["query"] !== "test book") throw new Error("wrong query");
  if (root["isbn"] !== "9780123456789") throw new Error("wrong isbn");

  const items = root["items"] as Array<Record<string, unknown>>;
  if (!Array.isArray(items) || items.length !== 3) {
    throw new Error(`expected 3 items, got ${items?.length ?? 0}`);
  }

  // Check stats
  const stats = root["stats"] as Record<string, unknown>;
  if (!stats) throw new Error("missing stats");
  if (stats["lowestPrice"] !== 100) throw new Error("wrong lowest price");
  if (stats["highestPrice"] !== 200) throw new Error("wrong highest price");
  if (stats["averagePrice"] !== 150) throw new Error("wrong average price");
  if (stats["totalSales"] !== 3) throw new Error("wrong total sales");

  const sourceCounts = stats["sourceCounts"] as Record<string, number>;
  if (sourceCounts["tradera"] !== 1) throw new Error("wrong tradera count");
  if (sourceCounts["vinted"] !== 1) throw new Error("wrong vinted count");
  if (sourceCounts["bokborsen"] !== 1) throw new Error("wrong bokborsen count");

  // Check sources array
  const sources = root["sources"] as Array<Record<string, unknown>>;
  if (!Array.isArray(sources) || sources.length !== 3) {
    throw new Error(`expected 3 sources, got ${sources?.length ?? 0}`);
  }
});

Deno.test("handles partial source failures gracefully", async () => {
  const mockFetch = async (url: string | URL | Request) => {
    const urlStr = typeof url === "string" ? url : url.toString();

    // Mock tradera-proxy success
    if (urlStr.includes("/tradera-proxy")) {
      return new Response(
        JSON.stringify({
          items: [
            {
              maxBid: 100,
              isEnded: true,
              hasBids: true,
              endDate: "2024-01-15T10:00:00Z",
              itemLink: "https://tradera.com/item/1",
              title: "Tradera Book",
            },
          ],
        }),
        { status: 200 },
      );
    }

    // Mock vinted-scraper failure
    if (urlStr.includes("/vinted-scraper")) {
      return new Response("Internal Server Error", { status: 500 });
    }

    // Mock bokborsen-scraper success
    if (urlStr.includes("/bokborsen-scraper")) {
      return new Response(
        JSON.stringify({
          items: [
            {
              platform: "bokborsen",
              price: 200,
              soldAt: "2024-01-17",
              url: "https://bokborsen.se/book/1",
              title: "Bokbörsen Book",
            },
          ],
        }),
        { status: 200 },
      );
    }

    throw new Error(`Unexpected URL: ${urlStr}`);
  };

  const resp = await handleRequest(
    new Request("http://localhost/book-market-aggregator", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "test book" }),
    }),
    {
      env: {
        get: (k: string) => {
          if (k === "SUPABASE_URL") return "https://test.supabase.co";
          if (k === "SUPABASE_SERVICE_ROLE_KEY") return "test-key";
          return undefined;
        },
      },
      fetch: mockFetch,
    },
  );

  if (resp.status !== 200) throw new Error(`expected 200, got ${resp.status}`);

  const body = await resp.json();
  const root = body as Record<string, unknown>;

  const items = root["items"] as Array<Record<string, unknown>>;
  if (!Array.isArray(items) || items.length !== 2) {
    throw new Error(`expected 2 items (vinted failed), got ${items?.length ?? 0}`);
  }

  // Check sources array shows error for vinted
  const sources = root["sources"] as Array<Record<string, unknown>>;
  if (!Array.isArray(sources) || sources.length !== 3) {
    throw new Error(`expected 3 sources, got ${sources?.length ?? 0}`);
  }

  const vintedSource = sources.find((s) => s["source"] === "vinted");
  if (!vintedSource) throw new Error("missing vinted source");
  if (vintedSource["count"] !== 0) throw new Error("vinted should have 0 items");
  if (!vintedSource["error"]) throw new Error("vinted should have error");
});

Deno.test("deduplicates items with same price, date, and URL", async () => {
  const mockFetch = async (url: string | URL | Request) => {
    const urlStr = typeof url === "string" ? url : url.toString();

    // Mock tradera-proxy with duplicate
    if (urlStr.includes("/tradera-proxy")) {
      return new Response(
        JSON.stringify({
          items: [
            {
              maxBid: 100,
              isEnded: true,
              hasBids: true,
              endDate: "2024-01-15T10:00:00Z",
              itemLink: "https://example.com/item/1",
              title: "Tradera Book",
            },
          ],
        }),
        { status: 200 },
      );
    }

    // Mock vinted-scraper with same price, date, and URL (should be deduplicated)
    if (urlStr.includes("/vinted-scraper")) {
      return new Response(
        JSON.stringify({
          items: [
            {
              platform: "vinted",
              price: 100,
              soldAt: "2024-01-15",
              url: "https://example.com/item/1",
              title: "Vinted Book",
            },
          ],
        }),
        { status: 200 },
      );
    }

    // Mock bokborsen-scraper with different price
    if (urlStr.includes("/bokborsen-scraper")) {
      return new Response(
        JSON.stringify({
          items: [
            {
              platform: "bokborsen",
              price: 200,
              soldAt: "2024-01-17",
              url: "https://bokborsen.se/book/1",
              title: "Bokbörsen Book",
            },
          ],
        }),
        { status: 200 },
      );
    }

    throw new Error(`Unexpected URL: ${urlStr}`);
  };

  const resp = await handleRequest(
    new Request("http://localhost/book-market-aggregator", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: "test book" }),
    }),
    {
      env: {
        get: (k: string) => {
          if (k === "SUPABASE_URL") return "https://test.supabase.co";
          if (k === "SUPABASE_SERVICE_ROLE_KEY") return "test-key";
          return undefined;
        },
      },
      fetch: mockFetch,
    },
  );

  if (resp.status !== 200) throw new Error(`expected 200, got ${resp.status}`);

  const body = await resp.json();
  const root = body as Record<string, unknown>;

  const items = root["items"] as Array<Record<string, unknown>>;
  // Should deduplicate the 100 SEK items with same URL from tradera and vinted
  if (!Array.isArray(items) || items.length !== 2) {
    throw new Error(`expected 2 deduplicated items, got ${items?.length ?? 0}`);
  }

  const stats = root["stats"] as Record<string, unknown>;
  if (stats["totalSales"] !== 2) throw new Error("wrong total sales after dedup");
});
