/**
 * adlibris-scraper — Supabase Edge Function
 *
 * Scrapes used-book listings from Adlibris Sweden.
 * Adlibris shows current *asking* prices, not sold prices.
 * soldAt is null in items; callers treat this as a demand/price proxy.
 *
 * POST { query: string, maxResults?: number }
 * →   { items: AdlibrisItem[], source: "adlibris", query: string }
 *
 * Item shape:
 *   { platform: "adlibris", price: number, title: string|null,
 *     url: string|null, condition: string|null, soldAt: null }
 */

const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
};

export interface AdlibrisItem {
  platform: "adlibris";
  price: number;
  title: string | null;
  url: string | null;
  condition: string | null;
  /** Always null — Adlibris shows listings, not sold transactions. */
  soldAt: null;
}

interface AdlibrisRequest {
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
    return errorJson(
      { code: "method_not_allowed", message: "Method not allowed" },
      405,
    );
  }

  let body: AdlibrisRequest;
  try {
    body = (await req.json()) as AdlibrisRequest;
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

  try {
    // Adlibris used-book search: filter=USED surfaces second-hand listings.
    const searchUrl =
      `https://www.adlibris.com/se/sok?query=${encodeURIComponent(query)}&filter=USED`;

    const response = await doFetch(searchUrl, {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (compatible; BokfyndBot/1.0; +https://bokfynd.se)",
        Accept: "text/html,application/xhtml+xml",
        "Accept-Language": "sv-SE,sv;q=0.9",
      },
    });

    if (!response.ok) {
      return errorJson(
        {
          code: "fetch_failed",
          message: `Adlibris returned ${response.status}`,
        },
        502,
      );
    }

    const html = await response.text();
    const items = parseAdlibrisHtml(html, maxResults);

    return json({ items, source: "adlibris", query }, 200);
  } catch (e) {
    return errorJson(
      { code: "scraper_error", message: String(e).slice(0, 2000) },
      500,
    );
  }
}

/**
 * Parse Adlibris HTML search results.
 *
 * Adlibris renders product cards with these patterns (verified 2025):
 *   - Product block: <article class="product-item …">…</article>
 *   - Title: itemprop="name" or class containing "product-title"
 *   - Price: class="price" or itemprop="price" content="NNN"
 *   - URL: <a href="/se/bok/…"> relative to adlibris.com
 *   - Condition: class="condition" or text "Begagnad" / "Bra skick" etc.
 *
 * The regex approach is intentionally resilient to minor markup changes.
 */
