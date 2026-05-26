import { handleRequest } from "../index.ts";

function fakeEnv(
  overrides: Record<string, string> = {},
): { get: (key: string) => string | undefined } {
  const defaults: Record<string, string> = {
    SUPABASE_URL: "http://localhost:54321",
    SUPABASE_SERVICE_ROLE_KEY: "test-service-role-key",
    ...overrides,
  };
  return { get: (k: string) => defaults[k] };
}

type AdminOverrides = {
  getUser?: (jwt: string) => Promise<{ data: { user: { id: string } | null }; error: unknown }>;
  deleteUser?: (id: string) => Promise<{ error: unknown }>;
  selectScanItems?: (col: string, val: string) => Promise<{ data: unknown[] | null; error: unknown }>;
  deleteScanItems?: (col: string, val: string) => Promise<{ error: unknown }>;
  deleteHauls?: (col: string, val: string) => Promise<{ error: unknown }>;
  storageRemove?: (paths: string[]) => Promise<unknown>;
};

function fakeAdmin(overrides: AdminOverrides = {}) {
  const getUser = overrides.getUser ??
    (async () => ({ data: { user: { id: "user-123" } }, error: null }));
  const deleteUser = overrides.deleteUser ??
    (async () => ({ error: null }));
  const selectScanItems = overrides.selectScanItems ??
    (async () => ({ data: [], error: null }));
  const deleteScanItems = overrides.deleteScanItems ??
    (async () => ({ error: null }));
  const deleteHauls = overrides.deleteHauls ??
    (async () => ({ error: null }));
  const storageRemove = overrides.storageRemove ??
    (async () => ({}));

  return {
    auth: {
      getUser,
      admin: { deleteUser },
    },
    from: (table: string) => ({
      select: (_cols: string) => ({
        eq: (col: string, val: string) => {
          if (table === "scan_items") return selectScanItems(col, val);
          return Promise.resolve({ data: [], error: null });
        },
      }),
      delete: () => ({
        eq: (col: string, val: string) => {
          if (table === "scan_items") return deleteScanItems(col, val);
          if (table === "hauls") return deleteHauls(col, val);
          return Promise.resolve({ error: null });
        },
      }),
    }),
    storage: {
      from: (_bucket: string) => ({
        remove: storageRemove,
      }),
    },
  };
}

function postReq(headers?: Record<string, string>): Request {
  return new Request("http://localhost/account-delete", {
    method: "POST",
    headers: {
      authorization: "Bearer valid-test-jwt",
      ...headers,
    },
  });
}

Deno.test("OPTIONS returns 204 + CORS headers", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/account-delete", { method: "OPTIONS" }),
  );
  if (resp.status !== 204) throw new Error(`expected 204, got ${resp.status}`);
  if (resp.headers.get("access-control-allow-origin") !== "*") {
    throw new Error("missing CORS allow-origin");
  }
  if (!resp.headers.get("access-control-allow-methods")?.includes("POST")) {
    throw new Error("missing CORS allow-methods POST");
  }
});

Deno.test("GET returns 405 method not allowed", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/account-delete", { method: "GET" }),
  );
  if (resp.status !== 405) throw new Error(`expected 405, got ${resp.status}`);
  const body = await resp.json();
  if (!body.error) throw new Error("missing error field");
});

Deno.test("missing bearer token returns 401", async () => {
  const resp = await handleRequest(
    new Request("http://localhost/account-delete", {
      method: "POST",
      headers: {},
    }),
    { env: fakeEnv(), adminClient: fakeAdmin() },
  );
  if (resp.status !== 401) throw new Error(`expected 401, got ${resp.status}`);
  const body = await resp.json();
  if (body.error !== "Missing bearer token") {
    throw new Error(`wrong error: ${body.error}`);
  }
});

Deno.test("invalid JWT returns 401", async () => {
  const resp = await handleRequest(
    postReq(),
    {
      env: fakeEnv(),
      adminClient: fakeAdmin({
        getUser: async () => ({ data: { user: null }, error: "invalid token" }),
      }),
    },
  );
  if (resp.status !== 401) throw new Error(`expected 401, got ${resp.status}`);
  const body = await resp.json();
  if (body.error !== "Unauthorized") {
    throw new Error(`wrong error: ${body.error}`);
  }
});

Deno.test("server not configured returns 500 when env vars missing", async () => {
  const resp = await handleRequest(
    postReq(),
    { env: { get: () => undefined }, adminClient: fakeAdmin() },
  );
  if (resp.status !== 500) throw new Error(`expected 500, got ${resp.status}`);
  const body = await resp.json();
  if (!body.error?.includes("not configured")) {
    throw new Error(`wrong error: ${body.error}`);
  }
});

Deno.test("success path - all ops succeed returns 200 ok", async () => {
  const resp = await handleRequest(
    postReq(),
    { env: fakeEnv(), adminClient: fakeAdmin() },
  );
  if (resp.status !== 200) throw new Error(`expected 200, got ${resp.status}`);
  const body = await resp.json();
  if (body.ok !== true) throw new Error("expected ok: true");
  if (body.storageError !== null) {
    throw new Error(`expected storageError null, got ${body.storageError}`);
  }
});

Deno.test("success path - storage failure returns 200 with storageError", async () => {
  const resp = await handleRequest(
    postReq(),
    {
      env: fakeEnv(),
      adminClient: fakeAdmin({
        selectScanItems: async () => ({
          data: [{ id: "scan-1" }, { id: "scan-2" }],
          error: null,
        }),
        storageRemove: async () => {
          throw new Error("bucket unreachable");
        },
      }),
    },
  );
  if (resp.status !== 200) throw new Error(`expected 200, got ${resp.status}`);
  const body = await resp.json();
  if (body.ok !== true) throw new Error("expected ok: true");
  if (typeof body.storageError !== "string") {
    throw new Error("expected storageError to be a string");
  }
  if (!body.storageError.includes("bucket unreachable")) {
    throw new Error(`wrong storageError: ${body.storageError}`);
  }
});

Deno.test("scan_items delete failure returns 500", async () => {
  const resp = await handleRequest(
    postReq(),
    {
      env: fakeEnv(),
      adminClient: fakeAdmin({
        deleteScanItems: async () => ({ error: "scan delete failed" }),
      }),
    },
  );
  if (resp.status !== 500) throw new Error(`expected 500, got ${resp.status}`);
  const body = await resp.json();
  if (!body.error?.includes("scan delete failed")) {
    throw new Error(`wrong error: ${body.error}`);
  }
});

Deno.test("hauls delete failure returns 500", async () => {
  const resp = await handleRequest(
    postReq(),
    {
      env: fakeEnv(),
      adminClient: fakeAdmin({
        deleteHauls: async () => ({ error: "hauls delete failed" }),
      }),
    },
  );
  if (resp.status !== 500) throw new Error(`expected 500, got ${resp.status}`);
  const body = await resp.json();
  if (!body.error?.includes("hauls delete failed")) {
    throw new Error(`wrong error: ${body.error}`);
  }
});

Deno.test("deleteUser failure returns 500", async () => {
  const resp = await handleRequest(
    postReq(),
    {
      env: fakeEnv(),
      adminClient: fakeAdmin({
        deleteUser: async () => ({ error: "user delete failed" }),
      }),
    },
  );
  if (resp.status !== 500) throw new Error(`expected 500, got ${resp.status}`);
  const body = await resp.json();
  if (!body.error?.includes("user delete failed")) {
    throw new Error(`wrong error: ${body.error}`);
  }
});
