-- Database triggers to create notifications when reactions/comments are created

-- Function to create notification on reaction (like)
CREATE OR REPLACE FUNCTION public.handle_reaction_notification()
RETURNS TRIGGER AS $$
DECLARE
  content_author_id UUID;
  content_title TEXT;
BEGIN
  -- Get content author and title
  IF NEW.reaction_type = 'like' THEN
    IF NEW.content_type = 'post' THEN
      SELECT author_id, body INTO content_author_id, content_title
      FROM public.posts WHERE id = NEW.content_id;
    ELSIF NEW.content_type = 'lesson' THEN
      SELECT author_id, title INTO content_author_id, content_title
      FROM public.lessons WHERE id = NEW.content_id;
    END IF;
    
    -- Create notification if not self-reaction
    IF content_author_id IS NOT NULL AND content_author_id != NEW.user_id THEN
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
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for reactions
CREATE TRIGGER on_reaction_insert
  AFTER INSERT ON public.reactions
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_reaction_notification();

-- Function to create notification on comment
CREATE OR REPLACE FUNCTION public.handle_comment_notification()
RETURNS TRIGGER AS $$
DECLARE
  content_author_id UUID;
  content_title TEXT;
  parent_author_id UUID;
BEGIN
  -- Get content author and title
  IF NEW.content_type = 'post' THEN
    SELECT author_id, body INTO content_author_id, content_title
    FROM public.posts WHERE id = NEW.content_id;
  ELSIF NEW.content_type = 'lesson' THEN
    SELECT author_id, title INTO content_author_id, content_title
    FROM public.lessons WHERE id = NEW.content_id;
  END IF;
  
  -- If reply to comment, notify parent comment author
  IF NEW.parent_id IS NOT NULL THEN
    SELECT author_id INTO parent_author_id
    FROM public.comments WHERE id = NEW.parent_id;
    
    IF parent_author_id IS NOT NULL AND parent_author_id != NEW.author_id THEN
      INSERT INTO public.notifications (user_id, type, title, body, content_type, content_id, actor_id)
      VALUES (
        parent_author_id,
        'comment',
        'Someone replied to your comment',
        LEFT(NEW.body, 100),
        NEW.content_type,
        NEW.content_id,
        NEW.author_id
      );
    END IF;
  END IF;
  
  -- Notify content author if not self-comment
  IF content_author_id IS NOT NULL AND content_author_id != NEW.author_id THEN
    INSERT INTO public.notifications (user_id, type, title, body, content_type, content_id, actor_id)
    VALUES (
      content_author_id,
      'comment',
      'Someone commented on your content',
      LEFT(NEW.body, 100),
      NEW.content_type,
      NEW.content_id,
      NEW.author_id
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for comments
CREATE TRIGGER on_comment_insert
  AFTER INSERT ON public.comments
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_comment_notification();

-- Function to create notification on follow
CREATE OR REPLACE FUNCTION public.handle_follow_notification()
RETURNS TRIGGER AS $$
BEGIN
  -- Notify the person being followed
  INSERT INTO public.notifications (user_id, type, title, body, actor_id)
  VALUES (
    NEW.following_id,
    'follow',
    'Someone started following you',
    NULL,
    NEW.follower_id
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for follows
CREATE TRIGGER on_follow_insert
  AFTER INSERT ON public.follows
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_follow_notification();
