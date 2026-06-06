/**
 * bokborsen-scraper — Supabase Edge Function  (v2 — 2025-06)
 *
 * Scrapes sold-price-sorted book listings from Bokbörsen.se.
 *
 * Research findings (2025-06):
 *   • No Cloudflare, no JS rendering required — pure SSR PHP/Laravel.
 *   • `sort=sold_date` returns items ordered by most-recently-purchased date.
 *   • Individual listing cards do NOT carry a sold timestamp in HTML;
 *     the sorted order IS the sold signal.
 *   • soldAt is set to fetchedAt (now) as a proxy — callers aware of this.
 *
 * Parsing strategy (two layers):
 *   1. schema.org/Offer JSON-LD blocks — immune to CSS class changes.
 *   2. CSS selector fallback — confirmed selectors from research:
 *        span.price           → "66 SEK"
 *        div.header h2 a      → listing URL
 *        span[itemprop=name]  → title
 *
 * POST { query: string, maxResults?: number }
 * →   { items: BokborsenItem[], source: "bokborsen", query: string }
 */

const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
};

export interface BokborsenItem {
  platform: "bokborsen";
  price: number;
  title: string | null;
  url: string | null;
  soldAt: string | null;
}

interface BokborsenRequest {
  query: string;
  maxResults?: number;
}

export async function handleRequest(
  req: Request,
  deps: { fetch?: typeof fetch } = {},
): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return errorJson({
      code: "method_not_allowed",
      message: "Method not allowed",
    }, 405);
  }

  let body: BokborsenRequest;
  try {
    body = (await req.json()) as BokborsenRequest;
  } catch {
    return errorJson({ code: "invalid_json", message: "Invalid JSON" }, 400);
  }

  const query = (body.query ?? "").trim();
  if (query.length < 2 || query.length > 200) {
    return errorJson(
      { code: "invalid_request", message: "query must be 2..200 chars" },
      400,
    );
  }

  const maxResults = Math.min(body.maxResults ?? 50, 100);
  const doFetch = deps.fetch ?? fetch;

  const searchUrl = `https://www.bokborsen.se/search?q=${
    encodeURIComponent(query)
  }&sort=sold_date`;

  let html: string;
  try {
    const resp = await doFetch(searchUrl, {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (compatible; BokfyndBot/1.0; +https://bokfynd.se)",
        Accept: "text/html",
        "Accept-Language": "sv-SE,sv;q=0.9",
      },
    });
    if (!resp.ok) {
      return errorJson(
        { code: "fetch_failed", message: `Bokbörsen returned ${resp.status}` },
        502,
      );
    }
    html = await resp.text();
  } catch (e) {
    return errorJson(
      { code: "fetch_error", message: String(e).slice(0, 500) },
      502,
    );
  }

  const items = parseBokborsenHtml(html, maxResults);
  return json({ items, source: "bokborsen", query }, 200);
}

/**
 * Parse Bokbörsen HTML.  Two strategies:
 *   A. schema.org JSON-LD Product blocks (preferred — markup-agnostic)
 *   B. Confirmed CSS selectors (fallback)
 */
export function parseBokborsenHtml(
  html: string,
  maxResults: number,
  now?: Date,
): BokborsenItem[] {
  const soldAt = (now ?? new Date()).toISOString();

  // ── Strategy A: JSON-LD Product blocks ──────────────────────────────────
  const jsonLdItems = tryJsonLdProducts(html, maxResults, soldAt);
  if (jsonLdItems.length > 0) return jsonLdItems;

  // ── Strategy B: CSS selector fallback ────────────────────────────────────
  return parseCssSelectors(html, maxResults, soldAt);
}

// ── A: JSON-LD ───────────────────────────────────────────────────────────────

function tryJsonLdProducts(
  html: string,
  maxResults: number,
  soldAt: string,
): BokborsenItem[] {
  const items: BokborsenItem[] = [];
  const re =
    /<script[^>]*type="application\/ld\+json"[^>]*>([\s\S]*?)<\/script>/gi;
  let m: RegExpExecArray | null;

  while ((m = re.exec(html)) !== null && items.length < maxResults) {
    let data: unknown;
    try {
      data = JSON.parse(m[1]);
    } catch {
      continue;
    }
    collectProducts(data, items, maxResults, soldAt);
  }
  return items;
}

