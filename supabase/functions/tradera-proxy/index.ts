import { buildSearchAdvancedEnvelope, buildSearchAdvancedRequestXml } from "./soap.ts";
import { parseSearchAdvancedResponse } from "./parse.ts";
import type { TraderaProxyRequest } from "./types.ts";

const TRADERA_ENDPOINT = "https://api.tradera.com/v3/searchservice.asmx";
const SOAP_ACTION = "http://api.tradera.com/SearchAdvanced";

const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  let body: TraderaProxyRequest;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const searchWords = (body?.searchWords ?? "").trim();
  if (searchWords.length < 2 || searchWords.length > 80) {
    return json({ error: "searchWords must be 2..80 chars" }, 400);
  }

  const appIdStr = Deno.env.get("TRADERA_APP_ID") ?? "";
  const appKey = Deno.env.get("TRADERA_APP_KEY") ?? "";
  const sandboxStr = Deno.env.get("TRADERA_SANDBOX") ?? "0";
  const maxResultAgeStr = Deno.env.get("TRADERA_MAX_RESULT_AGE") ?? "0";

  const appId = Number.parseInt(appIdStr, 10);
  const sandbox = Number.parseInt(sandboxStr, 10);
  const maxResultAge = Number.parseInt(maxResultAgeStr, 10);

  if (!Number.isFinite(appId) || appId <= 0 || !appKey) {
    return json(
      {
        error:
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

  const traderaResp = await fetch(TRADERA_ENDPOINT, {
    method: "POST",
    headers: {
      "content-type": "text/xml; charset=utf-8",
      "soapaction": `"${SOAP_ACTION}"`,
    },
    body: soapEnvelope,
  });

  const xml = await traderaResp.text();
  if (!traderaResp.ok) {
    return json(
      {
        error: "Tradera request failed",
        status: traderaResp.status,
        body: xml.slice(0, 2000),
      },
      502,
    );
  }

  try {
    const parsed = parseSearchAdvancedResponse(xml);
    return json(parsed, 200);
  } catch (e) {
    return json(
      {
        error: "Failed to parse Tradera SOAP response",
        detail: String(e),
      },
      502,
    );
  }
});

function json(data: unknown, status: number): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json" },
  });
}
