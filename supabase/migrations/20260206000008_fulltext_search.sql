-- Full-text search setup for posts and lessons

-- Add full-text search columns
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS search_vector tsvector;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS search_vector tsvector;

-- Create GIN indexes for fast full-text search
CREATE INDEX IF NOT EXISTS idx_posts_search ON public.posts USING GIN(search_vector);
CREATE INDEX IF NOT EXISTS idx_lessons_search ON public.lessons USING GIN(search_vector);

-- Function to update post search vector
CREATE OR REPLACE FUNCTION public.update_post_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector := 
    setweight(to_tsvector('english', COALESCE(NEW.body, '')), 'A');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update lesson search vector
CREATE OR REPLACE FUNCTION public.update_lesson_search_vector()
RETURNS TRIGGER AS $$
DECLARE
  sections_text TEXT;
BEGIN
  SELECT string_agg(body, ' ') INTO sections_text
  FROM public.lesson_sections WHERE lesson_id = NEW.id;
  
  NEW.search_vector := 
    setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(sections_text, '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to update search vectors
CREATE TRIGGER post_search_vector_update
  BEFORE INSERT OR UPDATE OF body ON public.posts
  FOR EACH ROW
  EXECUTE FUNCTION public.update_post_search_vector();

CREATE TRIGGER lesson_search_vector_update
  BEFORE INSERT OR UPDATE OF title ON public.lessons
  FOR EACH ROW
  EXECUTE FUNCTION public.update_lesson_search_vector();

-- Update existing rows
UPDATE public.posts SET search_vector = setweight(to_tsvector('english', COALESCE(body, '')), 'A');
UPDATE public.lessons l SET search_vector = 
  setweight(to_tsvector('english', COALESCE(l.title, '')), 'A') ||
  setweight(to_tsvector('english', COALESCE(
    (SELECT string_agg(body, ' ') FROM public.lesson_sections WHERE lesson_id = l.id), ''
  )), 'B');

-- Function for full-text search
CREATE OR REPLACE FUNCTION public.search_content(query_text TEXT, content_type_filter TEXT DEFAULT NULL)
RETURNS TABLE (
  id UUID,
  content_type TEXT,
  title TEXT,
  body TEXT,
  author_id UUID,
  created_at TIMESTAMPTZ,
  rank REAL
) AS $$
BEGIN
  IF content_type_filter = 'post' OR content_type_filter IS NULL THEN
    RETURN QUERY
    SELECT 
      p.id,
      'post'::TEXT,
      NULL::TEXT,
      p.body,
      p.author_id,
      p.created_at,
      ts_rank(p.search_vector, plainto_tsquery('english', query_text))::REAL as rank
    FROM public.posts p
    WHERE p.search_vector @@ plainto_tsquery('english', query_text)
      AND p.moderation_status = 'approved'
    ORDER BY rank DESC, p.created_at DESC
    LIMIT 50;
  END IF;
  
  IF content_type_filter = 'lesson' OR content_type_filter IS NULL THEN
    RETURN QUERY
    SELECT 
      l.id,
      'lesson'::TEXT,
      l.title,
      NULL::TEXT,
      l.author_id,
      l.created_at,
      ts_rank(l.search_vector, plainto_tsquery('english', query_text))::REAL as rank
    FROM public.lessons l
    WHERE l.search_vector @@ plainto_tsquery('english', query_text)
      AND l.moderation_status = 'approved'
    ORDER BY rank DESC, l.created_at DESC
    LIMIT 50;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
