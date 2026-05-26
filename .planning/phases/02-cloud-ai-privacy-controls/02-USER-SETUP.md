# Phase 2: User Setup Required

**Generated:** 2026-02-22
**Phase:** 02-cloud-ai-privacy-controls
**Status:** Incomplete

Complete these items for the cloud AI proxy integration to function. These steps require access to external dashboards/accounts.

## Environment Variables

| Status | Variable | Source | Add to |
|--------|----------|--------|--------|
| [ ] | `GEMINI_API_KEY` | Google AI Studio -> API keys | Supabase secrets (Edge Functions) |
| [ ] | `GEMINI_MODEL` | Set to an allowed model id (e.g. `gemini-2.5-flash`) | Supabase secrets (Edge Functions) |

## Account Setup

- [ ] **Create or access Google AI Studio project/API key**
  - URL: https://aistudio.google.com/
  - Notes: Create a new API key (server-side usage). Do not embed this key in the mobile app.

## Dashboard Configuration

- [ ] **Add secrets to Supabase Edge Functions**
  - Location: Supabase Dashboard -> Project Settings -> Secrets (Edge Functions)
  - Set: `GEMINI_API_KEY` and (optionally) `GEMINI_MODEL`
  - Notes: `GEMINI_MODEL` defaults to `gemini-2.5-flash` if unset.

## Verification

After completing setup, verify by deploying the Edge Function and calling it with a small crop payload.

Expected results:
- Requests without `prompt` or `imageBase64Jpeg` return 400.
- Oversized payload returns 413.
- Valid requests return 200 with `{ text, raw }` and never return uploaded image bytes.

---

**Once all items complete:** Mark status as "Complete" at top of file.
