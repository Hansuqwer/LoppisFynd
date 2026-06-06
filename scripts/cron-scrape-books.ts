import { handleRequest as bokborsen } from "../supabase/functions/bokborsen-scraper/index.ts";
import { handleRequest as blocket } from "../supabase/functions/blocket-scraper/index.ts";
import { handleRequest as vinted } from "../supabase/functions/vinted-scraper/index.ts";
import { handleRequest as tradera } from "../supabase/functions/tradera-proxy/index.ts";

type Item = {
  source: string; query: string; title: string | null;
  price: number | null; url: string | null; soldAt: string | null; compType: "sold" | "asking";
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
  "Jakob Wegelius bok", "Mördarens apa bok", "Bokpaket barn",
  "Sagor barn", "Klassiska sagor barn",
];

const stopWords = new Set([
  "och","om","den","det","de","som","p\u00e5","i","en","ett","av",
  "bok","b\u00f6cker","barnbok","ungdomsbok","pocket",
]);
const bookWords = [
  "bok","b\u00f6cker","barnbok","barnb\u00f6cker","pocket","roman","saga","sagor",
  "pixi","bilderbok","kokbok","deckare","ungdomsbok","l\u00e4sebok",
  "f\u00f6rfattare","inbunden","h\u00e4ftad","ljudbok","cd bok",
];

function normalizeUrl(url: string | null): string | null {
  if (!url) return null;
  try {
    const parsed = new URL(url);
    parsed.searchParams.delete("referrer");
    parsed.hash = "";
    return parsed.toString();
  } catch { return url.trim() || null; }
}

function dedupKey(item: Item): string {
  const url = normalizeUrl(item.url);
  if (url) return `${item.source}|${url}`;
  return `${item.source}|${(item.title ?? "").toLowerCase().trim()}|${item.price ?? ""}`;
}

function significantTokens(query: string): string[] {
  return query.toLowerCase().normalize("NFKD").replace(/[\u0300-\u036f]/g, "")
    .split(/[^a-z0-9\u00e5\u00e4\u00f6]+/i)
    .map(t => t.trim()).filter(t => t.length >= 3 && !stopWords.has(t));
}
function normalizeText(v: string): string {
  return v.toLowerCase().normalize("NFKD").replace(/[\u0300-\u036f]/g, "");
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

async function scrapeMarketSource(source: string, handler: Function, query: string, max: number) {
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
    compType: source === "bokborsen" ? "sold" : "asking",
  })) as Item[];
}

async function scrapeTraderaSold(query: string, max: number): Promise<Item[]> {
  const res = await tradera(new Request("http://local/", {
    method: "POST", headers: { "content-type": "application/json" },
    body: JSON.stringify({ searchWords: query, itemStatus: "Ended", orderBy: "EndDateDescending", itemsPerPage: max, pageNumber: 1 }),
  }), { env: { get: (k: string) => k === "TRADERA_PUBLIC_FALLBACK" ? "1" : undefined }, rateLimit: async () => ({ allowed: true }) });
  let body: Record<string, unknown>;
  try { body = await res.json(); } catch { body = { items: [] }; }
  return (Array.isArray(body.items) ? body.items : []).map((raw: Record<string, unknown>) => ({
    source: "tradera", query,
    title: typeof raw.shortDescription === "string" ? raw.shortDescription : null,
    price: typeof raw.maxBid === "number" ? raw.maxBid : null,
    url: typeof raw.itemLink === "string" ? raw.itemLink : null,
    soldAt: typeof raw.endDate === "string" ? raw.endDate : null,
    compType: "sold",
  })) as Item[];
}

const sources: Array<[string, (q: string, m: number) => Promise<Item[]>]> = [
  ["tradera", scrapeTraderaSold],
  ["bokborsen", (q, m) => scrapeMarketSource("bokborsen", bokborsen, q, m)],
  ["vinted", (q, m) => scrapeMarketSource("vinted", vinted, q, m)],
  ["blocket", (q, m) => scrapeMarketSource("blocket", blocket, q, m)],
];

// --- main ---
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

const target = 1000;
const seen = new Set<string>();
const items: Item[] = [];
const sourceCounts: Record<string, number> = { tradera: 0, bokborsen: 0, vinted: 0, blocket: 0 };
const compTypeCounts: Record<string, number> = { sold: 0, asking: 0 };
const queryStats: object[] = [];
const errors: unknown[] = [];
const startedAt = new Date().toISOString();
const startedMs = Date.now();

for (const query of QUERY_POOL) {
  const before = items.length;
  for (const [source, scrape] of sources) {
    const result = await scrape(query, 20).catch(e => { errors.push({ query, source, error: String(e) }); return []; });
    for (const item of result) {
      if (!isLikelyBook(item)) continue;
      item.url = normalizeUrl(item.url);
      const key = dedupKey(item);
      if (seen.has(key) || prevSeen.has(key)) continue;
      seen.add(key);
      items.push(item);
      sourceCounts[item.source] = (sourceCounts[item.source] ?? 0) + 1;
      compTypeCounts[item.compType] = (compTypeCounts[item.compType] ?? 0) + 1;
      if (items.length >= target) break;
    }
    if (items.length >= target) break;
  }
  console.log(JSON.stringify({ query, added: items.length - before, total: items.length }));
  if (items.length >= target) break;
}

const prices = items.map(i => i.price).filter((p): p is number => p != null).sort((a, b) => a - b);

const outDir = Deno.env.get("SCRAPE_OUTPUT_DIR") || "scrape_output";
await Deno.mkdir(outDir, { recursive: true });
const stamp = startedAt.replace(/[:.]/g, "-");
const outPath = `${outDir}/books-${stamp}.json`;

await Deno.writeTextFile(outPath, JSON.stringify({
  scrapedAt: startedAt, elapsedMs: Date.now() - startedMs,
  target, total: items.length, sourceCounts, compTypeCounts, queryStats, errors,
  minPrice: prices[0] ?? null, medianPrice: prices.length ? prices[Math.floor(prices.length / 2)] : null,
  maxPrice: prices[prices.length - 1] ?? null,
  items,
}, null, 2));

const summary = {
  path: outPath, total: items.length, sourceCounts, compTypeCounts,
  queriesUsed: queryStats.length, elapsedMs: Date.now() - startedMs,
  minPrice: prices[0] ?? null, medianPrice: prices.length ? prices[Math.floor(prices.length / 2)] : null,
  maxPrice: prices[prices.length - 1] ?? null, errors: errors.length,
};
console.log("SAVED " + JSON.stringify(summary));
