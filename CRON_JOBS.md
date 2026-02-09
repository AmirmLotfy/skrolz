# Skrolz Cron Jobs Configuration

## ✅ Deployed Cron Jobs

All automated maintenance tasks are now scheduled and running:

### 1. **Refresh Trending Views** ⏰ Every Hour
- **Schedule**: `0 * * * *` (Every hour at minute 0)
- **Function**: `public.refresh_trending_views()`
- **Purpose**: Updates materialized views for trending posts and lessons
- **Impact**: Keeps trending feed fresh and accurate

### 2. **Update Creator Stats** ⏰ Daily at 1 AM UTC
- **Schedule**: `0 1 * * *` (Daily at 1:00 AM UTC)
- **Function**: `public.update_creator_stats_daily()`
- **Purpose**: Aggregates daily creator statistics (posts, lessons, engagement)
- **Impact**: Powers creator dashboards and analytics

### 3. **Clean Rate Limits** ⏰ Daily at 2 AM UTC
- **Schedule**: `0 2 * * *` (Daily at 2:00 AM UTC)
- **Function**: `public.clean_rate_limits()`
- **Purpose**: Removes old rate limit records (older than 24 hours)
- **Impact**: Keeps rate limit table clean and performant

### 4. **Process Pending Notifications** ⏰ Daily at 3 AM UTC
- **Schedule**: `0 3 * * *` (Daily at 3:00 AM UTC)
- **Function**: `public.process_pending_notifications()`
- **Purpose**: Deletes read notifications older than 30 days
- **Impact**: Maintains notification table size and performance

### 5. **Analyze Tables** ⏰ Weekly (Sunday at 4 AM UTC)
- **Schedule**: `0 4 * * 0` (Weekly on Sunday at 4:00 AM UTC)
- **Function**: `public.analyze_tables()`
- **Purpose**: Updates table statistics for query optimizer
- **Impact**: Ensures optimal query performance

### 6. **Update All Engagement Scores** ⏰ Every 6 Hours
- **Schedule**: `0 */6 * * *` (Every 6 hours)
- **Purpose**: Recalculates engagement scores for recent content (last 7 days)
- **Impact**: Ensures engagement scores stay accurate even if triggers miss updates

### 7. **Refresh Search Vectors** ⏰ Every 4 Hours
- **Schedule**: `0 */4 * * *` (Every 4 hours)
- **Purpose**: Updates full-text search vectors for new/updated content
- **Impact**: Keeps search functionality accurate and up-to-date

## 📊 Monitoring Cron Jobs

### List All Scheduled Jobs
```sql
SELECT * FROM public.list_cron_jobs();
```

### Check Cron Job Status
```sql
SELECT * FROM cron.job ORDER BY jobid;
```

### View Cron Job History
```sql
SELECT * FROM cron.job_run_details 
ORDER BY start_time DESC 
LIMIT 50;
```

### Manually Run a Job
```sql
-- Refresh trending views
SELECT public.refresh_trending_views();

-- Update creator stats
SELECT public.update_creator_stats_daily();

-- Clean rate limits
SELECT public.clean_rate_limits();

-- Process notifications
SELECT public.process_pending_notifications();

-- Analyze tables
SELECT public.analyze_tables();
```

## 🔧 Managing Cron Jobs

### Unschedule a Job
```sql
-- Find job ID first
SELECT jobid, schedule, command FROM cron.job WHERE command LIKE '%refresh-trending%';

-- Unschedule by job ID
SELECT cron.unschedule(jobid);
```

### Reschedule a Job
```sql
-- First unschedule the old job
SELECT cron.unschedule(jobid);

-- Then schedule with new timing
SELECT cron.schedule(
  'job-name',
  '0 * * * *', -- New schedule
  $$SELECT function_name()$$
);
```

## ⚠️ Important Notes

1. **pg_cron Extension**: Requires `pg_cron` extension to be enabled (already done in migration)
2. **Permissions**: Cron jobs run with the permissions of the user who scheduled them
3. **Timezone**: All schedules are in UTC
4. **Monitoring**: Check `cron.job_run_details` table for execution history and errors
5. **Error Handling**: Failed jobs are logged but don't stop other jobs from running

## 🎯 Cron Schedule Reference

| Schedule | Description |
|----------|-------------|
| `0 * * * *` | Every hour at minute 0 |
| `0 */6 * * *` | Every 6 hours |
| `0 */4 * * *` | Every 4 hours |
| `0 1 * * *` | Daily at 1:00 AM UTC |
| `0 2 * * *` | Daily at 2:00 AM UTC |
| `0 3 * * *` | Daily at 3:00 AM UTC |
| `0 4 * * 0` | Weekly on Sunday at 4:00 AM UTC |

## 📈 Expected Performance Impact

- **Trending Views**: Refreshed hourly for real-time trending content
- **Creator Stats**: Updated daily for accurate analytics
- **Rate Limits**: Cleaned daily to maintain performance
- **Notifications**: Pruned monthly to prevent table bloat
- **Table Stats**: Updated weekly for query optimization
- **Engagement Scores**: Recalculated every 6 hours for accuracy
- **Search Vectors**: Updated every 4 hours for search freshness

All cron jobs are production-ready and automatically maintained! 🚀
