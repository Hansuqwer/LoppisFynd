const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
};

interface AggregatorRequest {
  query: string;
  isbn?: string;
  maxResults?: number;
}

interface SaleItem {
  platform: string;
  price: number;
  soldAt: string | null;
  url: string | null;
  title: string | null;
}

interface SourceResult {
  source: string;
  items: SaleItem[];
  error?: string;
}

export async function handleRequest(
  req: Request,
  deps: {
    env?: { get: (key: string) => string | undefined };
    fetch?: typeof fetch;
  } = {},
): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return errorJson({ code: "method_not_allowed", message: "Method not allowed" }, 405);
  }

  const env = deps.env ?? { get: (k: string) => Deno.env.get(k) };
  const doFetch = deps.fetch ?? fetch;

  const supabaseUrl = (env.get("SUPABASE_URL") ?? "").trim();
  const serviceKey = (env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "").trim();

  if (!supabaseUrl || !serviceKey) {
    return errorJson(
      {
        code: "server_not_configured",
        message: "Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in Supabase secrets.",
      },
      500,
    );
  }

  let body: AggregatorRequest;
  try {
    body = (await req.json()) as AggregatorRequest;
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

  const edgeHeaders = {
    Authorization: `Bearer ${serviceKey}`,
    apikey: serviceKey,
    "Content-Type": "application/json",
  };

  const sources = await Promise.allSettled([
    callEdgeFunction(
      `${supabaseUrl}/functions/v1/tradera-proxy`,
      {
        searchWords: query,
        itemStatus: "Ended",
        orderBy: "EndDateDescending",
        itemsPerPage: maxResults,
        pageNumber: 1,
      },
      edgeHeaders,
      "tradera",
      doFetch,
    ),
    callEdgeFunction(
      `${supabaseUrl}/functions/v1/vinted-scraper`,
      { query, maxResults },
      edgeHeaders,
      "vinted",
      doFetch,
    ),
    callEdgeFunction(
      `${supabaseUrl}/functions/v1/bokborsen-scraper`,
      { query, maxResults },
      edgeHeaders,
      "bokborsen",
      doFetch,
    ),
  ]);

  const results: SourceResult[] = sources.map((result, index) => {
    const sourceNames = ["tradera", "vinted", "bokborsen"];
    if (result.status === "fulfilled") {
      return result.value;
    }
    return {
      source: sourceNames[index],
      items: [],
      error: String(result.reason),
    };
  });

  const allItems: SaleItem[] = [];
  for (const result of results) {
    allItems.push(...result.items);
  }

  const deduplicated = deduplicateSales(allItems);
  const stats = calculateStats(deduplicated);

  return json(
    {
      query,
      isbn: body.isbn ?? null,
      items: deduplicated,
      stats,
      sources: results.map((r) => ({
        source: r.source,
        count: r.items.length,
        error: r.error ?? null,
      })),
    },
    200,
  );
}

async function callEdgeFunction(
  url: string,
  payload: Record<string, unknown>,
  headers: Record<string, string>,
  source: string,
  doFetch: typeof fetch,
): Promise<SourceResult> {
  try {
    const response = await doFetch(url, {
      method: "POST",
      headers,
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      return { source, items: [], error: `HTTP ${response.status}` };
    }

    const data = (await response.json()) as Record<string, unknown>;

    if (source === "tradera") {
      return parseTraderaResponse(data);
    }

    const items = data.items;
    if (!Array.isArray(items)) {
      return { source, items: [], error: "No items in response" };
    }

    return {
      source,
      items: (items as SaleItem[]).map((item) => ({
        ...item,
        platform: source,
      })),
    };
  } catch (e) {
    return { source, items: [], error: String(e) };
  }
}

function parseTraderaResponse(data: Record<string, unknown>): SourceResult {
  const items = data.items;
  if (!Array.isArray(items)) {
    return { source: "tradera", items: [], error: "No items" };
  }

  const sales: SaleItem[] = [];
  for (const raw of items) {
    if (typeof raw !== "object" || raw === null) continue;
    const item = raw as Record<string, unknown>;

    const price = typeof item.maxBid === "number" ? item.maxBid : null;
    if (price == null || price <= 0) continue;
    if (item.isEnded === false) continue;
    if (item.hasBids === false) continue;

    sales.push({
      platform: "tradera",
      price,
      soldAt: typeof item.endDate === "string" ? item.endDate : null,
      url: typeof item.itemLink === "string" ? item.itemLink : null,
      title: typeof item.title === "string" ? item.title : null,
    });
  }

  return { source: "tradera", items: sales };
}

function deduplicateSales(items: SaleItem[]): SaleItem[] {
  const seen = new Set<string>();
  const result: SaleItem[] = [];

  for (const item of items) {
    const dateKey = item.soldAt
      ? item.soldAt.substring(0, 10)
      : "unknown";
    const key = `${item.price}|${dateKey}|${item.url ?? ""}`;
    if (!seen.has(key)) {
      seen.add(key);
      result.push(item);
    }
  }

  return result;
}

function calculateStats(items: SaleItem[]): {
  highestPrice: number | null;
  averagePrice: number | null;
  lowestPrice: number | null;
  totalSales: number;
  sourceCounts: Record<string, number>;
} | null {
  if (items.length === 0) return null;

  const prices = items.map((i) => i.price).sort((a, b) => a - b);
  const total = prices.reduce((sum, p) => sum + p, 0);

  const sourceCounts: Record<string, number> = {};
  for (const item of items) {
    sourceCounts[item.platform] = (sourceCounts[item.platform] ?? 0) + 1;
  }

  return {
    highestPrice: prices[prices.length - 1],
    averagePrice: Math.round(total / prices.length),
    lowestPrice: prices[0],
    totalSales: items.length,
    sourceCounts,
  };
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
