# Privacy policy (draft)

Loppisfynd is designed to be offline-first.

## What data is stored locally

On your device, Loppisfynd stores:

- Hauls (title, date, optional location if you add it)
- Items (keywords, notes, prices, computed stats)
- Draft listings (title/description/asking price)
- Scan photos and thumbnails

## What data is stored in the cloud (optional)

If you enable cloud sync and sign in, Loppisfynd may upload:

- Haul and item metadata to Supabase tables (`hauls`, `scan_items`)
- Scan photos to Supabase Storage (bucket `scan-photos`)

Cloud sync is optional. The app still functions without it.

## Online requests

When you are online, the app can fetch sold-price comps from Tradera via a proxy.

## Export and deletion

In-app you can:

- Export your data (JSON/CSV)
- Delete local data
- Delete cloud data (when Supabase is configured)
- Request account deletion (when Supabase Edge Function is deployed)
