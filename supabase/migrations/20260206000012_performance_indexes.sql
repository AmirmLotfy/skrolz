-- Additional performance indexes for common queries

-- Composite indexes for feed queries
CREATE INDEX IF NOT EXISTS idx_posts_author_moderation_created 
  ON public.posts(author_id, moderation_status, created_at DESC) 
  WHERE moderation_status = 'approved';

CREATE INDEX IF NOT EXISTS idx_lessons_author_moderation_created 
  ON public.lessons(author_id, moderation_status, created_at DESC) 
  WHERE moderation_status = 'approved';

-- Indexes for notification queries
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread 
  ON public.notifications(user_id, read, created_at DESC) 
  WHERE read = false;

CREATE INDEX IF NOT EXISTS idx_notifications_actor 
  ON public.notifications(actor_id, created_at DESC);

-- Indexes for collection queries
CREATE INDEX IF NOT EXISTS idx_collection_items_collection_sort 
  ON public.collection_items(collection_id, sort_order);

-- Indexes for user interactions analytics
CREATE INDEX IF NOT EXISTS idx_user_interactions_content_user 
  ON public.user_interactions(content_type, content_id, user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_interactions_user_created 
  ON public.user_interactions(user_id, created_at DESC);

-- Indexes for lesson sections
CREATE INDEX IF NOT EXISTS idx_lesson_sections_lesson_sort 
  ON public.lesson_sections(lesson_id, sort_order);

-- Indexes for quiz questions
CREATE INDEX IF NOT EXISTS idx_quiz_questions_lesson_sort 
  ON public.lesson_quiz_questions(lesson_id, sort_order);

-- Partial index for active follows
CREATE INDEX IF NOT EXISTS idx_follows_active 
  ON public.follows(follower_id, following_id, created_at DESC);

-- Index for creator stats queries
CREATE INDEX IF NOT EXISTS idx_creator_stats_profile_date 
  ON public.creator_stats_daily(profile_id, date DESC);

-- Index for lesson attempts
CREATE INDEX IF NOT EXISTS idx_lesson_attempts_user_lesson 
  ON public.lesson_attempts(user_id, lesson_id, completed_at DESC);

-- Function to analyze table statistics
CREATE OR REPLACE FUNCTION public.analyze_tables()
RETURNS void AS $$
BEGIN
  ANALYZE public.profiles;
  ANALYZE public.posts;
  ANALYZE public.lessons;
  ANALYZE public.reactions;
  ANALYZE public.comments;
  ANALYZE public.follows;
  ANALYZE public.user_interactions;
  ANALYZE public.notifications;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
