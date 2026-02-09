-- Storage buckets: lesson media, avatars, share cards
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('lesson-media', 'lesson-media', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp']),
  ('avatars', 'avatars', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp']),
  ('share-cards', 'share-cards', true, 5242880, ARRAY['image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- RLS for storage
CREATE POLICY "Lesson media: authenticated upload, public read"
  ON storage.objects FOR SELECT USING (bucket_id = 'lesson-media');
CREATE POLICY "Lesson media: authenticated insert"
  ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'lesson-media' AND auth.role() = 'authenticated');
CREATE POLICY "Lesson media: owner update/delete"
  ON storage.objects FOR UPDATE USING (bucket_id = 'lesson-media' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Lesson media: owner delete"
  ON storage.objects FOR DELETE USING (bucket_id = 'lesson-media' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Avatars: public read"
  ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "Avatars: authenticated upload own"
  ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');
CREATE POLICY "Avatars: owner update/delete"
  ON storage.objects FOR ALL USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Share cards: public read"
  ON storage.objects FOR SELECT USING (bucket_id = 'share-cards');
CREATE POLICY "Share cards: service role write"
  ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'share-cards');
