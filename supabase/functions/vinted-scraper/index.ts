const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
};

interface VintedScraperRequest {
  query: string;
  maxResults?: number;
}

interface VintedItem {
  id?: string;
  title?: string;
  price?: number | { amount?: number };
  currency?: string;
  url?: string;
  status?: string;
  soldAt?: string;
  sold_at?: string;
  soldDate?: string;
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

  const apifyToken = (env.get("APIFY_API_TOKEN") ?? "").trim();
  const actorId = (env.get("VINTED_SCRAPER_ACTOR_ID") ?? "").trim();

  if (!apifyToken || !actorId) {
    return errorJson(
      {
        code: "server_not_configured",
        message: "Set APIFY_API_TOKEN and VINTED_SCRAPER_ACTOR_ID in Supabase secrets.",
      },
      500,
    );
  }

  let body: VintedScraperRequest;
  try {
    body = (await req.json()) as VintedScraperRequest;
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

  try {
    const runResponse = await doFetch(
      `https://api.apify.com/v2/acts/${actorId}/runs?memory=256`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${apifyToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          searchQuery: query,
          maxItems: maxResults,
          country: "se",
        }),
      },
    );

    if (!runResponse.ok) {
      const text = await runResponse.text();
      return errorJson(
        {
          code: "apify_start_failed",
          message: `Apify run start failed: ${runResponse.status} ${text.slice(0, 500)}`,
        },
        502,
      );
    }

    const runData = (await runResponse.json()) as {
      data?: { id?: string; status?: string; defaultDatasetId?: string };
    };
    const runId = runData.data?.id;
    const datasetId = runData.data?.defaultDatasetId;
    if (!runId || !datasetId) {
      return errorJson({ code: "apify_no_run_id", message: "No run ID from Apify" }, 502);
    }

    const items = await pollForResults(runId, datasetId, apifyToken, doFetch);

    const parsed = items
      .filter((item) => {
        const status = item.status?.toLowerCase();
        return !status || status === "sold" || status === "completed";
      })
      .map((item) => ({
        platform: "vinted",
        price: extractPrice(item),
        soldAt: item.soldAt ?? item.sold_at ?? item.soldDate ?? null,
        url: item.url ?? null,
        title: item.title ?? null,
      }))
      .filter((item) => item.price != null && item.price > 0);

    return json({ items: parsed, source: "vinted", query }, 200);
  } catch (e) {
    return errorJson(
      { code: "scraper_error", message: String(e).slice(0, 2000) },
      500,
    );
  }
}

async function pollForResults(
  runId: string,
  datasetId: string,
  apifyToken: string,
  doFetch: typeof fetch,
  maxAttempts = 20,
  pollIntervalMs = 2000,
): Promise<VintedItem[]> {
  for (let i = 0; i < maxAttempts; i++) {
    await new Promise((resolve) => setTimeout(resolve, pollIntervalMs));

    const statusResp = await doFetch(
      `https://api.apify.com/v2/actor-runs/${runId}`,
      {
        headers: { Authorization: `Bearer ${apifyToken}` },
      },
    );

    if (!statusResp.ok) continue;

    const statusData = (await statusResp.json()) as {
      data?: { status?: string };
    };
    const status = statusData.data?.status;

    if (status === "SUCCEEDED") {
      const itemsResp = await doFetch(
        `https://api.apify.com/v2/datasets/${datasetId}/items?format=json`,
        {
          headers: { Authorization: `Bearer ${apifyToken}` },
        },
      );

      if (!itemsResp.ok) return [];

      const items = await itemsResp.json();
      return Array.isArray(items) ? (items as VintedItem[]) : [];
    }

    if (status === "FAILED" || status === "ABORTED" || status === "TIMED-OUT") {
      return [];
    }
  }

  return [];
}

function extractPrice(item: VintedItem): number | null {
  if (typeof item.price === "number") return Math.round(item.price);
  if (typeof item.price === "object" && item.price?.amount != null) {
    return Math.round(item.price.amount);
  }
  return null;
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
