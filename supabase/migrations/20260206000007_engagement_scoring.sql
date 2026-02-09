-- Enhanced engagement scoring system with automatic updates

-- Function to calculate engagement score for a post
CREATE OR REPLACE FUNCTION public.calculate_post_engagement_score(post_id UUID)
RETURNS NUMERIC AS $$
DECLARE
  score NUMERIC := 0;
  likes_count INT;
  saves_count INT;
  comments_count INT;
  shares_count INT;
  views_count INT;
  completed_count INT;
  age_hours NUMERIC;
BEGIN
  -- Get engagement metrics
  SELECT 
    COUNT(*) FILTER (WHERE reaction_type = 'like'),
    COUNT(*) FILTER (WHERE reaction_type = 'save')
  INTO likes_count, saves_count
  FROM public.reactions
  WHERE content_type = 'post' AND content_id = post_id;
  
  SELECT COUNT(*) INTO comments_count
  FROM public.comments
  WHERE content_type = 'post' AND content_id = post_id;
  
  SELECT 
    COUNT(*) FILTER (WHERE shared = true),
    COUNT(*) FILTER (WHERE dwell_time_sec > 0),
    COUNT(*) FILTER (WHERE completed = true)
  INTO shares_count, views_count, completed_count
  FROM public.user_interactions
  WHERE content_type = 'post' AND content_id = post_id;
  
  -- Calculate age in hours
  SELECT EXTRACT(EPOCH FROM (now() - created_at)) / 3600 INTO age_hours
  FROM public.posts WHERE id = post_id;
  
  -- Weighted scoring formula
  score := 
    (likes_count * 1.0) +
    (saves_count * 2.0) +
    (comments_count * 3.0) +
    (shares_count * 5.0) +
    (views_count * 0.1) +
    (completed_count * 0.5) -
    (GREATEST(age_hours - 24, 0) * 0.01); -- Decay after 24 hours
  
  RETURN GREATEST(score, 0);
END;
$$ LANGUAGE plpgsql;

-- Function to calculate engagement score for a lesson
CREATE OR REPLACE FUNCTION public.calculate_lesson_engagement_score(lesson_id UUID)
RETURNS NUMERIC AS $$
DECLARE
  score NUMERIC := 0;
  likes_count INT;
  saves_count INT;
  comments_count INT;
  attempts_count INT;
  completed_count INT;
  age_hours NUMERIC;
BEGIN
  SELECT 
    COUNT(*) FILTER (WHERE reaction_type = 'like'),
    COUNT(*) FILTER (WHERE reaction_type = 'save')
  INTO likes_count, saves_count
  FROM public.reactions
  WHERE content_type = 'lesson' AND content_id = lesson_id;
  
  SELECT COUNT(*) INTO comments_count
  FROM public.comments
  WHERE content_type = 'lesson' AND content_id = lesson_id;
  
  SELECT COUNT(*) INTO attempts_count
  FROM public.lesson_attempts
  WHERE lesson_id = lesson_id;
  
  SELECT COUNT(*) INTO completed_count
  FROM public.user_interactions
  WHERE content_type = 'lesson' AND content_id = lesson_id AND completed = true;
  
  SELECT EXTRACT(EPOCH FROM (now() - created_at)) / 3600 INTO age_hours
  FROM public.lessons WHERE id = lesson_id;
  
  score := 
    (likes_count * 1.0) +
    (saves_count * 2.5) +
    (comments_count * 3.0) +
    (attempts_count * 4.0) +
    (completed_count * 5.0) -
    (GREATEST(age_hours - 48, 0) * 0.01); -- Decay after 48 hours
  
  RETURN GREATEST(score, 0);
END;
$$ LANGUAGE plpgsql;

-- Trigger to update post engagement score
CREATE OR REPLACE FUNCTION public.update_post_engagement_score()
RETURNS TRIGGER AS $$
DECLARE
  content_id_param UUID;
BEGIN
  content_id_param := COALESCE(NEW.content_id, OLD.content_id);
  UPDATE public.posts
  SET engagement_score = public.calculate_post_engagement_score(content_id_param)
  WHERE id = content_id_param;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Triggers for engagement score updates
CREATE TRIGGER update_post_score_on_reaction_insert
  AFTER INSERT ON public.reactions
  FOR EACH ROW
  WHEN (NEW.content_type = 'post')
  EXECUTE FUNCTION public.update_post_engagement_score();

CREATE TRIGGER update_post_score_on_reaction_delete
  AFTER DELETE ON public.reactions
  FOR EACH ROW
  WHEN (OLD.content_type = 'post')
  EXECUTE FUNCTION public.update_post_engagement_score();

CREATE TRIGGER update_post_score_on_comment_insert
  AFTER INSERT ON public.comments
  FOR EACH ROW
  WHEN (NEW.content_type = 'post')
  EXECUTE FUNCTION public.update_post_engagement_score();

CREATE TRIGGER update_post_score_on_comment_delete
  AFTER DELETE ON public.comments
  FOR EACH ROW
  WHEN (OLD.content_type = 'post')
  EXECUTE FUNCTION public.update_post_engagement_score();

CREATE TRIGGER update_post_score_on_interaction
  AFTER INSERT OR UPDATE ON public.user_interactions
  FOR EACH ROW
  WHEN (NEW.content_type = 'post')
  EXECUTE FUNCTION public.update_post_engagement_score();

-- Similar triggers for lessons
CREATE OR REPLACE FUNCTION public.update_lesson_engagement_score()
RETURNS TRIGGER AS $$
DECLARE
  content_id_param UUID;
BEGIN
  content_id_param := COALESCE(NEW.content_id, OLD.content_id);
  UPDATE public.lessons
  SET engagement_score = public.calculate_lesson_engagement_score(content_id_param)
  WHERE id = content_id_param;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lesson_score_on_reaction_insert
  AFTER INSERT ON public.reactions
  FOR EACH ROW
  WHEN (NEW.content_type = 'lesson')
  EXECUTE FUNCTION public.update_lesson_engagement_score();

CREATE TRIGGER update_lesson_score_on_reaction_delete
  AFTER DELETE ON public.reactions
  FOR EACH ROW
  WHEN (OLD.content_type = 'lesson')
  EXECUTE FUNCTION public.update_lesson_engagement_score();

CREATE TRIGGER update_lesson_score_on_comment_insert
  AFTER INSERT ON public.comments
  FOR EACH ROW
  WHEN (NEW.content_type = 'lesson')
  EXECUTE FUNCTION public.update_lesson_engagement_score();

CREATE TRIGGER update_lesson_score_on_comment_delete
  AFTER DELETE ON public.comments
  FOR EACH ROW
  WHEN (OLD.content_type = 'lesson')
  EXECUTE FUNCTION public.update_lesson_engagement_score();

CREATE TRIGGER update_lesson_score_on_attempt
  AFTER INSERT OR UPDATE ON public.lesson_attempts
  FOR EACH ROW
  EXECUTE FUNCTION public.update_lesson_engagement_score();
