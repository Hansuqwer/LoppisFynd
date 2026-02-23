import { buildSearchAdvancedEnvelope, buildSearchAdvancedRequestXml } from "./soap.ts";
import { parseSearchAdvancedResponse } from "./parse.ts";
import type { TraderaProxyRequest, TraderaProxyResponse } from "./types.ts";
import type { TraderaProxyErrorResponse } from "./types.ts";

import { Ratelimit } from "npm:@upstash/ratelimit";
import { Redis } from "npm:@upstash/redis";

const TRADERA_ENDPOINT = "https://api.tradera.com/v3/searchservice.asmx";
const SOAP_ACTION = "http://api.tradera.com/SearchAdvanced";

const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
};

export const LIMITS = {
  // The Tradera proxy request is tiny; guard against abuse via oversized payloads.
  maxBodyChars: 50_000,
} as const;

type EnvProvider = {
  get: (key: string) => string | undefined;
};

type FetchLike = (
  input: RequestInfo | URL,
  init?: RequestInit,
) => Promise<Response>;

type RateLimitResult = {
  allowed: boolean;
  retryAfterSeconds?: number;
};

type Deps = {
  env?: EnvProvider;
  fetch?: FetchLike;
  rateLimit?: (key: string) => Promise<RateLimitResult>;
};

export async function handleRequest(
  req: Request,
  deps: Deps = {},
): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return errorJson(
      {
        code: "method_not_allowed",
        message: "Method not allowed",
      },
      405,
    );
  }

  const env = deps.env ?? { get: (k: string) => Deno.env.get(k) };

  const rateLimit = deps.rateLimit ?? createUpstashRateLimit(env);
  const key = await rateLimitKey(req);

  let rl: RateLimitResult;
  try {
    rl = await rateLimit(key);
  } catch (e) {
    const msg = String(e);
    if (msg.includes("server_not_configured")) {
      return errorJson(
        {
          code: "server_not_configured",
          message:
            "Server not configured. Set UPSTASH_REDIS_REST_URL and UPSTASH_REDIS_REST_TOKEN in Supabase secrets.",
        },
        500,
      );
    }

    return errorJson(
      {
        code: "upstream_failed",
        message: `Rate limiting failed: ${msg}`.slice(0, 2000),
      },
      502,
    );
  }

  if (!rl.allowed) {
    return errorJson(
      {
        code: "rate_limited",
        message: "Too many requests. Try again soon.",
        retryAfterSeconds: rl.retryAfterSeconds,
      },
      429,
      {
        "retry-after":
          typeof rl.retryAfterSeconds === "number" &&
            Number.isFinite(rl.retryAfterSeconds) &&
            rl.retryAfterSeconds > 0
            ? String(Math.ceil(rl.retryAfterSeconds))
            : undefined,
      },
    );
  }

  let bodyText = "";
  try {
    bodyText = await req.text();
  } catch {
    return errorJson(
      {
        code: "invalid_request",
        message: "Invalid request body",
      },
      400,
    );
  }

  if (bodyText.length > LIMITS.maxBodyChars) {
    return errorJson(
      {
        code: "payload_too_large",
        message: "Payload too large",
      },
      413,
    );
  }

  let body: TraderaProxyRequest;
  try {
    body = JSON.parse(bodyText) as TraderaProxyRequest;
  } catch {
    return errorJson(
      {
        code: "invalid_json",
        message: "Invalid JSON",
      },
      400,
    );
  }

  const searchWords = (body?.searchWords ?? "").trim();
  if (searchWords.length < 2 || searchWords.length > 80) {
    return errorJson(
      {
        code: "invalid_request",
        message: "searchWords must be 2..80 chars",
      },
      400,
    );
  }

  const appIdStr = env.get("TRADERA_APP_ID") ?? "";
  const appKey = (env.get("TRADERA_APP_KEY") ?? "").trim();
  const sandboxStr = env.get("TRADERA_SANDBOX") ?? "0";
  const maxResultAgeStr = env.get("TRADERA_MAX_RESULT_AGE") ?? "0";

  const appId = Number.parseInt(appIdStr, 10);
  const sandbox = Number.parseInt(sandboxStr, 10);
  const maxResultAge = Number.parseInt(maxResultAgeStr, 10);

  if (!Number.isFinite(appId) || appId <= 0 || !appKey) {
    return errorJson(
      {
        code: "server_not_configured",
        message:
          "Server not configured. Set TRADERA_APP_ID and TRADERA_APP_KEY in Supabase secrets.",
      },
      500,
    );
  }

  const requestXml = buildSearchAdvancedRequestXml({ ...body, searchWords });
  const soapEnvelope = buildSearchAdvancedEnvelope({
    appId,
    appKey,
    sandbox: Number.isFinite(sandbox) ? sandbox : 0,
    maxResultAge: Number.isFinite(maxResultAge) ? maxResultAge : 0,
    requestXml,
  });

  const doFetch = deps.fetch ?? fetch;
  let traderaResp: Response;
  try {
    traderaResp = await doFetch(TRADERA_ENDPOINT, {
      method: "POST",
      headers: {
        "content-type": "text/xml; charset=utf-8",
        "soapaction": `"${SOAP_ACTION}"`,
      },
      body: soapEnvelope,
    });
  } catch (e) {
    return errorJson(
      {
        code: "upstream_failed",
        message: `Tradera request failed: ${String(e)}`.slice(0, 2000),
      },
      502,
    );
  }

  const xml = await traderaResp.text();
  if (!traderaResp.ok) {
    return errorJson(
      {
        code: "upstream_failed",
        message: `Tradera request failed (${traderaResp.status})`,
      },
      502,
    );
  }

  let parsed: TraderaProxyResponse;
  try {
    parsed = parseSearchAdvancedResponse(xml);
  } catch (e) {
    return errorJson(
      {
        code: "parse_failed",
        message: `Failed to parse Tradera SOAP response: ${String(e)}`.slice(0, 2000),
      },
      502,
    );
  }

  return json(parsed, 200);
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
  error: { code: string; message: string; retryAfterSeconds?: number },
  status: number,
  extraHeaders: Record<string, string | undefined> = {},
): Response {
  const body: TraderaProxyErrorResponse = {
    error: {
      code: error.code,
      message: error.message,
      ...(typeof error.retryAfterSeconds === "number" &&
          Number.isFinite(error.retryAfterSeconds) &&
          error.retryAfterSeconds > 0
        ? { retryAfterSeconds: Math.ceil(error.retryAfterSeconds) }
        : {}),
    },
  };

  const headers = new Headers({
    ...corsHeaders,
    "content-type": "application/json",
    "cache-control": "no-store",
  });
  for (const [k, v] of Object.entries(extraHeaders)) {
    if (v != null && v !== "") headers.set(k, v);
  }

  return new Response(JSON.stringify(body), { status, headers });
}

