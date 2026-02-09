-- Skrolz initial schema: core tables, RLS, indexes
-- Extend auth.users via public.profiles (subscription_status, preferences)

-- Profiles (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  subscription_status TEXT NOT NULL DEFAULT 'free' CHECK (subscription_status IN ('free', 'premium', 'trialing', 'cancelled')),
  preferences JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Categories/topics for posts and lessons
CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT NOT NULL UNIQUE,
  name_en TEXT NOT NULL,
  name_ar TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Posts (≤280 chars)
CREATE TABLE public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  body TEXT NOT NULL CHECK (char_length(body) <= 280),
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
  time_to_read_sec INT,
  engagement_score NUMERIC NOT NULL DEFAULT 0,
  moderation_status TEXT NOT NULL DEFAULT 'pending' CHECK (moderation_status IN ('pending', 'approved', 'quarantined', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Lessons (multi-slide)
CREATE TABLE public.lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  thumbnail_url TEXT,
  engagement_score NUMERIC NOT NULL DEFAULT 0,
  moderation_status TEXT NOT NULL DEFAULT 'pending' CHECK (moderation_status IN ('pending', 'approved', 'quarantined', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Lesson sections (slides)
CREATE TABLE public.lesson_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  sort_order INT NOT NULL,
  title TEXT,
  body TEXT,
  image_url TEXT,
  key_takeaway TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Collections (curated playlists)
CREATE TABLE public.collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  cover_url TEXT,
  is_public BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Content items in collections (post or lesson)
CREATE TABLE public.collection_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id UUID NOT NULL REFERENCES public.collections(id) ON DELETE CASCADE,
  content_type TEXT NOT NULL CHECK (content_type IN ('post', 'lesson')),
  content_id UUID NOT NULL,
  sort_order INT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (collection_id, content_type, content_id)
);

-- Content sources / citations for lessons
CREATE TABLE public.content_sources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  url TEXT,
  title TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Follows
CREATE TABLE public.follows (
  follower_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id != following_id)
);

-- Comments (post or lesson via content_id + content_type)
CREATE TABLE public.comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_type TEXT NOT NULL CHECK (content_type IN ('post', 'lesson')),
  content_id UUID NOT NULL,
  author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Reactions: likes, saves (unified)
CREATE TABLE public.reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content_type TEXT NOT NULL CHECK (content_type IN ('post', 'lesson')),
  content_id UUID NOT NULL,
  reaction_type TEXT NOT NULL CHECK (reaction_type IN ('like', 'save')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, content_type, content_id, reaction_type)
);

-- Reports
CREATE TABLE public.reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_type TEXT NOT NULL CHECK (content_type IN ('post', 'lesson')),
  content_id UUID NOT NULL,
  reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'reviewed', 'resolved', 'dismissed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Blocks
CREATE TABLE public.blocks (
  blocker_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (blocker_id, blocked_id),
  CHECK (blocker_id != blocked_id)
);

-- Mutes
CREATE TABLE public.mutes (
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  muted_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, muted_id),
  CHECK (user_id != muted_id)
);

-- User interactions (for ranking)
CREATE TABLE public.user_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content_type TEXT NOT NULL CHECK (content_type IN ('post', 'lesson')),
  content_id UUID NOT NULL,
  dwell_time_sec NUMERIC,
  completed BOOLEAN NOT NULL DEFAULT false,
  saved BOOLEAN NOT NULL DEFAULT false,
  shared BOOLEAN NOT NULL DEFAULT false,
  commented BOOLEAN NOT NULL DEFAULT false,
  hidden BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Creator stats (daily aggregates for profile dashboards)
CREATE TABLE public.creator_stats_daily (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  posts_count INT NOT NULL DEFAULT 0,
  lessons_count INT NOT NULL DEFAULT 0,
  likes_received INT NOT NULL DEFAULT 0,
  saves_received INT NOT NULL DEFAULT 0,
  comments_received INT NOT NULL DEFAULT 0,
  UNIQUE (profile_id, date)
);

-- Indexes for feed and performance
CREATE INDEX idx_posts_created_at ON public.posts(created_at DESC);
CREATE INDEX idx_posts_engagement_score ON public.posts(engagement_score DESC);
CREATE INDEX idx_posts_category_created ON public.posts(category_id, created_at DESC);
CREATE INDEX idx_posts_author ON public.posts(author_id);
CREATE INDEX idx_posts_moderation ON public.posts(moderation_status) WHERE moderation_status = 'approved';

CREATE INDEX idx_lessons_created_at ON public.lessons(created_at DESC);
CREATE INDEX idx_lessons_engagement_score ON public.lessons(engagement_score DESC);
CREATE INDEX idx_lessons_category_created ON public.lessons(category_id, created_at DESC);
CREATE INDEX idx_lessons_author ON public.lessons(author_id);
CREATE INDEX idx_lessons_moderation ON public.lessons(moderation_status) WHERE moderation_status = 'approved';

CREATE INDEX idx_follows_follower ON public.follows(follower_id);
CREATE INDEX idx_follows_following ON public.follows(following_id);

CREATE INDEX idx_comments_content ON public.comments(content_type, content_id);
CREATE INDEX idx_comments_parent_created ON public.comments(parent_id, created_at DESC);
CREATE INDEX idx_comments_content_parent_created ON public.comments(content_type, content_id, parent_id, created_at DESC);

CREATE INDEX idx_reactions_user ON public.reactions(user_id);
CREATE INDEX idx_reactions_content ON public.reactions(content_type, content_id);

CREATE INDEX idx_user_interactions_user_created ON public.user_interactions(user_id, created_at DESC);

-- Trigger: create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.email));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
