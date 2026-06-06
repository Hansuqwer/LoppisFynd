/**
 * blocket-scraper — Supabase Edge Function
 *
 * Scrapes active book listings from Blocket.se (Sweden's largest classifieds).
 *
 * Strategy: parse the JSON-LD `<script id="seoStructuredData">` block embedded
 * in the SSR HTML.  This is immune to CSS class renames and requires no headless
 * browser.  Blocket has NO sold-item filter — all results are active listings.
 * soldAt is always null; callers treat prices as demand / asking-price comps.
 *
 * POST { query: string, maxResults?: number }
 * →   { items: BlocketItem[], source: "blocket", query: string }
 *
 * Item shape:
 *   { platform:"blocket", price:number, title:string|null,
 *     url:string|null, soldAt:null }
 */

const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
};

export interface BlocketItem {
  platform: "blocket";
  price: number;
  title: string | null;
  url: string | null;
  /** Always null — Blocket shows active listings only, not sold transactions. */
  soldAt: null;
}

interface BlocketRequest {
  query: string;
  maxResults?: number;
}

// Shape of a single item inside the JSON-LD CollectionPage → ItemList
interface JsonLdListItem {
  item?: {
    name?: string;
    url?: string;
    offers?: {
      price?: number | string;
      priceCurrency?: string;
      availability?: string;
    };
  };
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

  let body: BlocketRequest;
  try {
    body = (await req.json()) as BlocketRequest;
  } catch {
    return errorJson({ code: "invalid_json", message: "Invalid JSON" }, 400);
  }

  const query = (body.query ?? "").trim();
  if (query.length < 2 || query.length > 200) {
    return errorJson({
      code: "invalid_request",
      message: "query must be 2..200 chars",
    }, 400);
  }

  const maxResults = Math.min(body.maxResults ?? 50, 100);
  const doFetch = deps.fetch ?? fetch;

  // Blocket book/magazine category = "bocker-tidningar", nation-wide search.
  // The recommerce platform does a 301 to the actual search URL with location param;
  // we follow redirects (default fetch behaviour).
  const searchUrl =
    `https://www.blocket.se/annonser/hela_sverige/bocker-tidningar?r=1&q=${
      encodeURIComponent(query)
    }`;

