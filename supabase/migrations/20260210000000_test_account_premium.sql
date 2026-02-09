-- Grant premium to the hackathon test account (run after creating the user in Supabase Dashboard).
-- User: gemini@skrolz.app (create via Authentication → Users → Add user in Dashboard first).
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM auth.users WHERE email = 'gemini@skrolz.app') THEN
    UPDATE public.profiles
    SET subscription_status = 'premium'
    WHERE id = (SELECT id FROM auth.users WHERE email = 'gemini@skrolz.app');
  END IF;
END $$;
