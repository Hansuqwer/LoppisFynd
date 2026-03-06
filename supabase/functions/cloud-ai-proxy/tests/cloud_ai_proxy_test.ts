import { handleRequest, LIMITS } from "../index.ts";

const authorizedHeaders = {
  authorization: "Bearer test-jwt",
  "content-type": "application/json",
};

const allowAuth = {
  verifyAuth: async () => ({ userId: "test-user" }),
};

Deno.test("OPTIONS returns 204 + CORS headers", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/cloud-ai-proxy", { method: "OPTIONS" }),
  );
  if (resp.status !== 204) throw new Error(`expected 204, got ${resp.status}`);
  if (resp.headers.get("access-control-allow-origin") !== "*") {
    throw new Error("missing CORS allow-origin");
  }
  if (!resp.headers.get("access-control-allow-methods")?.includes("POST")) {
    throw new Error("missing CORS allow-methods");
  }
});

Deno.test("non-POST returns 405", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/cloud-ai-proxy", { method: "GET" }),
  );
  if (resp.status !== 405) throw new Error(`expected 405, got ${resp.status}`);
});

Deno.test("invalid JSON returns 400", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/cloud-ai-proxy", {
      method: "POST",
      headers: authorizedHeaders,
      body: "{",
    }),
    allowAuth,
  );
  if (resp.status !== 400) throw new Error(`expected 400, got ${resp.status}`);
});

Deno.test("missing/empty prompt returns 400", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/cloud-ai-proxy", {
      method: "POST",
      headers: authorizedHeaders,
      body: JSON.stringify({ prompt: "", imageBase64Jpeg: "aGVsbG8=" }),
    }),
    allowAuth,
  );
  if (resp.status !== 400) throw new Error(`expected 400, got ${resp.status}`);
});

Deno.test("missing/empty imageBase64Jpeg returns 400", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/cloud-ai-proxy", {
      method: "POST",
      headers: authorizedHeaders,
      body: JSON.stringify({ prompt: "hi", imageBase64Jpeg: "" }),
    }),
    allowAuth,
  );
  if (resp.status !== 400) throw new Error(`expected 400, got ${resp.status}`);
});

Deno.test("oversized payload returns 413", async () => {
  const tooLarge = "a".repeat(LIMITS.maxImageBase64Chars + 1);
  const resp = await handleRequest(
    new Request("http://localhost/cloud-ai-proxy", {
      method: "POST",
      headers: authorizedHeaders,
      body: JSON.stringify({ prompt: "hi", imageBase64Jpeg: tooLarge }),
    }),
    allowAuth,
  );
  if (resp.status !== 413) throw new Error(`expected 413, got ${resp.status}`);
});

Deno.test("missing bearer token returns 401", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/cloud-ai-proxy", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ prompt: "hi", imageBase64Jpeg: "aGVsbG8=" }),
    }),
  );
  if (resp.status !== 401) throw new Error(`expected 401, got ${resp.status}`);
});

Deno.test("invalid bearer token returns 401", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/cloud-ai-proxy", {
      method: "POST",
      headers: authorizedHeaders,
      body: JSON.stringify({ prompt: "hi", imageBase64Jpeg: "aGVsbG8=" }),
    }),
    { verifyAuth: async () => null },
  );
  if (resp.status !== 401) throw new Error(`expected 401, got ${resp.status}`);
});
