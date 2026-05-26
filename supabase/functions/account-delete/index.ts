import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type EnvProvider = { get: (key: string) => string | undefined };

type AdminClient = {
  auth: {
    getUser: (
      jwt: string,
    ) => Promise<{ data: { user: { id: string } | null }; error: unknown }>;
    admin: {
      deleteUser: (id: string) => Promise<{ error: unknown }>;
    };
  };
  from: (table: string) => {
    select: (cols: string) => {
      eq: (
        col: string,
        val: string,
      ) => Promise<{ data: unknown[] | null; error: unknown }>;
    };
    delete: () => {
      eq: (col: string, val: string) => Promise<{ error: unknown }>;
    };
  };
  storage: {
    from: (bucket: string) => {
      remove: (paths: string[]) => Promise<unknown>;
    };
  };
};

type Deps = {
  env?: EnvProvider;
  adminClient?: AdminClient;
};

const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
};

const BUCKET_ID = "scan-photos";

export async function handleRequest(
  req: Request,
  deps?: Deps,
): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const env = deps?.env ?? Deno.env;
  const supabaseUrl = env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!supabaseUrl || !serviceRoleKey) {
    return json(
      {
        error:
          "Server not configured. Set SUPABASE_SERVICE_ROLE_KEY in Supabase secrets.",
      },
      500,
    );
  }

  const authHeader = req.headers.get("authorization") ?? "";
  const jwt = authHeader.toLowerCase().startsWith("bearer ")
    ? authHeader.slice(7)
    : "";
  if (!jwt) {
    return json({ error: "Missing bearer token" }, 401);
  }

  const admin: AdminClient = deps?.adminClient ??
    createClient(supabaseUrl, serviceRoleKey) as unknown as AdminClient;

  const { data: userData, error: userErr } = await admin.auth.getUser(jwt);
  if (userErr || !userData?.user) {
    return json({ error: "Unauthorized" }, 401);
  }

  const userId = userData.user.id;

  const { data: scanRows, error: scanErr } = await admin
    .from("scan_items")
    .select("id")
    .eq("user_id", userId);
  if (scanErr) {
    return json({ error: String(scanErr) }, 500);
  }

  const scanIds = (scanRows ?? [])
    .map((r: any) => (typeof r?.id === "string" ? r.id : ""))
    .filter((id: string) => id.length > 0);

  let storageError: string | null = null;
  try {
    if (scanIds.length > 0) {
      const paths: string[] = [];
      for (const id of scanIds) {
        paths.push(`${userId}/scan_items/${id}/image.jpg`);
        paths.push(`${userId}/scan_items/${id}/thumb.jpg`);
      }

      const batchSize = 50;
      for (let i = 0; i < paths.length; i += batchSize) {
        const batch = paths.slice(i, i + batchSize);
        await admin.storage.from(BUCKET_ID).remove(batch);
      }
    }
  } catch (e) {
    console.error("account-delete storage cleanup failed", e);
    storageError = String(e);
  }

  const { error: delScanErr } = await admin
    .from("scan_items")
    .delete()
    .eq("user_id", userId);
  if (delScanErr) {
    return json({ error: String(delScanErr) }, 500);
  }

  const { error: delHaulsErr } = await admin
    .from("hauls")
    .delete()
    .eq("user_id", userId);
  if (delHaulsErr) {
    return json({ error: String(delHaulsErr) }, 500);
  }

  const { error: delUserErr } = await admin.auth.admin.deleteUser(userId);
  if (delUserErr) {
    return json({ error: String(delUserErr) }, 500);
  }

  return json({ ok: true, storageError }, 200);
}

if (import.meta.main) {
  Deno.serve((req) => handleRequest(req));
}

function json(data: unknown, status: number): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json" },
  });
}
