import type { CloudAiProxyRequest, CloudAiProxyResponse } from "./types.ts";

const GEMINI_API_BASE = "https://generativelanguage.googleapis.com";
const DEFAULT_GEMINI_MODEL = "gemini-2.5-flash";

const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
};

export const LIMITS = {
  // Hard guard against obviously huge request bodies.
  // (Base64 expands bytes by ~4/3, plus JSON overhead)
  maxBodyChars: 2_800_000,
  maxPromptChars: 8_000,
  // Base64 chars budget for a JPEG crop (bytes only, no prefix)
  maxImageBase64Chars: 2_000_000,
  // Upper bound for upstream response we embed into `raw`.
  // Upper bound for upstream response we embed into `raw`.
  maxRawJsonChars: 50_000,
  // Timeout for the upstream Gemini API call (ms).
  geminiTimeoutMs: 30_000,
} as const;
type EnvProvider = {
  get: (key: string) => string | undefined;
};

type FetchLike = (
  input: RequestInfo | URL,
  init?: RequestInit,
) => Promise<Response>;

type AuthVerifier = (
  jwt: string,
) => Promise<{ userId: string } | null>;

type Deps = {
  env?: EnvProvider;
  fetch?: FetchLike;
  verifyAuth?: AuthVerifier;
};
export async function handleRequest(
  req: Request,
  deps: Deps = {},
): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  // ── Auth gate: require a valid Supabase JWT ──
  const env = deps.env ?? { get: (k: string) => Deno.env.get(k) };
  const verifyAuth = deps.verifyAuth ?? createSupabaseAuthVerifier(env);

  const authHeader = (req.headers.get("authorization") ?? "").trim();
  const jwt = authHeader.toLowerCase().startsWith("bearer ")
    ? authHeader.slice("bearer ".length).trim()
    : "";
  if (!jwt) {
    return json({ error: "Missing bearer token" }, 401);
  }

  const authResult = await verifyAuth(jwt);
  if (!authResult) {
    return json({ error: "Unauthorized" }, 401);
  }

  let bodyText = "";
  try {
    bodyText = await req.text();
  } catch {
    return json({ error: "Invalid request body" }, 400);
  }

  if (bodyText.length > LIMITS.maxBodyChars) {
    return json({ error: "Payload too large" }, 413);
  }

  let body: CloudAiProxyRequest;
  try {
    body = JSON.parse(bodyText) as CloudAiProxyRequest;
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const requestId = typeof body?.requestId === "string"
    ? body.requestId
    : undefined;

  const prompt = (body?.prompt ?? "").trim();
  if (!prompt) {
    return json({ error: "prompt is required", requestId }, 400);
  }
  if (prompt.length > LIMITS.maxPromptChars) {
    return json({ error: "prompt is too long", requestId }, 400);
  }

  const imageBase64Jpeg = (body?.imageBase64Jpeg ?? "").trim();
  if (!imageBase64Jpeg) {
    return json({ error: "imageBase64Jpeg is required", requestId }, 400);
  }
  if (imageBase64Jpeg.startsWith("data:")) {
    return json(
      {
        error: "imageBase64Jpeg must be base64 bytes only (no data: prefix)",
        requestId,
      },
      400,
    );
  }
  if (imageBase64Jpeg.length > LIMITS.maxImageBase64Chars) {
    return json({ error: "Payload too large", requestId }, 413);
  }
  if (!isBase64(imageBase64Jpeg)) {
    return json(
      { error: "imageBase64Jpeg must be valid base64", requestId },
      400,
    );
  }

  const apiKey = (env.get("GEMINI_API_KEY") ?? "").trim();
  const model = (env.get("GEMINI_MODEL") ?? DEFAULT_GEMINI_MODEL).trim() ||
    DEFAULT_GEMINI_MODEL;

  if (!apiKey) {
    return json(
      {
        error:
          "Server not configured. Set GEMINI_API_KEY (and optionally GEMINI_MODEL) in Supabase secrets.",
        requestId,
      },
      500,
    );
  }

  const maxTokens = normalizeMaxTokens(body?.maxTokens);

  const upstream = await callGemini(
    {
      apiKey,
      model,
      prompt,
      imageBase64Jpeg,
      maxTokens,
    },
    deps.fetch,
  );

  if (upstream.ok) {
    const raw = truncateRaw(upstream.raw);
    const response: CloudAiProxyResponse = {
      text: upstream.text,
      raw,
      requestId,
    };
    return json(response, 200);
  }

  return json(
    {
      error: upstream.error,
      requestId,
    } satisfies CloudAiProxyResponse,
    upstream.status,
  );
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

function normalizeMaxTokens(value: unknown): number {
  if (typeof value !== "number" || !Number.isFinite(value)) return 512;
  const v = Math.floor(value);
  if (v < 1) return 1;
  if (v > 4096) return 4096;
  return v;
}

function isBase64(s: string): boolean {
  // Minimal sanity check: valid base64 charset only.
  return /^[A-Za-z0-9+/=]+$/.test(s);
}

function truncateRaw(value: unknown): unknown {
  try {
    const jsonStr = JSON.stringify(value);
    if (jsonStr.length <= LIMITS.maxRawJsonChars) return value;
    return {
      truncated: true,
      json: jsonStr.slice(0, LIMITS.maxRawJsonChars),
    };
  } catch {
    return { truncated: true, json: "<unserializable>" };
  }
}

async function callGemini(
  args: {
    apiKey: string;
    model: string;
    prompt: string;
    imageBase64Jpeg: string;
    maxTokens: number;
  },
  fetchImpl?: FetchLike,
): Promise<
  | { ok: true; text: string; raw: unknown }
  | { ok: false; status: number; error: string }
> {
  const doFetch = fetchImpl ?? fetch;
  const url = `${GEMINI_API_BASE}/v1beta/models/${
    encodeURIComponent(args.model)
  }:generateContent?key=${encodeURIComponent(args.apiKey)}`;

  const basePayload = {
    contents: [
      {
        role: "user",
        parts: [
          { text: args.prompt },
          {
            inline_data: {
              mime_type: "image/jpeg",
              data: args.imageBase64Jpeg,
            },
          },
        ],
      },
    ],
    generationConfig: {
      // Important: On Gemini 2.5, hidden "thinking" tokens can consume most
      // of the output budget, producing truncated JSON. We explicitly set a
      // low temperature and attempt to disable thinking, with a safe fallback.
      maxOutputTokens: args.maxTokens,
    },
  };

  const payloads: Array<Record<string, unknown>> = [
    {
      ...basePayload,
      generationConfig: {
        ...(basePayload.generationConfig as Record<string, unknown>),
        temperature: 0.0,
        responseMimeType: "application/json",
        thinkingConfig: {
          thinkingBudget: 0,
        },
      },
    },
    {
      ...basePayload,
      generationConfig: {
        ...(basePayload.generationConfig as Record<string, unknown>),
        temperature: 0.0,
        responseMimeType: "application/json",
      },
    },
    basePayload as unknown as Record<string, unknown>,
  ];

  let lastError: string | null = null;

  for (const payload of payloads) {
    let resp: Response;
    try {
      resp = await doFetch(url, {
        method: "POST",
        headers: {
          "content-type": "application/json",
        },
        body: JSON.stringify(payload),
      });
    } catch (e) {
      lastError = `Gemini request failed: ${String(e)}`;
      continue;
    }

    const respText = await resp.text();

    if (!resp.ok) {
      // If the API rejects newer JSON/thinking fields, retry with a simpler payload.
      if (
        resp.status === 400 &&
        (respText.includes("Unknown name") ||
          respText.includes("Invalid JSON payload") ||
          respText.includes("Unrecognized") ||
          respText.includes("cannot find field"))
      ) {
        lastError = `Gemini request rejected (${resp.status}): ${respText.slice(0, 2000)}`;
        continue;
      }

      return {
        ok: false,
        status: 502,
        error: `Gemini request failed (${resp.status}): ${respText.slice(0, 2000)}`,
      };
    }

    let raw: unknown;
    try {
      raw = JSON.parse(respText);
    } catch {
      raw = { text: respText.slice(0, 2000) };
    }

    const text = extractTextFromGeminiResponse(raw);
    if (!text) {
      return {
        ok: false,
        status: 502,
        error: "Gemini response missing candidate text",
      };
    }

    return { ok: true, text, raw };
  }

  return {
    ok: false,
    status: 502,
    error: lastError ?? "Gemini request failed",
  };
}

function extractTextFromGeminiResponse(raw: unknown): string {
  const root = asRecord(raw);
  if (!root) return "";

  const candidates = root["candidates"];
  if (!Array.isArray(candidates) || candidates.length === 0) return "";

  const cand0 = asRecord(candidates[0]);
  if (!cand0) return "";

  const content = asRecord(cand0["content"]);
  if (!content) return "";

  const parts = content["parts"];
  if (!Array.isArray(parts)) return "";

  let out = "";
  for (const part of parts) {
    const p = asRecord(part);
    const text = p?.["text"];
    if (typeof text === "string") out += text;
  }

  return out.trim();
}

function asRecord(value: unknown): Record<string, unknown> | null {
  if (!value || typeof value !== "object") return null;
  return value as Record<string, unknown>;
}

function createSupabaseAuthVerifier(env: EnvProvider): AuthVerifier {
  return async (jwt: string) => {
    const supabaseUrl = (env.get("SUPABASE_URL") ?? "").trim();
    const supabaseAnonKey = (env.get("SUPABASE_ANON_KEY") ?? "").trim();
    if (!supabaseUrl || !supabaseAnonKey) {
      return { userId: "unknown" };
    }

    try {
      const resp = await fetch(`${supabaseUrl}/auth/v1/user`, {
        headers: {
          authorization: `Bearer ${jwt}`,
          apikey: supabaseAnonKey,
        },
      });
      if (!resp.ok) return null;
      const data = (await resp.json()) as Record<string, unknown>;
      const id = typeof data.id === "string" ? data.id : null;
      if (!id) return null;
      return { userId: id };
    } catch {
      return null;
    }
  };
}