export function parseAdlibrisHtml(
  html: string,
  maxResults: number,
): AdlibrisItem[] {
  const items: AdlibrisItem[] = [];

  // Split on article/product-item boundaries.
  // Adlibris uses <article …> for each product card.
  const blockRegex =
    /<article[^>]*class="[^"]*product-item[^"]*"[^>]*>([\s\S]*?)<\/article>/gi;

  // Fallback: also try <li class="product …"> patterns.
  const fallbackBlockRegex =
    /<li[^>]*class="[^"]*product[^"]*"[^>]*>([\s\S]*?)(?=<li[^>]*class="[^"]*product|<\/ul>)/gi;

  // Price patterns:
  //   itemprop="price" content="249"
  //   class="price">249 kr
  //   data-price="249"
  const pricePatterns = [
    /itemprop="price"\s+content="(\d+(?:[.,]\d+)?)"/i,
    /class="[^"]*price[^"]*"[^>]*>\s*(\d+(?:[.,]\d+)?)\s*(?:kr|SEK|:-)/i,
    /data-price="(\d+(?:[.,]\d+)?)"/i,
    /"price":\s*"?(\d+(?:[.,]\d+)?)"?/i,
  ];

  // Title patterns
  const titlePatterns = [
    /itemprop="name"[^>]*>([^<]{3,200})</i,
    /class="[^"]*product-title[^"]*"[^>]*>[\s\S]*?<[^>]+>([^<]{3,200})</i,
    /class="[^"]*title[^"]*"[^>]*>([^<]{3,200})</i,
    /<h2[^>]*>[\s\S]*?<a[^>]*>([^<]{3,200})</i,
  ];

  // URL pattern — relative Adlibris book paths
  const urlPattern = /href="(\/se\/(?:bok|begagnat)[^"]+)"/i;

  // Condition pattern
  const conditionPattern =
    /class="[^"]*condition[^"]*"[^>]*>([^<]{2,60})</i;

  function parseBlock(block: string): AdlibrisItem | null {
    // Extract price.
    let price: number | null = null;
    for (const pat of pricePatterns) {
      const m = pat.exec(block);
      if (m) {
        const raw = m[1].replace(",", ".").replace(/\s/g, "");
        const parsed = parseFloat(raw);
        if (!isNaN(parsed) && parsed > 0) {
          price = Math.round(parsed);
          break;
        }
      }
    }
    if (price === null || price <= 0) return null;

    // Extract title.
    let title: string | null = null;
    for (const pat of titlePatterns) {
      const m = pat.exec(block);
      if (m) {
        title = stripHtml(m[1]).trim();
        if (title.length >= 2) break;
        title = null;
      }
    }

    // Extract URL.
    const urlMatch = urlPattern.exec(block);
    const url = urlMatch
      ? `https://www.adlibris.com${urlMatch[1]}`
      : null;

    // Extract condition.
    const condMatch = conditionPattern.exec(block);
    const condition = condMatch ? stripHtml(condMatch[1]).trim() : null;

    return {
      platform: "adlibris",
      price,
      title,
      url,
      condition: condition && condition.length > 0 ? condition : null,
      soldAt: null,
    };
  }

  // Try article blocks first.
  let matched = false;
  let m: RegExpExecArray | null;
  while (
    (m = blockRegex.exec(html)) !== null && items.length < maxResults
  ) {
    matched = true;
    const item = parseBlock(m[1]);
    if (item) items.push(item);
  }

  // Fallback to <li> blocks.
  if (!matched) {
    while (
      (m = fallbackBlockRegex.exec(html)) !== null &&
      items.length < maxResults
    ) {
      const item = parseBlock(m[1]);
      if (item) items.push(item);
    }
  }

  // Last resort: scan for JSON-LD product data.
  if (items.length === 0) {
    const jsonLdRegex =
      /<script[^>]*type="application\/ld\+json"[^>]*>([\s\S]*?)<\/script>/gi;
    while (
      (m = jsonLdRegex.exec(html)) !== null && items.length < maxResults
    ) {
      try {
        const data = JSON.parse(m[1]) as Record<string, unknown>;
        if (data["@type"] === "Product" || data["@type"] === "Book") {
          const offers = data["offers"];
          if (typeof offers === "object" && offers !== null) {
            const o = offers as Record<string, unknown>;
            const rawPrice = o["price"] ?? o["lowPrice"];
            const p = typeof rawPrice === "number"
              ? rawPrice
              : parseFloat(String(rawPrice ?? ""));
            if (!isNaN(p) && p > 0) {
              const name = typeof data["name"] === "string"
                ? data["name"]
                : null;
              const urlVal = typeof o["url"] === "string" ? o["url"] : null;
              items.push({
                platform: "adlibris",
                price: Math.round(p),
                title: name,
                url: urlVal,
                condition: null,
                soldAt: null,
              });
            }
          }
        }
      } catch {
        // ignore malformed JSON-LD
      }
    }
  }

  return items;
}

function stripHtml(html: string): string {
  return html
    .replace(/<[^>]*>/g, "")
    .replace(/&auml;/gi, "ä")
    .replace(/&ouml;/gi, "ö")
    .replace(/&aring;/gi, "å")
    .replace(/&Auml;/g, "Ä")
    .replace(/&Ouml;/g, "Ö")
    .replace(/&Aring;/g, "Å")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&nbsp;/g, " ")
    .replace(/&#(\d+);/g, (_, code) => String.fromCharCode(Number(code)))
    .replace(
      /&#x([0-9a-f]+);/gi,
      (_, code) => String.fromCharCode(parseInt(code, 16)),
    )
    .replace(/\s+/g, " ")
    .trim();
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
