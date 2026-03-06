-- Performance indexes for common scan_items queries.
create index if not exists idx_scan_items_status on public.scan_items (status);
create index if not exists idx_scan_items_user_updated on public.scan_items (user_id, updated_at desc);
