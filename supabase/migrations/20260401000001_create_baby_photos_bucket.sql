-- Create baby-photos storage bucket
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'baby-photos',
  'baby-photos',
  true,
  5242880, -- 5MB
  array['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

-- Allow authenticated users to upload to their own folder
create policy "Authenticated users can upload baby photos"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'baby-photos');

-- Allow public read access
create policy "Public read access for baby photos"
  on storage.objects for select
  to public
  using (bucket_id = 'baby-photos');

-- Allow authenticated users to update/delete their own photos
create policy "Authenticated users can update baby photos"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'baby-photos');

create policy "Authenticated users can delete baby photos"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'baby-photos');
