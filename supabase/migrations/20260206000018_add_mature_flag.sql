-- Add is_mature flag for content filtering
ALTER TABLE public.posts ADD COLUMN is_mature BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.lessons ADD COLUMN is_mature BOOLEAN NOT NULL DEFAULT false;

-- Create index for filtering
CREATE INDEX idx_posts_is_mature ON public.posts(is_mature);
CREATE INDEX idx_lessons_is_mature ON public.lessons(is_mature);