  let html: string;
  try {
    const resp = await doFetch(searchUrl, {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (compatible; BokfyndBot/1.0; +https://bokfynd.se)",
        Accept: "text/html,application/xhtml+xml",
        "Accept-Language": "sv-SE,sv;q=0.9",
        "Cache-Control": "no-cache",
      },
      redirect: "follow",
    });

    if (!resp.ok) {
      return errorJson(
        { code: "fetch_failed", message: `Blocket returned ${resp.status}` },
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

  const items = parseBlocketHtml(html, maxResults);
  return json({ items, source: "blocket", query }, 200);
}

/**
 * Primary strategy: extract the JSON-LD block with id="seoStructuredData".
 * The structure is:
 *   { "@type": "CollectionPage", "mainEntity": { "@type": "ItemList",
 *     "itemListElement": [ { "@type": "ListItem", "item": {
 *       "@type": "Product", "name": "...", "url": "...",
 *       "offers": { "price": 75, "priceCurrency": "SEK",
 *                   "availability": "https://schema.org/InStock" }
 *     }}]}}
 *
 * Fallback strategy: article-tag HTML parsing with price/title selectors
 * confirmed in research (2025-06).
 */
export function parseBlocketHtml(
  html: string,
  maxResults: number,
): BlocketItem[] {
  // ── Primary: JSON-LD ─────────────────────────────────────────────────────
  const jsonLdItems = tryParseJsonLd(html, maxResults);
  if (jsonLdItems.length > 0) return jsonLdItems;

  // ── Fallback: article HTML ────────────────────────────────────────────────
  return parseBlocketArticles(html, maxResults);
}

function tryParseJsonLd(html: string, maxResults: number): BlocketItem[] {
  // The structured-data script may or may not have id="seoStructuredData".
  // Try both approaches: by id attr and by iterating all ld+json blocks.
  const scriptById =
    /<script[^>]*id="seoStructuredData"[^>]*>([\s\S]*?)<\/script>/i.exec(html)
      ?.[1];
  const candidates: string[] = scriptById ? [scriptById] : [];

  // Also collect all application/ld+json blocks
  const ldJsonRe =
    /<script[^>]*type="application\/ld\+json"[^>]*>([\s\S]*?)<\/script>/gi;
  let m: RegExpExecArray | null;
  while ((m = ldJsonRe.exec(html)) !== null) {
    candidates.push(m[1]);
  }

  for (const raw of candidates) {
    try {
      const data = JSON.parse(raw) as Record<string, unknown>;
      const items = extractFromCollectionPage(data, maxResults);
      if (items.length > 0) return items;
    } catch {
      // skip malformed block
    }
  }
  return [];
}

function extractFromCollectionPage(
  data: Record<string, unknown>,
  maxResults: number,
): BlocketItem[] {
  const result: BlocketItem[] = [];

  // Try CollectionPage → mainEntity → ItemList → itemListElement
  const mainEntity = data["mainEntity"] ?? data["@graph"];
  const itemList = findItemList(mainEntity ?? data);
  if (!itemList) return result;

  const elements = itemList["itemListElement"];
  if (!Array.isArray(elements)) return result;

  for (const el of elements as JsonLdListItem[]) {
    if (result.length >= maxResults) break;
    const item = el.item ?? (el as unknown as JsonLdListItem["item"]);
    if (!item) continue;

    const offers = item.offers;
    if (!offers) continue;

    const rawPrice = offers.price;
    const price = typeof rawPrice === "number"
      ? rawPrice
      : parseFloat(String(rawPrice ?? "").replace(/[^\d.]/g, ""));
    if (isNaN(price) || price <= 0) continue;

    result.push({
      platform: "blocket",
      price: Math.round(price),
      title: typeof item.name === "string" ? item.name.trim() || null : null,
      url: typeof item.url === "string" ? item.url.trim() || null : null,
      soldAt: null,
    });
  }

  return result;
}

function findItemList(node: unknown): Record<string, unknown> | null {
  if (!node || typeof node !== "object") return null;
  if (Array.isArray(node)) {
    for (const child of node) {
      const found = findItemList(child);
      if (found) return found;
    }
    return null;
  }
  const rec = node as Record<string, unknown>;
  if (rec["@type"] === "ItemList") return rec;
  for (const val of Object.values(rec)) {
    if (val && typeof val === "object") {
      const found = findItemList(val);
      if (found) return found;
    }
  }
  return null;
}

/**
 * Fallback HTML parser using confirmed article selectors (research 2025-06).
 *   article.sf-search-ad  →  card container
 *   a.sf-search-ad-link[href]  →  URL
 *   h2.h4  →  title
 *   div.flex.justify-between span (first)  →  price text "75 kr"
 */
function parseBlocketArticles(html: string, maxResults: number): BlocketItem[] {
  const items: BlocketItem[] = [];

  // Split on article boundaries
  const articleRe =
    /<article[^>]*class="[^"]*sf-search-ad[^"]*"[^>]*>([\s\S]*?)<\/article>/gi;
  let m: RegExpExecArray | null;

  while ((m = articleRe.exec(html)) !== null && items.length < maxResults) {
    const block = m[1];

    // URL
    const urlMatch = /class="[^"]*sf-search-ad-link[^"]*"[^>]*href="([^"]+)"/i
      .exec(block);
    const url = urlMatch ? urlMatch[1] : null;

    // Price — text like "75 kr" or "1 500 kr"
    const priceMatch = /<span[^>]*>(\d[\d\s]*)\s*kr<\/span>/i.exec(block);
    if (!priceMatch) continue;
    const priceStr = priceMatch[1].replace(/\s/g, "");
    const price = parseInt(priceStr, 10);
    if (isNaN(price) || price <= 0) continue;

    // Title — h2 with class h4
    const titleMatch = /<h2[^>]*class="[^"]*h4[^"]*"[^>]*>([^<]+)</i.exec(
      block,
    );
    const title = titleMatch ? titleMatch[1].trim() || null : null;

    items.push({ platform: "blocket", price, title, url, soldAt: null });
  }

  return items;
}

// ── HTTP helpers ──────────────────────────────────────────────────────────────

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
