-- Cron jobs for automated maintenance tasks

-- Enable pg_cron extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Grant usage to postgres role (required for pg_cron)
GRANT USAGE ON SCHEMA cron TO postgres;

-- 1. Refresh trending materialized views (every hour)
SELECT cron.schedule(
  'refresh-trending-views',
  '0 * * * *', -- Every hour at minute 0
  $$SELECT public.refresh_trending_views()$$
);

-- 2. Update creator stats daily (every day at 1 AM UTC)
SELECT cron.schedule(
  'update-creator-stats-daily',
  '0 1 * * *', -- Daily at 1:00 AM UTC
  $$SELECT public.update_creator_stats_daily()$$
);

-- 3. Clean old rate limit records (daily at 2 AM UTC)
SELECT cron.schedule(
  'clean-rate-limits',
  '0 2 * * *', -- Daily at 2:00 AM UTC
  $$SELECT public.clean_rate_limits()$$
);

-- 4. Process pending notifications (daily at 3 AM UTC)
SELECT cron.schedule(
  'process-pending-notifications',
  '0 3 * * *', -- Daily at 3:00 AM UTC
  $$SELECT public.process_pending_notifications()$$
);

-- 5. Analyze tables for query optimization (weekly on Sunday at 4 AM UTC)
SELECT cron.schedule(
  'analyze-tables',
  '0 4 * * 0', -- Weekly on Sunday at 4:00 AM UTC
  $$SELECT public.analyze_tables()$$
);

-- 6. Update engagement scores for all content (every 6 hours)
-- This ensures scores stay accurate even if triggers miss something
SELECT cron.schedule(
  'update-all-engagement-scores',
  '0 */6 * * *', -- Every 6 hours
  $$
  UPDATE public.posts 
  SET engagement_score = public.calculate_post_engagement_score(id)
  WHERE updated_at > now() - INTERVAL '7 days';
  
  UPDATE public.lessons 
  SET engagement_score = public.calculate_lesson_engagement_score(id)
  WHERE updated_at > now() - INTERVAL '7 days';
  $$
);

-- 7. Refresh search vectors for new content (every 4 hours)
SELECT cron.schedule(
  'refresh-search-vectors',
  '0 */4 * * *', -- Every 4 hours
  $$
  UPDATE public.posts 
  SET search_vector = setweight(to_tsvector('english', COALESCE(body, '')), 'A')
  WHERE search_vector IS NULL OR updated_at > now() - INTERVAL '1 day';
  
  UPDATE public.lessons l
  SET search_vector = 
    setweight(to_tsvector('english', COALESCE(l.title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(
      (SELECT string_agg(body, ' ') FROM public.lesson_sections WHERE lesson_id = l.id), ''
    )), 'B')
  WHERE search_vector IS NULL OR l.updated_at > now() - INTERVAL '1 day';
  $$
);

-- Function to list all scheduled cron jobs
CREATE OR REPLACE FUNCTION public.list_cron_jobs()
RETURNS TABLE (
  jobid BIGINT,
  schedule TEXT,
  command TEXT,
  nodename TEXT,
  nodeport INT,
  database TEXT,
  username TEXT,
  active BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    j.jobid,
    j.schedule,
    j.command,
    j.nodename,
    j.nodeport,
    j.database,
    j.username,
    j.active
  FROM cron.job j
  ORDER BY j.jobid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to unschedule a cron job by name
CREATE OR REPLACE FUNCTION public.unschedule_cron_job(job_name TEXT)
RETURNS void AS $$
DECLARE
  job_id BIGINT;
BEGIN
  SELECT jobid INTO job_id
  FROM cron.job
  WHERE jobid::text = (
    SELECT unnest(string_to_array(current_setting('cron.job_name'), ','))
  );
  
  -- Alternative: find by command pattern
  SELECT jobid INTO job_id
  FROM cron.job
  WHERE command LIKE '%' || job_name || '%'
  LIMIT 1;
  
  IF job_id IS NOT NULL THEN
    PERFORM cron.unschedule(job_id);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
