import { handleRequest as bokborsen } from "../supabase/functions/bokborsen-scraper/index.ts";
import { handleRequest as blocket } from "../supabase/functions/blocket-scraper/index.ts";
import { handleRequest as vinted } from "../supabase/functions/vinted-scraper/index.ts";
import { handleRequest as tradera } from "../supabase/functions/tradera-proxy/index.ts";

type Item = {
  source: string; query: string; title: string | null;
  price: number | null; url: string | null; soldAt: string | null;
  soldPrice: number | null; isbn: string | null; coverUrl: string | null;
};

const QUERY_POOL: string[] = [
  "Pippi Långstrump bok", "Emil i Lönneberga bok", "Bröderna Lejonhjärta bok",
  "Ronja Rövardotter bok", "Barnen i Bullerbyn bok", "Karlsson på taket bok",
  "Mio min Mio bok", "Madicken bok", "Pettson och Findus bok", "Alfons Åberg bok",
  "Mumin bok", "Bamse bok", "LasseMajas detektivbyrå bok", "Sune bok", "Bert bok",
  "Harry Potter och de vises sten bok", "Harry Potter och hemligheternas kammare bok",
  "Harry Potter och fången från Azkaban bok", "Sagan om ringen bok", "Härskarringen bok",
  "Hobbit bok", "Narnia bok", "Lejonet häxan och garderoben bok",
  "Doktor Glas bok", "Röda rummet bok", "Gösta Berlings saga bok",
  "Utvandrarna Moberg bok", "Invandrarna Moberg bok", "Mina drömmars stad bok",
  "Män som hatar kvinnor bok", "Flickan som lekte med elden bok", "Luftslottet som sprängdes bok",
  "En man som heter Ove bok", "Hundraåringen bok", "Britt-Marie var här bok",
  "Da Vinci koden bok", "Änglar och demoner bok", "Sapiens bok", "Factfulness bok",
  "Atomic Habits bok", "Omgiven av idioter bok", "Låt den rätte komma in bok",
  "Hypnotisören bok", "Sandmannen Kepler bok", "Isprinsessan Läckberg bok",
  "Predikanten Läckberg bok", "Brott och straff bok", "Anna Karenina bok",
  "1984 Orwell bok", "Stolthet och fördom bok", "Jane Eyre bok", "Alkemisten bok",
  "Den lille prinsen bok", "Flyga drake bok", "Tusen strålande solar bok",
  "Kokbok", "Bakbok", "Trädgårdsbok", "Stickbok", "Faktabok historia",
  "Biografi bok", "Deckare pocket", "Roman pocket", "Fantasy bok",
  "Science fiction bok", "Pixibok", "Kapitelbok barn", "Lättläst bok",
  "Engelsk bok", "Tysk bok", "Franska bok", "Spanska bok",
  "Lärobok matematik", "Svenska språket bok",
  "Kalle Anka pocket", "Asterix bok", "Tintin bok",
  "Dagbok för alla mina fans bok", "Percy Jackson bok",
  "Twilight ungdomsbok", "Hungerspelen ungdomsbok", "Cirkeln ungdomsbok",
  "Nalle Puh bok", "Disney barnbok", "Godnattsagor bok",
  "Barnkammarboken", "Lilla spöket Laban bok", "Mulle Meck bok", "Halvan bok",
  "Kapten Kalsong bok", "Super-Charlie bok", "Kråke barnbok",
  "Gittan bok", "Vem-böckerna bok", "Stina Wirsén bok",
  "Loranga Masarin Dartanjang bok", "Kalle och chokladfabriken bok",
  "Matilda Roald Dahl bok", "Max boll bok", "Bu och Bä bok",
  "Nicke Nyfiken bok", "Barbapapa bok", "Babblarna bok",
  "Ture Sventon bok", "Saltkråkan bok", "Lotta på Bråkmakargatan bok",
  "Jakob Wegelius bok", "Mördarens apa bok",
  "Sagor barn", "Klassiska sagor barn", "Barnbokspaket",
];

