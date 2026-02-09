-- Materialized views for trending (refresh via cron or trigger)
CREATE MATERIALIZED VIEW public.mv_trending_posts AS
SELECT
  p.id,
  p.author_id,
  p.category_id,
  p.body,
  p.difficulty,
  p.time_to_read_sec,
  p.engagement_score,
  p.created_at,
  (p.engagement_score * 0.7 + (EXTRACT(EPOCH FROM (now() - p.created_at)) / 3600) * (-0.01)) AS trending_score
FROM public.posts p
WHERE p.moderation_status = 'approved'
ORDER BY trending_score DESC NULLS LAST;

CREATE UNIQUE INDEX ON public.mv_trending_posts (id);

CREATE MATERIALIZED VIEW public.mv_trending_lessons AS
SELECT
  l.id,
  l.author_id,
  l.category_id,
  l.title,
  l.thumbnail_url,
  l.engagement_score,
  l.created_at,
  (l.engagement_score * 0.7 + (EXTRACT(EPOCH FROM (now() - l.created_at)) / 3600) * (-0.01)) AS trending_score
FROM public.lessons l
WHERE l.moderation_status = 'approved'
ORDER BY trending_score DESC NULLS LAST;

CREATE UNIQUE INDEX ON public.mv_trending_lessons (id);

-- Refresh function (call from cron or Edge Function)
CREATE OR REPLACE FUNCTION public.refresh_trending_views()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY public.mv_trending_posts;
  REFRESH MATERIALIZED VIEW CONCURRENTLY public.mv_trending_lessons;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
