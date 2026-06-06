/**
 * vinted-scraper — Supabase Edge Function
 *
 * Primary strategy (research 2025-06):
 *   1. GET Vinted catalog page to obtain anonymous `access_token_web` cookie.
 *   2. Call REST API: /api/v2/catalog/items?search_text=...&per_page=...
 *   3. Parse JSON items: price.amount, title, url/path, sold_at.
 *
 * Notes:
 *   • Vinted runs Cloudflare + DataDome. Low-volume anonymous API calls work,
 *     but may be blocked at scale. If direct API fails, and APIFY_API_TOKEN +
 *     VINTED_SCRAPER_ACTOR_ID are configured, fallback to Apify actor.
 *   • The `status_ids` for sold-only is unstable / session-dependent, so this
 *     scraper requests broad catalog results and filters `sold_at != null` when
 *     available. If sold results are unavailable, active asking prices are still
 *     returned as demand proxy with `soldAt:null`.
 */

const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
};

interface VintedScraperRequest {
  query: string;
  maxResults?: number;
  soldOnly?: boolean;
}

interface VintedApiItem {
  id?: number | string;
  title?: string;
  price?: { amount?: string | number; currency_code?: string } | number;
  url?: string;
  path?: string;
  status?: string;
  sold_at?: string | number | null;
  soldAt?: string | number | null;
  soldDate?: string | number | null;
}

interface ParsedVintedItem {
  platform: "vinted";
  price: number;
  soldAt: string | null;
  url: string | null;
  title: string | null;
}

type EnvProvider = { get: (key: string) => string | undefined };
type FetchLike = (
  input: RequestInfo | URL,
  init?: RequestInit,
) => Promise<Response>;