// ── Book-relevance filter ──────────────────────────────────────────────────────
const stopWords = new Set([
  "och","om","den","det","de","som","p\u00e5","i","en","ett","av",
  "bok","b\u00f6cker","barnbok","ungdomsbok","pocket",
]);
const bookWords = [
  "bok","b\u00f6cker","barnbok","barnb\u00f6cker","pocket","roman","saga","sagor",
  "pixi","bilderbok","kokbok","deckare","ungdomsbok","l\u00e4sebok",
  "f\u00f6rfattare","inbunden","h\u00e4ftad","ljudbok","cd bok",
];
function normalizeText(v: string): string {
  return v.toLowerCase().normalize("NFKD").replace(/[\u0300-\u036f]/g, "");
}
function significantTokens(q: string): string[] {
  return q.toLowerCase().normalize("NFKD").replace(/[\u0300-\u036f]/g, "")
    .split(/[^a-z0-9\u00e5\u00e4\u00f6]+/i)
    .map(t => t.trim()).filter(t => t.length >= 3 && !stopWords.has(t));
}
function isLikelyBook(item: Item): boolean {
  if (item.price == null || item.price <= 0 || item.price > 5000) return false;
  if (item.source === "bokborsen") return true;
  const title = normalizeText(item.title ?? "");
  const hasBW = bookWords.some(w => title.includes(normalizeText(w)));
  if (item.source === "blocket" && !hasBW) return false;
  const tokens = significantTokens(item.query);
  const matches = tokens.filter(t => title.includes(normalizeText(t))).length;
  if (tokens.length >= 2) return matches >= 2 || (matches >= 1 && hasBW);
  return matches >= 1 && hasBW;
}

// ── Dedup ──────────────────────────────────────────────────────────────────────
function normalizeUrl(url: string | null): string | null {
  if (!url) return null;
  try {
    const p = new URL(url);
    p.searchParams.delete("referrer"); p.hash = "";
    return p.toString();
  } catch { return url.trim() || null; }
}
function dedupKey(item: Item): string {
  const url = normalizeUrl(item.url);
  if (url) return `${item.source}|${url}`;
  return `${item.source}|${(item.title ?? "").toLowerCase()}|${item.price ?? ""}`;
}

// ── Scraper helpers ────────────────────────────────────────────────────────────
async function scrapeMarketSource(
  source: string, handler: Function, query: string, max: number,
): Promise<Item[]> {
  const res = await handler(new Request("http://local/", {
    method: "POST", headers: { "content-type": "application/json" },
    body: JSON.stringify({ query, maxResults: max }),
  }), { env: { get: () => undefined } });
  let body: Record<string, unknown>;
  try { body = await res.json(); } catch { body = { items: [] }; }
  return (Array.isArray(body.items) ? body.items : []).map((raw: Record<string, unknown>) => ({
    source, query,
    title: typeof raw.title === "string" ? raw.title : null,
    price: typeof raw.price === "number" ? raw.price : null,
    url: typeof raw.url === "string" ? raw.url : null,
    soldAt: typeof raw.soldAt === "string" ? raw.soldAt : null,
    soldPrice: typeof raw.price === "number" && typeof raw.soldAt === "string" && raw.soldAt ? raw.price : null,
    isbn: null, coverUrl: null,
  }));
}

async function scrapeTraderaSold(query: string, max: number): Promise<Item[]> {
  const res = await tradera(new Request("http://local/", {
    method: "POST", headers: { "content-type": "application/json" },
    body: JSON.stringify({ searchWords: query, itemStatus: "Ended", orderBy: "EndDateDescending", itemsPerPage: max, pageNumber: 1 }),
  }), { env: { get: (k: string) => k === "TRADERA_PUBLIC_FALLBACK" ? "1" : undefined }, rateLimit: async () => ({ allowed: true }) });
  let body: Record<string, unknown>;
  try { body = await res.json(); } catch { body = { items: [] }; }
  return (Array.isArray(body.items) ? body.items : []).map((raw: Record<string, unknown>) => {
    const price = typeof raw.maxBid === "number" ? raw.maxBid : null;
    return {
      source: "tradera", query,
      title: typeof raw.shortDescription === "string" ? raw.shortDescription : null,
      price, url: typeof raw.itemLink === "string" ? raw.itemLink : null,
      soldAt: typeof raw.endDate === "string" ? raw.endDate : null,
      soldPrice: price, isbn: null,
      coverUrl: typeof raw.thumbnailLink === "string" && raw.thumbnailLink ? raw.thumbnailLink : null,
    };
  });
}

const sources: Array<[string, (q: string, m: number) => Promise<Item[]>]> = [
  ["tradera", scrapeTraderaSold],
  ["bokborsen", (q, m) => scrapeMarketSource("bokborsen", bokborsen, q, m)],
  ["vinted", (q, m) => scrapeMarketSource("vinted", vinted, q, m)],
  ["blocket", (q, m) => scrapeMarketSource("blocket", blocket, q, m)],
];

// ── Open Library enrichment ────────────────────────────────────────────────────
type OlResult = { isbn: string | null; coverUrl: string | null };

const olCache = new Map<string, OlResult>();