function collectProducts(
  node: unknown,
  out: BokborsenItem[],
  maxResults: number,
  soldAt: string,
): void {
  if (out.length >= maxResults || !node || typeof node !== "object") return;
  if (Array.isArray(node)) {
    for (const child of node) collectProducts(child, out, maxResults, soldAt);
    return;
  }
  const rec = node as Record<string, unknown>;
  const type = rec["@type"];
  if (type === "Product" || type === "Book") {
    const item = extractJsonLdProduct(rec, soldAt);
    if (item) out.push(item);
    return;
  }
  // Recurse into nested objects (handles @graph arrays etc.)
  for (const val of Object.values(rec)) {
    if (val && typeof val === "object") {
      collectProducts(val, out, maxResults, soldAt);
    }
  }
}

function extractJsonLdProduct(
  rec: Record<string, unknown>,
  soldAt: string,
): BokborsenItem | null {
  const offers = rec["offers"];
  if (!offers || typeof offers !== "object") return null;
  const o = offers as Record<string, unknown>;

  const rawPrice = o["price"] ?? o["lowPrice"];
  const priceStr = String(rawPrice ?? "")
    .replace(/[^\d.,]/g, "")
    .replace(",", ".");
  const price = parseFloat(priceStr);
  if (isNaN(price) || price <= 0) return null;

  const name = typeof rec["name"] === "string"
    ? rec["name"].trim() || null
    : null;
  const url = typeof o["url"] === "string"
    ? (o["url"].startsWith("http")
      ? o["url"]
      : `https://www.bokborsen.se${o["url"]}`)
    : null;

  return {
    platform: "bokborsen",
    price: Math.round(price),
    title: name,
    url,
    soldAt,
  };
}

// ── B: CSS selector fallback ─────────────────────────────────────────────────
// Confirmed selectors (research 2025-06):
//   Container: div.single-product  (class: "single-product content item group")
//   Price:     span.price           → "66 SEK"
//   Title:     span[itemprop=name]  → book title
//   URL:       div.header h2 a[href]
//   Condition: span.created-at-view.discreet  (listing age, not sold date)

function parseCssSelectors(
  html: string,
  maxResults: number,
  soldAt: string,
): BokborsenItem[] {
  const items: BokborsenItem[] = [];

  // Split on confirmed container class
  const blockRe =
    /<div[^>]*class="[^"]*single-product[^"]*"[^>]*>([\s\S]*?)(?=<div[^>]*class="[^"]*single-product|$)/gi;
  let m: RegExpExecArray | null;

  while ((m = blockRe.exec(html)) !== null && items.length < maxResults) {
    const block = m[1];

    // Price — confirmed: <span class="price">66 SEK</span>
    const priceMatch = /class="[^"]*\bprice\b[^"]*"[^>]*>(\d[\d\s]*)\s*SEK/i
      .exec(block);
    if (!priceMatch) continue;
    const price = parseInt(priceMatch[1].replace(/\s/g, ""), 10);
    if (isNaN(price) || price <= 0) continue;

    // Title — confirmed: <span itemprop="name">...</span>
    const titleMatch = /itemprop="name"[^>]*>([^<]{2,200})/i.exec(block);
    const title = titleMatch ? stripHtml(titleMatch[1]).trim() || null : null;

    // URL — confirmed: <a href="/view/...">
    const urlMatch = /href="(\/view\/[^"]+)"/i.exec(block);
    const url = urlMatch ? `https://www.bokborsen.se${urlMatch[1]}` : null;

    items.push({ platform: "bokborsen", price, title, url, soldAt });
  }

  return items;
}

// ── Utilities ─────────────────────────────────────────────────────────────────

function stripHtml(html: string): string {
  return html
    .replace(/<[^>]*>/g, "")
    .replace(/&auml;/gi, "ä").replace(/&ouml;/gi, "ö").replace(/&aring;/gi, "å")
    .replace(/&Auml;/g, "Ä").replace(/&Ouml;/g, "Ö").replace(/&Aring;/g, "Å")
    .replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&nbsp;/g, " ")
    .replace(/&#(\d+);/g, (_, c) => String.fromCharCode(Number(c)))
    .replace(
      /&#x([0-9a-f]+);/gi,
      (_, c) => String.fromCharCode(parseInt(c, 16)),
    )
    .replace(/\s+/g, " ").trim();
}

if (import.meta.main) {
  Deno.serve((req) => handleRequest(req));
}

function json(data: unknown, status: number): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "content-type": "application/json",
      "cache-control": "no-store",
    },
  });
}

function errorJson(
  error: { code: string; message: string },
  status: number,
): Response {
  return new Response(JSON.stringify({ error }), {
    status,
    headers: {
      ...corsHeaders,
      "content-type": "application/json",
      "cache-control": "no-store",
    },
  });
}
