#!/usr/bin/env -S deno run --allow-net --allow-env --allow-write
/**
 * Harvest Swedish children's books from Libris (KB national bibliography).
 * Filters by intendedAudience=Juvenile (marc:j) — 367k+ records.
 * Outputs NDJSON: one book per line with isbn, title, author, year, coverUrl.
 *
 * Usage:
 *   deno run --allow-net --allow-write --allow-env scripts/seed/fetch_libris_children_books.ts
 *
 * Optional env:
 *   LIBRIS_OUT  – output path (default: scrape_output/libris_children_books.ndjson)
 *   LIBRIS_MAX  – max records (default: 50000)
 */

const BASE = "https://libris.kb.se/find";
const JUVENILE_ID = "https://id.kb.se/marc/Juvenile";
const PAGE_SIZE = 200;
const UA = "BokfyndBot/1.0 (+https://bokfynd.se)";
const DEFAULT_MAX = 50_000;

interface LibrisDoc {
  isbn?: string;
  title?: string;
  author?: string;
  year?: number;
  coverUrl?: string;
}

function extractIsbn(identifiedBy: unknown): string | undefined {
  if (!Array.isArray(identifiedBy)) return undefined;
  for (const id of identifiedBy as Record<string, unknown>[]) {
    if (id["@type"] === "ISBN" && typeof id.value === "string") {
      const raw = (id.value as string).replace(/[^0-9X]/gi, "").toUpperCase();
      if (raw.length === 13) return raw; // prefer ISBN-13
    }
  }
  for (const id of identifiedBy as Record<string, unknown>[]) {
    if (id["@type"] === "ISBN" && typeof id.value === "string") {
      const raw = (id.value as string).replace(/[^0-9X]/gi, "").toUpperCase();
      if (raw.length === 10) return raw;
    }
  }
  return undefined;
}

function extractTitle(hasTitle: unknown): string | undefined {
  if (!Array.isArray(hasTitle) || hasTitle.length === 0) return undefined;
  const t = (hasTitle as Record<string, unknown>[])[0];
  if (typeof t.mainTitle === "string") return t.mainTitle.trim();
  return undefined;
}

function extractAuthor(instanceOf: unknown): string | undefined {
  if (!instanceOf || typeof instanceOf !== "object") return undefined;
  const inst = instanceOf as Record<string, unknown>;
  const contributions = Array.isArray(inst.contribution) ? inst.contribution as Record<string, unknown>[] : [];
  for (const c of contributions) {
    const agent = c.agent as Record<string, unknown> | undefined;
    if (agent && typeof agent.label === "string") return agent.label.trim();
    if (agent && typeof agent.name === "string") return agent.name.trim();
  }
  return undefined;
}

function extractYear(publication: unknown): number | undefined {
  if (!Array.isArray(publication)) return undefined;
  for (const p of publication as Record<string, unknown>[]) {
    if (typeof p.year === "string") {
      const y = parseInt(p.year, 10);
      if (y > 1800 && y <= new Date().getFullYear()) return y;
    }
  }
  return undefined;
}

function extractCover(image: unknown): string | undefined {
  if (!Array.isArray(image) || image.length === 0) return undefined;
  const img = (image as Record<string, unknown>[])[0];
  if (typeof img["@id"] === "string") return img["@id"] as string;
  return undefined;
}

async function fetchPage(offset: number): Promise<{ items: LibrisDoc[]; total: number }> {
  const url = new URL(BASE);
  url.searchParams.set("instanceOf.intendedAudience.@id", JUVENILE_ID);
  url.searchParams.set("_limit", String(PAGE_SIZE));
  url.searchParams.set("_offset", String(offset));

  const res = await fetch(url.toString(), {
    headers: { "User-Agent": UA, "Accept": "application/json" },
  });
  if (!res.ok) throw new Error(`Libris HTTP ${res.status} at offset ${offset}`);

  const data = await res.json() as Record<string, unknown>;
  const total = typeof data.totalItems === "number" ? data.totalItems : 0;
  const rawItems = Array.isArray(data.items) ? data.items as Record<string, unknown>[] : [];

  const items: LibrisDoc[] = [];
  for (const node of rawItems) {
    const isbn = extractIsbn(node.identifiedBy);
    const title = extractTitle(node.hasTitle);
    if (!title) continue;

    items.push({
      isbn,
      title,
      author: extractAuthor(node.instanceOf),
      year: extractYear(node.publication),
      coverUrl: extractCover(node.image),
    });
  }

  return { items, total };
}

const outPath = Deno.env.get("LIBRIS_OUT") ?? "scrape_output/libris_children_books.ndjson";
const maxRecords = Deno.env.get("LIBRIS_MAX") ? parseInt(Deno.env.get("LIBRIS_MAX")!, 10) : DEFAULT_MAX;

await Deno.mkdir(outPath.substring(0, outPath.lastIndexOf("/")), { recursive: true });
const file = await Deno.open(outPath, { write: true, create: true, truncate: true });
const enc = new TextEncoder();

let offset = 0;
let total = 0;
let written = 0;

do {
  const page = await fetchPage(offset);
  if (offset === 0) {
    total = page.total;
    console.log(`Libris total juvenile records: ${total} — harvesting up to ${maxRecords}`);
  }

  for (const item of page.items) {
    await file.write(enc.encode(JSON.stringify(item) + "\n"));
    written++;
    if (written >= maxRecords) break;
  }

  console.log(`offset=${offset} fetched=${page.items.length} written=${written}`);
  offset += PAGE_SIZE;

  await new Promise(r => setTimeout(r, 300));
} while (offset < total && written < maxRecords);

file.close();
console.log(`✓ Done. Wrote ${written} books to ${outPath}`);
