const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
};

interface BokborsenRequest {
  query: string;
  maxResults?: number;
}

interface ParsedItem {
  platform: string;
  price: number;
  soldAt: string | null;
  url: string | null;
  title: string | null;
}

export async function handleRequest(
  req: Request,
  deps: {
    fetch?: typeof fetch;
  } = {},
): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return errorJson({ code: "method_not_allowed", message: "Method not allowed" }, 405);
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

  try {
    const searchUrl = `https://www.bokborsen.se/search?q=${encodeURIComponent(query)}&sort=sold_date`;
    const response = await doFetch(searchUrl, {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (compatible; BokfyndBot/1.0; +https://bokfynd.se)",
        Accept: "text/html",
      },
    });

    if (!response.ok) {
      return errorJson(
        {
          code: "fetch_failed",
          message: `Bokbörsen returned ${response.status}`,
        },
        502,
      );
    }

    const html = await response.text();
    const items = parseBokborsenHtml(html, maxResults);

    return json({ items, source: "bokborsen", query }, 200);
  } catch (e) {
    return errorJson(
      { code: "scraper_error", message: String(e).slice(0, 2000) },
      500,
    );
  }
}

function parseBokborsenHtml(html: string, maxResults: number): ParsedItem[] {
  const items: ParsedItem[] = [];

  const listingRegex =
    /<div[^>]*class="[^"]*listing[^"]*"[^>]*>([\s\S]*?)<\/div>\s*<\/div>/gi;
  const priceRegex = /(\d+)\s*(?:kr|SEK)/i;
  const titleRegex =
    /<(?:h[23]|a)[^>]*class="[^"]*title[^"]*"[^>]*>([\s\S]*?)<\/(?:h[23]|a)>/i;
  const linkRegex = /href="([^"]+)"/i;
  const dateRegex = /(\d{4}-\d{2}-\d{2})/;

  let match: RegExpExecArray | null;
  while ((match = listingRegex.exec(html)) !== null && items.length < maxResults) {
    const block = match[1];

    const priceMatch = priceRegex.exec(block);
    if (!priceMatch) continue;
    const price = parseInt(priceMatch[1], 10);
    if (isNaN(price) || price <= 0) continue;

    const titleMatch = titleRegex.exec(block);
    const title = titleMatch ? stripHtml(titleMatch[1]).trim() : null;

    const linkMatch = linkRegex.exec(block);
    const url = linkMatch ? linkMatch[1] : null;

    const dateMatch = dateRegex.exec(block);
    const soldAt = dateMatch ? dateMatch[1] : null;

    items.push({
      platform: "bokborsen",
      price,
      soldAt,
      url: url ? (url.startsWith("http") ? url : `https://www.bokborsen.se${url}`) : null,
      title,
    });
  }

  return items;
}

function stripHtml(html: string): string {
  return html.replace(/<[^>]*>/g, "").replace(/&amp;/g, "&").replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">").replace(/&quot;/g, '"').replace(/&#39;/g, "'");
}

if (import.meta.main) {
  Deno.serve((req) => handleRequest(req));
}

function json(data: unknown, status: number): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json", "cache-control": "no-store" },
  });
}

function errorJson(
  error: { code: string; message: string },
  status: number,
): Response {
  return new Response(JSON.stringify({ error }), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json", "cache-control": "no-store" },
  });
}