function cleanForSearch(raw: string): string {
  let t = raw
    .replace(/\s+(av|by)\s+\S.*/i, "")
    .replace(/\s*[-,–—|].*/g, "")
    .replace(/\s+(bok|böcker|pocket|roman|barnbok|ungdomsbok|barnböcker)\s*$/i, "")
    .replace(/\s+(del|del\s*\d+|bok\s*\d+)\s*$/i, "")
    .replace(/\([^)]*\)/g, "")
    .replace(/\s+/g, " ")
    .trim();
  const words = t.split(" ");
  if (words.length > 6) t = words.slice(0, 6).join(" ");
  return t;
}

async function enrichViaOpenLibrary(title: string): Promise<OlResult> {
  const key = normalizeText(title).replace(/\s+/g, " ");
  const cached = olCache.get(key);
  if (cached) return cached;

  try {
    const cleaned = cleanForSearch(title);
    if (!cleaned || cleaned.length < 3) return { isbn: null, coverUrl: null };
    const q = encodeURIComponent(cleaned);
    const resp = await fetch(`https://openlibrary.org/search.json?q=${q}&limit=1`, {
      headers: { "User-Agent": "BokfyndBot/1.0 (cron-scraper; +https://bokfynd.se)" },
    });
    if (!resp.ok) return { isbn: null, coverUrl: null };
    const data = await resp.json() as {
      docs?: Array<{ cover_i?: number; cover_edition_key?: string }>;
    };
    const doc = Array.isArray(data.docs) && data.docs.length > 0 ? data.docs[0] : null;
    if (!doc) { olCache.set(key, { isbn: null, coverUrl: null }); return olCache.get(key)!; }

    // Step 1: cover URL from cover_i
    const coverUrl = typeof doc.cover_i === "number"
      ? `https://covers.openlibrary.org/b/id/${doc.cover_i}-M.jpg`
      : null;

    // Step 2: ISBN-13 from edition endpoint
    let isbn: string | null = null;
    if (doc.cover_edition_key) {
      try {
        await new Promise(r => setTimeout(r, 150)); // gentle rate limit
        const edResp = await fetch(
          `https://openlibrary.org/books/${doc.cover_edition_key}.json`,
          { headers: { "User-Agent": "BokfyndBot/1.0 (cron-scraper; +https://bokfynd.se)" } },
        );
        if (edResp.ok) {
          const ed = await edResp.json() as { isbn_13?: string[]; isbn_10?: string[] };
          isbn = (Array.isArray(ed.isbn_13) && ed.isbn_13[0])
            ? ed.isbn_13[0]
            : (Array.isArray(ed.isbn_10) && ed.isbn_10[0]) ? ed.isbn_10[0] : null;
        }
      } catch { /* ignore */ }
    }

    const result = { isbn, coverUrl };
    olCache.set(key, result);
    return result;
  } catch {
    return { isbn: null, coverUrl: null };
  }
}

async function batchEnrich(items: Item[]): Promise<void> {
  // Group by cleaned title key so one lookup serves many items
  const byTitle = new Map<string, Item[]>();
  for (const item of items) {
    if (!item.title) continue;
    const k = cleanForSearch(item.title);
    if (!k || k.length < 3) continue;
    if (!byTitle.has(k)) byTitle.set(k, []);
    byTitle.get(k)!.push(item);
  }

  let done = 0;
  for (const [, group] of byTitle) {
    const first = group[0];
    if (!first.title) continue;
    // Skip if all items already have both fields
    if (group.every(i => i.isbn && i.coverUrl)) continue;
    const enriched = await enrichViaOpenLibrary(first.title);
    for (const item of group) {
      if (!item.coverUrl && enriched.coverUrl) item.coverUrl = enriched.coverUrl;
      if (!item.isbn && enriched.isbn) item.isbn = enriched.isbn;
    }
    done++;
    // Gentle rate limit: 200ms every 10 unique titles
    if (done % 10 === 0) await new Promise(r => setTimeout(r, 200));
  }
  console.log(`Enriched ${done} unique titles via Open Library`);
}

// ── Load previous dedup ────────────────────────────────────────────────────────
const prevPaths: string[] = [];
if (Deno.args.includes("--prev")) {
  const idx = Deno.args.indexOf("--prev");
  if (idx + 1 < Deno.args.length) prevPaths.push(Deno.args[idx + 1]);
}
const prevSeen = new Set<string>();
for (const pp of prevPaths) {
  try {
    const text = await Deno.readTextFile(pp);
    const data = JSON.parse(text);
    for (const item of data.items) prevSeen.add(dedupKey(item));
    console.log(`Loaded ${prevSeen.size} dedup keys from ${pp}`);
  } catch (e) { console.error(`Skip prev file ${pp}: ${e}`); }
}