let upstashRateLimitOnce:
  | ((key: string) => Promise<RateLimitResult>)
  | null = null;

function createUpstashRateLimit(env: EnvProvider): (key: string) => Promise<RateLimitResult> {
  if (upstashRateLimitOnce) return upstashRateLimitOnce;

  const url = (env.get("UPSTASH_REDIS_REST_URL") ?? "").trim();
  const token = (env.get("UPSTASH_REDIS_REST_TOKEN") ?? "").trim();

  if (!url || !token) {
    upstashRateLimitOnce = async () => {
      throw new Error(
        "server_not_configured: Set UPSTASH_REDIS_REST_URL and UPSTASH_REDIS_REST_TOKEN in Supabase secrets",
      );
    };
    return upstashRateLimitOnce;
  }

  // Default policy: 10 requests per minute per key.
  const redis = new Redis({ url, token });
  const limiter = new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(10, "1 m"),
    analytics: true,
  });

  upstashRateLimitOnce = async (key: string) => {
    const result = await limiter.limit(key);
    if (result.success) return { allowed: true };

    // `reset` is a Unix ms timestamp in @upstash/ratelimit.
    const retryAfterSeconds = typeof result.reset === "number" &&
        Number.isFinite(result.reset)
      ? Math.max(1, Math.ceil((result.reset - Date.now()) / 1000))
      : undefined;

    return { allowed: false, retryAfterSeconds };
  };

  return upstashRateLimitOnce;
}

async function rateLimitKey(req: Request): Promise<string> {
  const auth = (req.headers.get("authorization") ?? "").trim();
  if (auth.toLowerCase().startsWith("bearer ")) {
    const token = auth.slice("bearer ".length).trim();
    const sub = tryGetJwtSubWithoutVerify(token);
    if (sub) return `tradera:user:${sub}`;
    const hash = await sha256Hex(token);
    return `tradera:auth:${hash}`;
  }

  const xff = (req.headers.get("x-forwarded-for") ?? "").trim();
  if (xff) {
    const first = xff.split(",")[0]?.trim();
    if (first) return `tradera:ip:${first}`;
  }

  const cf = (req.headers.get("cf-connecting-ip") ?? "").trim();
  if (cf) return `tradera:ip:${cf}`;

  return "tradera:ip:unknown";
}

function tryGetJwtSubWithoutVerify(token: string): string | null {
  // Best-effort only: we do NOT verify JWT signature here.
  const parts = token.split(".");
  if (parts.length !== 3) return null;
  const payload = parts[1] ?? "";

  try {
    const json = JSON.parse(decodeBase64Url(payload)) as Record<string, unknown>;
    return typeof json["sub"] === "string" && json["sub"].trim()
      ? json["sub"].trim()
      : null;
  } catch {
    return null;
  }
}

function decodeBase64Url(input: string): string {
  const normalized = input.replaceAll("-", "+").replaceAll("_", "/");
  const padLen = (4 - (normalized.length % 4)) % 4;
  const padded = normalized + "=".repeat(padLen);
  const bytes = Uint8Array.from(atob(padded), (c) => c.charCodeAt(0));
  return new TextDecoder().decode(bytes);
}

async function sha256Hex(input: string): Promise<string> {
  const bytes = new TextEncoder().encode(input);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  const hashBytes = new Uint8Array(digest);
  let out = "";
  for (const b of hashBytes) out += b.toString(16).padStart(2, "0");
  return out;
}
