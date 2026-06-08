create table if not exists public.market_prices (
  id uuid primary key default gen_random_uuid(),
  isbn text null,
  title text null,
  source text not null,
  price integer not null,
  sold_at timestamptz null,
  scraped_at timestamptz not null default now(),
  url text null
);

create index if not exists market_prices_isbn_scraped_idx on public.market_prices (isbn, scraped_at desc);
create index if not exists market_prices_scraped_at_idx on public.market_prices (scraped_at desc);

alter table public.market_prices enable row level security;

drop policy if exists "market_prices_select_anon" on public.market_prices;
create policy "market_prices_select_anon" on public.market_prices
for select
to anon, authenticated
using (true);

drop policy if exists "market_prices_insert_service" on public.market_prices;
create policy "market_prices_insert_service" on public.market_prices
for insert
to service_role
with check (true);