// ── Scrape loop ────────────────────────────────────────────────────────────────
const target = 1000;
const seen = new Set<string>();
const items: Item[] = [];
const sourceCounts: Record<string, number> = { tradera: 0, bokborsen: 0, vinted: 0, blocket: 0 };
const queryStats: object[] = [];
const errors: unknown[] = [];
const startedAt = new Date().toISOString();
const startedMs = Date.now();

for (const query of QUERY_POOL) {
  const before = items.length;
  for (const [source, scrape] of sources) {
    const result = await scrape(query, 20).catch(e => {
      errors.push({ query, source, error: String(e) }); return [];
    });
    for (const item of result) {
      if (!isLikelyBook(item)) continue;
      item.url = normalizeUrl(item.url);
      const key = dedupKey(item);
      if (seen.has(key) || prevSeen.has(key)) continue;
      seen.add(key);
      items.push(item);
      sourceCounts[item.source] = (sourceCounts[item.source] ?? 0) + 1;
      if (items.length >= target) break;
    }
    if (items.length >= target) break;
  }
  console.log(JSON.stringify({ query, added: items.length - before, total: items.length }));
  if (items.length >= target) break;
}

// ── Enrich with ISBN + cover ──────────────────────────────────────────────────
console.log("Enriching with Open Library...");
await batchEnrich(items);

// ── Persist to Supabase market_prices ─────────────────────────────────────────
const supabaseUrl = Deno.env.get("SUPABASE_URL")?.trim();
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")?.trim();

if (supabaseUrl && supabaseKey) {
  const rows = items.map(i => ({
    isbn: i.isbn ?? null,
    title: i.title ?? null,
    source: i.source,
    price: Math.round(i.soldPrice ?? i.price ?? 0),
    sold_at: i.soldAt ?? null,
    scraped_at: startedAt,
    url: i.url ?? null,
  })).filter(r => r.price > 0);

  // Batch insert in chunks of 500
  let inserted = 0;
  for (let i = 0; i < rows.length; i += 500) {
    const chunk = rows.slice(i, i + 500);
    const res = await fetch(`${supabaseUrl}/rest/v1/market_prices`, {
      method: "POST",
      headers: {
        "apikey": supabaseKey,
        "Authorization": `Bearer ${supabaseKey}`,
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
      },
      body: JSON.stringify(chunk),
    });
    if (!res.ok) {
      console.error(`Supabase insert error ${res.status}: ${await res.text()}`);
    } else {
      inserted += chunk.length;
    }
  }
  console.log(`Inserted ${inserted} rows into market_prices`);
} else {
  console.log("SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY not set — skipping DB insert");
}

// ── Stats ──────────────────────────────────────────────────────────────────────
const prices = items.map(i => i.price).filter((p): p is number => p != null).sort((a, b) => a - b);
const soldPrices = items.map(i => i.soldPrice).filter((p): p is number => p != null).sort((a, b) => a - b);
const withIsbn = items.filter(i => i.isbn).length;
const withCover = items.filter(i => i.coverUrl).length;
const withSold = items.filter(i => i.soldPrice != null).length;

const outDir = Deno.env.get("SCRAPE_OUTPUT_DIR") || "scrape_output";
await Deno.mkdir(outDir, { recursive: true });
const stamp = startedAt.replace(/[:.]/g, "-");
const outPath = `${outDir}/books-${stamp}.json`;

await Deno.writeTextFile(outPath, JSON.stringify({
  scrapedAt: startedAt, elapsedMs: Date.now() - startedMs,
  target, total: items.length, sourceCounts,
  enrichmentStats: { withIsbn, withCover, withSold },
  queryStats, errors,
  priceStats: {
    min: prices[0] ?? null, median: prices.length ? prices[Math.floor(prices.length / 2)] : null, max: prices[prices.length - 1] ?? null,
    soldMin: soldPrices[0] ?? null, soldMedian: soldPrices.length ? soldPrices[Math.floor(soldPrices.length / 2)] : null, soldMax: soldPrices[soldPrices.length - 1] ?? null,
  },
  samples: items.slice(0, 25).map(i => ({ title: i.title, price: i.price, soldPrice: i.soldPrice, isbn: i.isbn, coverUrl: i.coverUrl, source: i.source })),
  items,
}, null, 2));

console.log("SAVED " + JSON.stringify({
  path: outPath, total: items.length, sourceCounts,
  enriched: { isbn: withIsbn, cover: withCover, sold: withSold },
  queriesUsed: queryStats.length, elapsedMs: Date.now() - startedMs,
  errors: errors.length,
}));
