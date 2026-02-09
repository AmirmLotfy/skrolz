-- Create storage buckets for Skrolz app

-- Avatars bucket (public)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Lesson thumbnails bucket (public)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'lesson-thumbnails',
  'lesson-thumbnails',
  true,
  10485760, -- 10MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Lesson images bucket (public)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'lesson-images',
  'lesson-images',
  true,
  10485760, -- 10MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for avatars bucket
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Storage policies for lesson-thumbnails bucket
CREATE POLICY "Lesson thumbnails are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'lesson-thumbnails');

CREATE POLICY "Authenticated users can upload lesson thumbnails"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'lesson-thumbnails' AND
  auth.role() = 'authenticated'
);

CREATE POLICY "Users can update their own lesson thumbnails"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'lesson-thumbnails' AND
  auth.role() = 'authenticated'
);

CREATE POLICY "Users can delete their own lesson thumbnails"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'lesson-thumbnails' AND
  auth.role() = 'authenticated'
);

-- Storage policies for lesson-images bucket
CREATE POLICY "Lesson images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'lesson-images');

CREATE POLICY "Authenticated users can upload lesson images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'lesson-images' AND
  auth.role() = 'authenticated'
);

CREATE POLICY "Users can update their own lesson images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'lesson-images' AND
  auth.role() = 'authenticated'
);

CREATE POLICY "Users can delete their own lesson images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'lesson-images' AND
  auth.role() = 'authenticated'
);
