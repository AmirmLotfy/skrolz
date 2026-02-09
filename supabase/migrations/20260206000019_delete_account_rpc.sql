-- Secure function for users to delete their own account
CREATE OR REPLACE FUNCTION public.delete_own_account()
RETURNS VOID AS $$
BEGIN
  -- Check if user is logged in matches the execution context
  -- (Though RLS usually handles data, deleting from auth.users requires elevated privileges)
  -- preventing accidental deletion of others
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.delete_own_account() TO authenticated;
