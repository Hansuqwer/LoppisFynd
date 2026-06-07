import { handleRequest, parsePublicEndedTraderaHtml } from "../index.ts";

const PUBLIC_ENDED_FIXTURE = `
<html><body>
<main>
<div class="">
<div id="item-card-713035878" data-item-loaded="false" data-item-type="PureBin">
  <a title="Barnbok" href="/item/341216/713035878/barnbok">Barnbok</a>
  <span id="item-card-713035878-time">Avslutad</span>
  <span data-testid="price">5&nbsp;kr<span class="sr-only">,</span></span>
  <img src="https://img.tradera.net/small-square/book.jpg" />
</div>
</div>
<div class="">
<div id="item-card-723233145" data-item-loaded="false" data-item-type="PureBin">
  <a title="Pippi Långstrump" href="/item/341216/723233145/pippi-langstrump">Pippi Långstrump</a>
  <span id="item-card-723233145-time">Avslutad</span>
  <span data-testid="price">49 kr<span class="sr-only">,</span></span>
</div>
</div>
</main>
</body></html>
`;

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

Deno.test("missing Upstash env uses noop rate limit fallback", async () => {
  const xml = await Deno.readTextFile(
    new URL(
      "../fixtures/get_search_result_advanced_xml_response.xml",
      import.meta.url,
    ),
  );

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
      fetch: async () => new Response(xml, { status: 200 }),
    },
  );

  if (resp.status !== 200) throw new Error(`expected 200, got ${resp.status}`);
});

Deno.test("success path returns JSON compatible with TraderaProxyResponse", async () => {
  const xml = await Deno.readTextFile(
    new URL(
      "../fixtures/get_search_result_advanced_xml_response.xml",
      import.meta.url,
    ),
  );

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
      fetch: async () => new Response(xml, { status: 200 }),
    },
  );

  if (resp.status !== 200) throw new Error(`expected 200, got ${resp.status}`);
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

Deno.test("parsePublicEndedTraderaHtml extracts ended sold comps", () => {
  const items = parsePublicEndedTraderaHtml(
    PUBLIC_ENDED_FIXTURE,
    10,
    "2026-06-06T00:00:00.000Z",
  );

  if (items.length !== 2) throw new Error(`expected 2, got ${items.length}`);
  if (items[0].shortDescription !== "Barnbok") throw new Error("wrong title");
  if (items[0].maxBid !== 5) throw new Error("wrong price");
  if (items[0].isEnded !== true) throw new Error("must be ended");
  if (items[0].hasBids !== true) throw new Error("must count as sold comp");
  if (items[0].endDate !== "2026-06-06T00:00:00.000Z") {
    throw new Error("wrong endDate fallback");
  }
});

Deno.test("TRADERA_PUBLIC_FALLBACK serves public ended comps without API creds", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/tradera-proxy", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ searchWords: "barnbok", itemsPerPage: 10 }),
    }),
    {
      env: {
        get: (k: string) => k === "TRADERA_PUBLIC_FALLBACK" ? "1" : undefined,
      },
      rateLimit: async () => ({ allowed: true }),
      fetch: async () => new Response(PUBLIC_ENDED_FIXTURE, { status: 200 }),
    },
  );

  if (resp.status !== 200) throw new Error(`expected 200, got ${resp.status}`);
  const body = await resp.json() as Record<string, unknown>;
  const items = body["items"];
  if (!Array.isArray(items) || items.length !== 2) {
    throw new Error("missing public fallback items");
  }
});
