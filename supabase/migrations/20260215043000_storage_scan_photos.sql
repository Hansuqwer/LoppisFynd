insert into storage.buckets (id, name, public, allowed_mime_types)
values ('scan-photos', 'scan-photos', false, array['image/jpeg'])
on conflict (id) do nothing;

drop policy if exists "scan_photos_select_own" on storage.objects;
create policy "scan_photos_select_own" on storage.objects
for select
to authenticated
using (bucket_id = 'scan-photos' and owner = auth.uid());

drop policy if exists "scan_photos_insert_own" on storage.objects;
create policy "scan_photos_insert_own" on storage.objects
for insert
to authenticated
with check (bucket_id = 'scan-photos' and owner = auth.uid());

drop policy if exists "scan_photos_update_own" on storage.objects;
create policy "scan_photos_update_own" on storage.objects
for update
to authenticated
using (bucket_id = 'scan-photos' and owner = auth.uid())
with check (bucket_id = 'scan-photos' and owner = auth.uid());

drop policy if exists "scan_photos_delete_own" on storage.objects;
create policy "scan_photos_delete_own" on storage.objects
for delete
to authenticated
using (bucket_id = 'scan-photos' and owner = auth.uid());
