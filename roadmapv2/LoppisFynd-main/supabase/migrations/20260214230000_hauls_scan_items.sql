create extension if not exists "uuid-ossp";

create table if not exists public.hauls (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  started_at timestamptz not null default now(),
  ended_at timestamptz null,
  lat double precision null,
  lng double precision null,
  total_invested double precision null,
  gross_value double precision null,
  net_profit double precision null,
  co2_saved_kg double precision null,
  updated_at timestamptz not null default now()
);

create index if not exists hauls_user_id_idx on public.hauls (user_id);

create table if not exists public.scan_items (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  haul_id uuid not null references public.hauls (id) on delete cascade,
  ai_json text null,
  query text null,
  "desc" text null,
  confidence double precision null,
  purchase_price double precision null,
  median_price double precision null,
  min_price double precision null,
  max_price double precision null,
  demand_score integer null,
  days_to_sell_est integer null,
  status text not null default 'pendingIdentify',
  updated_at timestamptz not null default now()
);

create index if not exists scan_items_user_id_idx on public.scan_items (user_id);
create index if not exists scan_items_haul_id_idx on public.scan_items (haul_id);

alter table public.hauls enable row level security;
alter table public.scan_items enable row level security;

drop policy if exists "hauls_select_own" on public.hauls;
create policy "hauls_select_own" on public.hauls
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "hauls_insert_own" on public.hauls;
create policy "hauls_insert_own" on public.hauls
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "hauls_update_own" on public.hauls;
create policy "hauls_update_own" on public.hauls
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "hauls_delete_own" on public.hauls;
create policy "hauls_delete_own" on public.hauls
for delete
to authenticated
using (user_id = auth.uid());

drop policy if exists "scan_items_select_own" on public.scan_items;
create policy "scan_items_select_own" on public.scan_items
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "scan_items_insert_own" on public.scan_items;
create policy "scan_items_insert_own" on public.scan_items
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "scan_items_update_own" on public.scan_items;
create policy "scan_items_update_own" on public.scan_items
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "scan_items_delete_own" on public.scan_items;
create policy "scan_items_delete_own" on public.scan_items
for delete
to authenticated
using (user_id = auth.uid());
