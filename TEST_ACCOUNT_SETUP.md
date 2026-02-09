# Test Account for Hackathon Judges & App Testing

Use this account to sign in and test all features (including premium).

| Field    | Value                |
|----------|----------------------|
| **Name** | Gemini Team          |
| **Email**| `gemini@skrolz.app`  |
| **Password** | `Gemini@Skrolz26` |

## Backend setup (one-time)

To enable this account in your Supabase project:

1. **Create the user in Supabase**
   - Open [Supabase Dashboard](https://supabase.com/dashboard) → your project → **Authentication** → **Users** → **Add user** → **Create new user**.
   - Email: `gemini@skrolz.app`
   - Password: `Gemini@Skrolz26`
   - Optional: set display name to **Gemini Team**.

2. **Grant premium**
   - Either run the migration (if not already applied):
     ```bash
     supabase db push
     ```
   - Or run this SQL in **SQL Editor**:
     ```sql
     UPDATE public.profiles
     SET subscription_status = 'premium'
     WHERE id = (SELECT id FROM auth.users WHERE email = 'gemini@skrolz.app');
     ```

After that, signing in with the credentials above will have premium access (e.g. Study Buddy, all features).
