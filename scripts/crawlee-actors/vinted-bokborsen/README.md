# LoppisFynd Crawlee Actors: Vinted + Bokbörsen

Fallback scraper actor intended for Apify deployment.

## Input

```json
{
  "source": "vinted",
  "query": "pippi långstrump",
  "maxResults": 50,
  "soldOnly": false
}
```

or:

```json
{
  "source": "bokborsen",
  "query": "pippi långstrump",
  "maxResults": 50
}
```

## Why

- `vinted-scraper` Edge Function uses direct anonymous REST API first. If DataDome blocks serverless IPs, deploy this Playwright-based actor and use it as Apify fallback.
- `bokborsen-scraper` direct HTTP works today; Crawlee actor is a fallback if SSR markup changes or if request volume increases.
