-- Notification preferences and batch processing

-- Add notification preferences to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{
  "likes": true,
  "comments": true,
  "follows": true,
  "mentions": true,
  "digest": true,
  "quiet_hours_start": 22,
  "quiet_hours_end": 8
}'::jsonb;

-- Function to check if notification should be sent based on preferences
CREATE OR REPLACE FUNCTION public.should_send_notification(
  user_id_param UUID,
  notification_type TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  prefs JSONB;
  quiet_start INT;
  quiet_end INT;
  current_hour INT;
  type_enabled BOOLEAN;
BEGIN
  SELECT notification_preferences INTO prefs
  FROM public.profiles
  WHERE id = user_id_param;
  
  IF prefs IS NULL THEN
    RETURN TRUE; -- Default: send all notifications
  END IF;
  
  -- Check if this notification type is enabled
  type_enabled := COALESCE((prefs->>notification_type)::boolean, true);
  IF NOT type_enabled THEN
    RETURN FALSE;
  END IF;
  
  -- Check quiet hours
  quiet_start := COALESCE((prefs->>'quiet_hours_start')::int, 22);
  quiet_end := COALESCE((prefs->>'quiet_hours_end')::int, 8);
  current_hour := EXTRACT(HOUR FROM now());
  
  -- If quiet hours span midnight
  IF quiet_start > quiet_end THEN
    IF current_hour >= quiet_start OR current_hour < quiet_end THEN
      RETURN FALSE;
    END IF;
  ELSE
    IF current_hour >= quiet_start AND current_hour < quiet_end THEN
      RETURN FALSE;
    END IF;
  END IF;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update notification trigger to check preferences
CREATE OR REPLACE FUNCTION public.handle_reaction_notification()
RETURNS TRIGGER AS $$
DECLARE
  content_author_id UUID;
  content_title TEXT;
BEGIN
  IF NEW.reaction_type = 'like' THEN
    IF NEW.content_type = 'post' THEN
      SELECT author_id, body INTO content_author_id, content_title
      FROM public.posts WHERE id = NEW.content_id;
    ELSIF NEW.content_type = 'lesson' THEN
      SELECT author_id, title INTO content_author_id, content_title
      FROM public.lessons WHERE id = NEW.content_id;
    END IF;
    
    IF content_author_id IS NOT NULL AND content_author_id != NEW.user_id THEN
      IF public.should_send_notification(content_author_id, 'likes') THEN
        INSERT INTO public.notifications (user_id, type, title, body, content_type, content_id, actor_id)
        VALUES (
          content_author_id,
          'like',
          'Someone liked your content',
          COALESCE(content_title, 'Your ' || NEW.content_type),
          NEW.content_type,
          NEW.content_id,
          NEW.user_id
        );
      END IF;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Batch notification processing function
CREATE OR REPLACE FUNCTION public.process_pending_notifications()
RETURNS INT AS $$
DECLARE
  processed_count INT := 0;
BEGIN
  -- Mark old read notifications for cleanup (older than 30 days)
  DELETE FROM public.notifications
  WHERE read = true AND created_at < now() - INTERVAL '30 days';
  
  GET DIAGNOSTICS processed_count = ROW_COUNT;
  RETURN processed_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
