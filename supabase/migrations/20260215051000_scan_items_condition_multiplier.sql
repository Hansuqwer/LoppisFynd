alter table public.scan_items
add column if not exists condition_multiplier double precision not null default 1.0;
