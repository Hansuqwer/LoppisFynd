import { handleRequest } from "../index.ts";

Deno.test("405 method not allowed returns stable error object", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/tradera-proxy", { method: "GET" }),
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
  if (typeof err["message"] !== "string") throw new Error("missing message");
});

Deno.test("400 invalid JSON returns stable code", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/tradera-proxy", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: "{",
    }),
    {
      rateLimit: async () => ({ allowed: true }),
      dailyQuota: async () => ({ allowed: true, used: 1, budget: 100 }),
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

Deno.test("injected rateLimit deny returns 429 + retryAfter", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/tradera-proxy", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ searchWords: "glassvas" }),
    }),
    {
      rateLimit: async () => ({ allowed: false, retryAfterSeconds: 42 }),
      dailyQuota: async () => ({ allowed: true, used: 1, budget: 100 }),
    },
  );

  if (resp.status !== 429) throw new Error(`expected 429, got ${resp.status}`);
  if (resp.headers.get("retry-after") !== "42") {
    throw new Error("missing retry-after header");
  }

  const body = await resp.json();
  const err = (body as Record<string, unknown>)["error"] as
    | Record<string, unknown>
    | undefined;
  if (!err) throw new Error("missing error object");
  if (err["code"] !== "rate_limited") throw new Error("wrong code");
  if (err["retryAfterSeconds"] !== 42) {
    throw new Error("wrong retryAfterSeconds");
  }
});

Deno.test("injected dailyQuota deny returns 429 + retryAfter", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/tradera-proxy", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ searchWords: "glassvas" }),
    }),
    {
      rateLimit: async () => ({ allowed: true }),
      dailyQuota: async () => ({
        allowed: false,
        used: 101,
        budget: 100,
        retryAfterSeconds: 600,
      }),
    },
  );

  if (resp.status !== 429) throw new Error(`expected 429, got ${resp.status}`);
  if (resp.headers.get("retry-after") !== "600") {
    throw new Error("missing retry-after header");
  }

  const body = await resp.json();
  const err = (body as Record<string, unknown>)["error"] as
    | Record<string, unknown>
    | undefined;
  if (!err) throw new Error("missing error object");
  if (err["code"] !== "daily_quota_exhausted") throw new Error("wrong code");
  if (err["retryAfterSeconds"] !== 600) {
    throw new Error("wrong retryAfterSeconds");
  }
});

Deno.test("success path returns JSON compatible with TraderaProxyResponse", async () => {
  const xml =
    `<SearchAdvancedResponse><SearchAdvancedResult><TotalNumberOfItems>1</TotalNumberOfItems><TotalNumberOfPages>1</TotalNumberOfPages><Items><Id>1001</Id><ShortDescription>Rorstrand plate</ShortDescription><EndDate>2026-02-16T20:00:00</EndDate><MaxBid>245</MaxBid><BuyItNowPrice>299</BuyItNowPrice><ItemType>AuctionWithBuyItNow</ItemType><BidCount>3</BidCount><HasBids>true</HasBids><IsEnded>true</IsEnded><ItemUrl>https://tradera.example/item/1001</ItemUrl><ThumbnailLink>https://tradera.example/thumb/1001.jpg</ThumbnailLink></Items></SearchAdvancedResult></SearchAdvancedResponse>`;

  const resp = await handleRequest(
    new Request("http://localhost/tradera-proxy", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ searchWords: "rorstrand" }),
    }),
    {
      env: {
        get: (k: string) => {
          if (k === "TRADERA_APP_ID") return "1";
          if (k === "TRADERA_APP_KEY") return "k";
          return undefined;
        },
      },
      rateLimit: async () => ({ allowed: true }),
      dailyQuota: async () => ({ allowed: true, used: 1, budget: 100 }),
      fetch: async () => new Response(xml, { status: 200 }),
    },
  );

  if (resp.status !== 200) {
    throw new Error(`expected 200, got ${resp.status}`);
  }
  if (resp.headers.get("cache-control") !== "no-store") {
    throw new Error("missing cache-control: no-store");
  }

  const body = await resp.json();
  const root = body as Record<string, unknown>;
  if (typeof root["totalNumberOfItems"] !== "number") {
    throw new Error("missing totalNumberOfItems");
  }
  const items = root["items"];
  if (!Array.isArray(items) || items.length === 0) {
    throw new Error("missing items array");
  }
});
