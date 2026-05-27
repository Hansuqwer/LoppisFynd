-- Schedule book-market-aggregator to refresh market stats nightly
-- Runs at 02:00 UTC every day via pg_cron (Supabase project must have pg_cron enabled)
-- Deploy with: supabase db push (after linking project)

select
  cron.schedule(
    'refresh-book-market-stats',          -- job name (unique)
    '0 2 * * *',                          -- cron expression: 02:00 UTC daily
    $$
    select
      net.http_post(
        url    := current_setting('app.supabase_url') || '/functions/v1/book-market-aggregator',
        headers := jsonb_build_object(
          'Content-Type',  'application/json',
          'Authorization', 'Bearer ' || current_setting('app.service_role_key')
        ),
        body   := '{"query":"placeholder","_cron":true}'::jsonb
      ) as request_id;
    $$
  );
