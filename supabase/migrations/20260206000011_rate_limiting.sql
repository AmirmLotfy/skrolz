-- Rate limiting and abuse prevention

-- Rate limit tracking table
CREATE TABLE IF NOT EXISTS public.rate_limits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  action_type TEXT NOT NULL,
  count INT NOT NULL DEFAULT 1,
  window_start TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, action_type, window_start)
);

CREATE INDEX idx_rate_limits_user_action ON public.rate_limits(user_id, action_type, window_start DESC);

-- Function to check rate limit
CREATE OR REPLACE FUNCTION public.check_rate_limit(
  user_id_param UUID,
  action_type_param TEXT,
  max_actions INT,
  window_minutes INT
)
RETURNS BOOLEAN AS $$
DECLARE
  current_count INT;
  window_start TIMESTAMPTZ;
BEGIN
  window_start := date_trunc('minute', now()) - (EXTRACT(MINUTE FROM now())::INT % window_minutes || ' minutes')::INTERVAL;
  
  SELECT COALESCE(SUM(count), 0) INTO current_count
  FROM public.rate_limits
  WHERE user_id = user_id_param
    AND action_type = action_type_param
    AND window_start >= now() - (window_minutes || ' minutes')::INTERVAL;
  
  IF current_count >= max_actions THEN
    RETURN FALSE;
  END IF;
  
  -- Record this action
  INSERT INTO public.rate_limits (user_id, action_type, count, window_start)
  VALUES (user_id_param, action_type_param, 1, window_start)
  ON CONFLICT (user_id, action_type, window_start) 
  DO UPDATE SET count = rate_limits.count + 1;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to clean old rate limit records
CREATE OR REPLACE FUNCTION public.clean_rate_limits()
RETURNS void AS $$
BEGIN
  DELETE FROM public.rate_limits
  WHERE window_start < now() - INTERVAL '24 hours';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Rate limit checks for posts
CREATE OR REPLACE FUNCTION public.enforce_post_rate_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT public.check_rate_limit(NEW.author_id, 'create_post', 10, 60) THEN
    RAISE EXCEPTION 'Rate limit exceeded: Maximum 10 posts per hour';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rate_limit_posts
  BEFORE INSERT ON public.posts
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_post_rate_limit();

-- Rate limit checks for comments
CREATE OR REPLACE FUNCTION public.enforce_comment_rate_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT public.check_rate_limit(NEW.author_id, 'create_comment', 30, 60) THEN
    RAISE EXCEPTION 'Rate limit exceeded: Maximum 30 comments per hour';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rate_limit_comments
  BEFORE INSERT ON public.comments
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_comment_rate_limit();

-- Rate limit checks for reactions
CREATE OR REPLACE FUNCTION public.enforce_reaction_rate_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT public.check_rate_limit(NEW.user_id, 'create_reaction', 100, 60) THEN
    RAISE EXCEPTION 'Rate limit exceeded: Maximum 100 reactions per hour';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rate_limit_reactions
  BEFORE INSERT ON public.reactions
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_reaction_rate_limit();
