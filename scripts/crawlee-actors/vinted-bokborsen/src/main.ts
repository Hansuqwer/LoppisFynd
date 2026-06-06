import { Actor } from 'apify';
import { CheerioCrawler, Dataset, PlaywrightCrawler } from 'crawlee';

type Input = {
  source: 'vinted' | 'bokborsen';
  query: string;
  maxResults?: number;
  country?: string;
  soldOnly?: boolean;
};

await Actor.init();
const input = await Actor.getInput<Input>() ?? { source: 'bokborsen', query: '', maxResults: 50 };
const maxResults = Math.min(input.maxResults ?? 50, 100);

if (!input.query?.trim()) throw new Error('query is required');

if (input.source === 'bokborsen') {
  await runBokborsen(input.query, maxResults);
} else {
  await runVinted(input.query, maxResults, input.soldOnly ?? false);
}

await Actor.exit();

async function runBokborsen(query: string, maxResults: number) {
  const url = `https://www.bokborsen.se/search?q=${encodeURIComponent(query)}&sort=sold_date`;
  let pushed = 0;

  const crawler = new CheerioCrawler({
    maxRequestsPerCrawl: 1,
    requestHandler: async ({ $, request }) => {
      const now = new Date().toISOString();
      const items: unknown[] = [];
      $('div.single-product').each((_i, el) => {
        if (pushed >= maxResults) return false;
        const block = $(el);
        const priceText = block.find('span.price').first().text();
        const price = parseInt(priceText.replace(/[^0-9]/g, ''), 10);
        if (!Number.isFinite(price) || price <= 0) return;
        const title = block.find('span[itemprop="name"]').first().text().trim() || null;
        const href = block.find('div.header h2 a[href]').first().attr('href') ?? null;
        const url = href ? new URL(href, 'https://www.bokborsen.se').toString() : null;
        items.push({ platform: 'bokborsen', price, title, url, soldAt: now, sourceUrl: request.loadedUrl });
        pushed += 1;
      });
      await Dataset.pushData(items);
    },
  });

  await crawler.run([url]);
}

async function runVinted(query: string, maxResults: number, soldOnly: boolean) {
  // Browser path for DataDome/Cloudflare-sensitive sessions.
  const crawler = new PlaywrightCrawler({
    maxRequestsPerCrawl: 1,
    launchContext: {
      launchOptions: { headless: true },
    },
    async requestHandler({ page }) {
      const catalogUrl = `https://www.vinted.se/catalog?search_text=${encodeURIComponent(query)}`;
      await page.goto(catalogUrl, { waitUntil: 'domcontentloaded', timeout: 60_000 });
      await page.waitForTimeout(1500);

      const items = await page.evaluate(async ({ query, maxResults, soldOnly }) => {
        const url = new URL('https://www.vinted.se/api/v2/catalog/items');
        url.searchParams.set('search_text', query);
        url.searchParams.set('per_page', String(maxResults));
        url.searchParams.set('page', '1');
        url.searchParams.set('currency', 'SEK');
        const resp = await fetch(url.toString(), { credentials: 'include', headers: { accept: 'application/json' } });
        if (!resp.ok) return [];
        const data = await resp.json();
        const rawItems = Array.isArray(data.items) ? data.items : [];
        return rawItems.map((item: any) => {
          const amount = typeof item.price === 'number'
            ? item.price
            : typeof item.price?.amount === 'string'
              ? parseFloat(item.price.amount)
              : item.price?.amount;
          const soldAtRaw = item.sold_at ?? item.soldAt ?? item.soldDate ?? null;
          const soldAt = typeof soldAtRaw === 'number'
            ? new Date(soldAtRaw < 10_000_000_000 ? soldAtRaw * 1000 : soldAtRaw).toISOString()
            : (soldAtRaw || null);
          return {
            platform: 'vinted',
            price: Number.isFinite(amount) ? Math.round(amount) : null,
            title: item.title ?? null,
            url: item.url ?? (item.path ? `https://www.vinted.se${item.path}` : null),
            soldAt,
          };
        }).filter((x: any) => x.price && (!soldOnly || x.soldAt));
      }, { query, maxResults, soldOnly });

      await Dataset.pushData(items);
    },
  });

  await crawler.run([`https://www.vinted.se/catalog?search_text=${encodeURIComponent(query)}`]);
}
