CREATE OR REPLACE FUNCTION public.check_rate_limit(
  user_id_param UUID,
  action_type_param TEXT,
  max_actions INT,
  window_minutes INT
)
RETURNS BOOLEAN AS $$
DECLARE
  current_count INT;
  window_start_var TIMESTAMPTZ;
BEGIN
  -- Calculate window start (e.g. current hour start)
  window_start_var := date_trunc('minute', now()) - (EXTRACT(MINUTE FROM now())::INT % window_minutes || ' minutes')::INTERVAL;
  
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
  VALUES (user_id_param, action_type_param, 1, window_start_var)
  ON CONFLICT (user_id, action_type, window_start) 
  DO UPDATE SET count = rate_limits.count + 1;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