export async function handleRequest(
  req: Request,
  deps: { env?: EnvProvider; fetch?: FetchLike } = {},
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

  const env = deps.env ?? { get: (k: string) => Deno.env.get(k) };
  const doFetch = deps.fetch ?? fetch;

  let body: VintedScraperRequest;
  try {
    body = (await req.json()) as VintedScraperRequest;
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
  const soldOnly = body.soldOnly ?? false;

  // Primary direct API path.
  const direct = await fetchViaVintedApi({
    query,
    maxResults,
    soldOnly,
    doFetch,
  });
  if (direct.ok) {
    return json({ items: direct.items, source: "vinted", query }, 200);
  }

  // Fallback: Apify actor if configured.
  const apifyToken = (env.get("APIFY_API_TOKEN") ?? "").trim();
  const actorId = (env.get("VINTED_SCRAPER_ACTOR_ID") ?? "").trim();
  if (apifyToken && actorId) {
    const apify = await fetchViaApify({
      query,
      maxResults,
      apifyToken,
      actorId,
      doFetch,
    });
    if (apify.ok) {
      return json({
        items: apify.items,
        source: "vinted",
        query,
        fallback: "apify",
      }, 200);
    }
  }

  return errorJson(
    {
      code: "scraper_error",
      message: direct.error ??
        "Vinted direct API failed and Apify fallback is not configured.",
    },
    502,
  );
}

// ── Direct Vinted API path ───────────────────────────────────────────────────

async function fetchViaVintedApi(args: {
  query: string;
  maxResults: number;
  soldOnly: boolean;
  doFetch: FetchLike;
}): Promise<
  { ok: true; items: ParsedVintedItem[] } | { ok: false; error: string }
> {
  const { query, maxResults, soldOnly, doFetch } = args;
  const ua =
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36";

  let cookie = "";
  try {
    const pageUrl = `https://www.vinted.se/catalog?search_text=${
      encodeURIComponent(query)
    }`;
    const pageResp = await doFetch(pageUrl, {
      headers: {
        "User-Agent": ua,
        Accept: "text/html,application/xhtml+xml",
        "Accept-Language": "sv-SE,sv;q=0.9,en;q=0.8",
      },
      redirect: "follow",
    });

    if (!pageResp.ok) {
      return {
        ok: false,
        error: `Vinted session page returned ${pageResp.status}`,
      };
    }

    cookie = extractSetCookieHeader(pageResp.headers);
    if (!cookie.includes("access_token_web=")) {
      // Some Deno runtimes coalesce headers differently; still try API with all cookies.
      const text = await pageResp.text();
      if (isBotChallenge(text)) {
        return { ok: false, error: "Vinted bot challenge / DataDome detected" };
      }
    }
  } catch (e) {
    return { ok: false, error: `Vinted session request failed: ${String(e)}` };
  }

  // Direct API. We request broad catalog items; soldOnly filters by `sold_at` if present.
  const apiUrl = new URL("https://www.vinted.se/api/v2/catalog/items");
  apiUrl.searchParams.set("search_text", query);
  apiUrl.searchParams.set("per_page", String(maxResults));
  apiUrl.searchParams.set("page", "1");
  apiUrl.searchParams.set("currency", "SEK");

  // Try common active/sold status ids in order.  If none return sold data,
  // the first non-empty response still provides asking-price proxies.
  const candidateStatusIds = soldOnly
    ? ["7", "3", "6", ""]
    : ["6", "", "7", "3"];

  let firstNonEmpty: ParsedVintedItem[] = [];
  let lastError = "";

  for (const statusId of candidateStatusIds) {
    const url = new URL(apiUrl.toString());
    if (statusId) url.searchParams.append("status_ids[]", statusId);

    try {
      const apiResp = await doFetch(url, {
        headers: {
          "User-Agent": ua,
          Accept: "application/json, text/plain, */*",
          "Accept-Language": "sv-SE,sv;q=0.9,en;q=0.8",
          ...(cookie ? { Cookie: cookie } : {}),
          Referer: `https://www.vinted.se/catalog?search_text=${
            encodeURIComponent(query)
          }`,
        },
      });

      if (!apiResp.ok) {
        lastError = `Vinted API returned ${apiResp.status}`;
        continue;
      }

      const data = await apiResp.json() as Record<string, unknown>;
      const rawItems = Array.isArray(data["items"])
        ? data["items"] as VintedApiItem[]
        : [];
      const parsed = rawItems
        .map(parseVintedApiItem)
        .filter((i): i is ParsedVintedItem => i != null)
        .filter((i) => !soldOnly || i.soldAt != null);

      if (parsed.length > 0) return { ok: true, items: parsed };

      const proxies = rawItems
        .map(parseVintedApiItem)
        .filter((i): i is ParsedVintedItem => i != null);
      if (firstNonEmpty.length === 0 && proxies.length > 0) {
        firstNonEmpty = proxies;
      }
    } catch (e) {
      lastError = String(e);
    }
  }

  // If soldOnly was requested but no sold results are discoverable, return active proxies.
  if (firstNonEmpty.length > 0) return { ok: true, items: firstNonEmpty };
  return { ok: false, error: lastError || "No Vinted items returned" };
}

function parseVintedApiItem(item: VintedApiItem): ParsedVintedItem | null {
  const price = extractPrice(item);
  if (price == null || price <= 0) return null;

  const rawSold = item.sold_at ?? item.soldAt ?? item.soldDate ?? null;
  const soldAt = normalizeSoldAt(rawSold);

  const url = item.url ??
    (item.path ? `https://www.vinted.se${item.path}` : null);
  return {
    platform: "vinted",
    price,
    soldAt,
    url,
    title: item.title ?? null,
  };
}

function extractPrice(item: VintedApiItem): number | null {
  if (typeof item.price === "number") return Math.round(item.price);
  if (typeof item.price === "object" && item.price != null) {
    const amount = item.price.amount;
    if (typeof amount === "number") return Math.round(amount);
    if (typeof amount === "string") {
      const parsed = parseFloat(amount.replace(",", "."));
      return isNaN(parsed) ? null : Math.round(parsed);
    }
  }
  return null;
}

function normalizeSoldAt(
  value: string | number | null | undefined,
): string | null {
  if (value == null) return null;
  if (typeof value === "number") {
    // Vinted sometimes uses Unix seconds.
    const ms = value < 10_000_000_000 ? value * 1000 : value;
    return new Date(ms).toISOString();
  }
  const trimmed = value.trim();
  if (!trimmed) return null;
  const n = Number(trimmed);
  if (Number.isFinite(n)) return normalizeSoldAt(n);
  const d = new Date(trimmed);
  return Number.isNaN(d.getTime()) ? null : d.toISOString();
}

function extractSetCookieHeader(headers: Headers): string {
  // Deno/Fetch doesn't expose getSetCookie everywhere.  Try both forms.
  const anyHeaders = headers as unknown as { getSetCookie?: () => string[] };
  const arr = typeof anyHeaders.getSetCookie === "function"
    ? anyHeaders.getSetCookie()
    : [];
  if (arr.length > 0) return arr.map((c) => c.split(";")[0]).join("; ");
  const single = headers.get("set-cookie") ?? "";
  return single
    .split(/,(?=\s*[^=;,]+=[^;,]+)/g)
    .map((c) => c.trim().split(";")[0])
    .filter(Boolean)
    .join("; ");
}

function isBotChallenge(html: string): boolean {
  const s = html.toLowerCase();
  return s.includes("datadome") || s.includes("captcha") ||
    s.includes("cloudflare") || s.includes("cf-challenge");
}

// ── Apify fallback path ──────────────────────────────────────────────────────

async function fetchViaApify(args: {
  query: string;
  maxResults: number;
  apifyToken: string;
  actorId: string;
  doFetch: FetchLike;
}): Promise<
  { ok: true; items: ParsedVintedItem[] } | { ok: false; error: string }
> {
  const { query, maxResults, apifyToken, actorId, doFetch } = args;
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
      return { ok: false, error: `Apify start failed: ${runResponse.status}` };
    }

    const runData = await runResponse.json() as {
      data?: { id?: string; defaultDatasetId?: string };
    };
    const runId = runData.data?.id;
    const datasetId = runData.data?.defaultDatasetId;
    if (!runId || !datasetId) return { ok: false, error: "Apify no run ID" };

    const rawItems = await pollForApifyResults(
      runId,
      datasetId,
      apifyToken,
      doFetch,
    );
    const items = rawItems
      .map(parseVintedApiItem)
      .filter((i): i is ParsedVintedItem => i != null);
    return { ok: true, items };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
}

async function pollForApifyResults(
  runId: string,
  datasetId: string,
  apifyToken: string,
  doFetch: FetchLike,
  maxAttempts = 20,
  pollIntervalMs = 2000,
): Promise<VintedApiItem[]> {
  for (let i = 0; i < maxAttempts; i++) {
    await new Promise((resolve) => setTimeout(resolve, pollIntervalMs));
    const statusResp = await doFetch(
      `https://api.apify.com/v2/actor-runs/${runId}`,
      {
        headers: { Authorization: `Bearer ${apifyToken}` },
      },
    );
    if (!statusResp.ok) continue;
    const statusData = await statusResp.json() as {
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
      return Array.isArray(items) ? items as VintedApiItem[] : [];
    }
    if (status === "FAILED" || status === "ABORTED" || status === "TIMED-OUT") {
      return [];
    }
  }
  return [];
}

// ── HTTP helpers ─────────────────────────────────────────────────────────────

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
