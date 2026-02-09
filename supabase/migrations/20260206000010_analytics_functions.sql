-- Analytics and reporting functions

-- Function to get user activity stats
CREATE OR REPLACE FUNCTION public.get_user_activity_stats(user_id_param UUID, days INT DEFAULT 30)
RETURNS TABLE (
  posts_created INT,
  lessons_created INT,
  likes_given INT,
  comments_made INT,
  follows_count INT,
  engagement_score NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*) FILTER (WHERE p.id IS NOT NULL)::INT as posts_created,
    COUNT(*) FILTER (WHERE l.id IS NOT NULL)::INT as lessons_created,
    COUNT(*) FILTER (WHERE r.reaction_type = 'like')::INT as likes_given,
    COUNT(DISTINCT c.id)::INT as comments_made,
    COUNT(DISTINCT f.following_id)::INT as follows_count,
    COALESCE(SUM(p.engagement_score), 0) + COALESCE(SUM(l.engagement_score), 0) as engagement_score
  FROM generate_series(now() - (days || ' days')::INTERVAL, now(), '1 day'::INTERVAL) d
  LEFT JOIN public.posts p ON p.author_id = user_id_param 
    AND DATE(p.created_at) = DATE(d)
  LEFT JOIN public.lessons l ON l.author_id = user_id_param 
    AND DATE(l.created_at) = DATE(d)
  LEFT JOIN public.reactions r ON r.user_id = user_id_param 
    AND DATE(r.created_at) = DATE(d)
  LEFT JOIN public.comments c ON c.author_id = user_id_param 
    AND DATE(c.created_at) = DATE(d)
  LEFT JOIN public.follows f ON f.follower_id = user_id_param 
    AND DATE(f.created_at) = DATE(d);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get content performance metrics
CREATE OR REPLACE FUNCTION public.get_content_performance(
  content_type_param TEXT,
  content_id_param UUID
)
RETURNS TABLE (
  total_views INT,
  unique_viewers INT,
  likes_count INT,
  saves_count INT,
  comments_count INT,
  shares_count INT,
  avg_dwell_time NUMERIC,
  completion_rate NUMERIC,
  engagement_score NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*)::INT as total_views,
    COUNT(DISTINCT user_id)::INT as unique_viewers,
    COUNT(*) FILTER (WHERE r.reaction_type = 'like')::INT as likes_count,
    COUNT(*) FILTER (WHERE r.reaction_type = 'save')::INT as saves_count,
    COUNT(DISTINCT c.id)::INT as comments_count,
    COUNT(*) FILTER (WHERE ui.shared = true)::INT as shares_count,
    AVG(ui.dwell_time_sec)::NUMERIC as avg_dwell_time,
    (COUNT(*) FILTER (WHERE ui.completed = true)::NUMERIC / NULLIF(COUNT(*), 0) * 100)::NUMERIC as completion_rate,
    CASE 
      WHEN content_type_param = 'post' THEN (SELECT engagement_score FROM public.posts WHERE id = content_id_param)
      WHEN content_type_param = 'lesson' THEN (SELECT engagement_score FROM public.lessons WHERE id = content_id_param)
      ELSE 0
    END as engagement_score
  FROM public.user_interactions ui
  LEFT JOIN public.reactions r ON r.content_type = content_type_param AND r.content_id = content_id_param
  LEFT JOIN public.comments c ON c.content_type = content_type_param AND c.content_id = content_id_param
  WHERE ui.content_type = content_type_param AND ui.content_id = content_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get trending creators
CREATE OR REPLACE FUNCTION public.get_trending_creators(limit_count INT DEFAULT 10)
RETURNS TABLE (
  profile_id UUID,
  display_name TEXT,
  avatar_url TEXT,
  posts_count INT,
  lessons_count INT,
  total_engagement NUMERIC,
  followers_count INT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.display_name,
    p.avatar_url,
    COUNT(DISTINCT posts.id)::INT as posts_count,
    COUNT(DISTINCT lessons.id)::INT as lessons_count,
    COALESCE(SUM(posts.engagement_score), 0) + COALESCE(SUM(lessons.engagement_score), 0) as total_engagement,
    COUNT(DISTINCT f.follower_id)::INT as followers_count
  FROM public.profiles p
  LEFT JOIN public.posts ON posts.author_id = p.id AND posts.moderation_status = 'approved'
  LEFT JOIN public.lessons ON lessons.author_id = p.id AND lessons.moderation_status = 'approved'
  LEFT JOIN public.follows f ON f.following_id = p.id
  WHERE posts.created_at > now() - INTERVAL '30 days' 
     OR lessons.created_at > now() - INTERVAL '30 days'
  GROUP BY p.id, p.display_name, p.avatar_url
  HAVING COUNT(DISTINCT posts.id) + COUNT(DISTINCT lessons.id) > 0
  ORDER BY total_engagement DESC, followers_count DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update creator stats daily
CREATE OR REPLACE FUNCTION public.update_creator_stats_daily()
RETURNS void AS $$
BEGIN
  INSERT INTO public.creator_stats_daily (
    profile_id,
    date,
    posts_count,
    lessons_count,
    likes_received,
    saves_received,
    comments_received
  )
  SELECT 
    p.id,
    CURRENT_DATE,
    COUNT(DISTINCT posts.id)::INT,
    COUNT(DISTINCT lessons.id)::INT,
    COUNT(*) FILTER (WHERE r.reaction_type = 'like' AND r.content_type = 'post')::INT +
    COUNT(*) FILTER (WHERE r.reaction_type = 'like' AND r.content_type = 'lesson')::INT,
    COUNT(*) FILTER (WHERE r.reaction_type = 'save' AND r.content_type = 'post')::INT +
    COUNT(*) FILTER (WHERE r.reaction_type = 'save' AND r.content_type = 'lesson')::INT,
    COUNT(DISTINCT c.id)::INT
  FROM public.profiles p
  LEFT JOIN public.posts ON posts.author_id = p.id 
    AND DATE(posts.created_at) = CURRENT_DATE
  LEFT JOIN public.lessons ON lessons.author_id = p.id 
    AND DATE(lessons.created_at) = CURRENT_DATE
  LEFT JOIN public.reactions r ON (
    (r.content_type = 'post' AND r.content_id IN (SELECT id FROM public.posts WHERE author_id = p.id))
    OR (r.content_type = 'lesson' AND r.content_id IN (SELECT id FROM public.lessons WHERE author_id = p.id))
  ) AND DATE(r.created_at) = CURRENT_DATE
  LEFT JOIN public.comments c ON (
    (c.content_type = 'post' AND c.content_id IN (SELECT id FROM public.posts WHERE author_id = p.id))
    OR (c.content_type = 'lesson' AND c.content_id IN (SELECT id FROM public.lessons WHERE author_id = p.id))
  ) AND DATE(c.created_at) = CURRENT_DATE
  GROUP BY p.id
  ON CONFLICT (profile_id, date) DO UPDATE SET
    posts_count = EXCLUDED.posts_count,
    lessons_count = EXCLUDED.lessons_count,
    likes_received = EXCLUDED.likes_received,
    saves_received = EXCLUDED.saves_received,
    comments_received = EXCLUDED.comments_received;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
