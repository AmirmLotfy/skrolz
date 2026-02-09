# Complete Supabase Setup Guide for Skrolz

This guide covers **all** manual steps needed in Supabase Dashboard to make your Skrolz app fully functional.

## 📋 Prerequisites

- You have a Supabase project created
- You have admin access to your Supabase Dashboard
- Your project is linked: `supabase link --project-ref YOUR_PROJECT_REF`

---

## 1. 🔐 Authentication Configuration

### 1.1 Enable Email Auth (Already Configured)
- Go to **Authentication** → **Providers**
- **Email** should already be enabled (default)
- **Confirm email** can be disabled for development (users sign in with OTP)

### 1.2 Enable Google OAuth (Required for "Sign in with Google")

#### Step A: Google Cloud Console Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Navigate to **APIs & Services** → **OAuth consent screen**:
   - **User Type**: External
   - **App name**: Skrolz
   - **Support email**: Your email
   - **Developer contact**: Your email
   - Click **Save and Continue**
   - Add scopes: `email`, `profile`, `openid` (usually pre-added)
   - Click **Save and Continue**
   - Add test users (your email) if app is in testing
   - Click **Save and Continue** → **Back to Dashboard**

4. Navigate to **APIs & Services** → **Credentials**:
   - Click **Create Credentials** → **OAuth client ID**
   - **Application type**: Web application
   - **Name**: Skrolz Auth
   - **Authorized redirect URIs**: 
     ```
     https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback
     ```
     (Replace `YOUR_PROJECT_ID` with your actual Supabase project ID)
   - Click **Create**
   - **Copy the Client ID and Client Secret**

#### Step B: Configure in Supabase
1. Go to **Authentication** → **Providers** → **Google**
2. Enable **Google enabled** toggle
3. Paste **Client ID** and **Client Secret** from Google Cloud
4. Click **Save**

### 1.3 Configure Redirect URLs
1. Go to **Authentication** → **URL Configuration**
2. **Site URL**: `skrolzapp://login-callback`
3. **Redirect URLs**: Add these (one per line):
   ```
   skrolzapp://login-callback
   http://localhost:3000
   https://YOUR_PROJECT_ID.supabase.co
   ```
4. Click **Save**

---

## 2. 🗄️ Database Setup

### 2.1 Verify All Migrations Are Applied
Run this command to check:
```bash
supabase db remote commit
```

If migrations are out of sync, push them:
```bash
supabase db push
```

### 2.2 Verify RLS (Row Level Security) Policies
Go to **Table Editor** → Check these tables have RLS enabled:
- ✅ `profiles`
- ✅ `posts`
- ✅ `lessons`
- ✅ `comments`
- ✅ `reactions`
- ✅ `follows`
- ✅ `blocks`
- ✅ `mutes`
- ✅ `reports`
- ✅ `collections`
- ✅ `collection_items`
- ✅ `notifications`

**If RLS is not enabled**, run:
```sql
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
-- Repeat for each table
```

### 2.3 Verify Storage Buckets
Go to **Storage** → **Buckets** → Ensure these exist:
- ✅ `avatars` (Public)
- ✅ `lesson-thumbnails` (Public)
- ✅ `lesson-images` (Public)

**If missing**, create them:
1. Click **New bucket**
2. Name: `avatars` → **Public bucket** → Create
3. Repeat for `lesson-thumbnails` and `lesson-images`

---

## 3. 🔧 Edge Functions Setup

### 3.1 Deploy All Edge Functions
Run this command to deploy all functions:
```bash
supabase functions deploy --no-verify-jwt moderate-content
supabase functions deploy --no-verify-jwt generate-post
supabase functions deploy --no-verify-jwt study-buddy
supabase functions deploy --no-verify-jwt notify-digest
supabase functions deploy --no-verify-jwt rank-feed
supabase functions deploy --no-verify-jwt recommend-content
```

### 3.2 Set Edge Function Secrets
Go to **Project Settings** → **Edge Functions** → **Secrets**

Add these secrets (click **Add secret** for each):

1. **GEMINI_API_KEY**
   - Value: Your Google Gemini API key
   - Get it from: [Google AI Studio](https://makersuite.google.com/app/apikey)

2. **SUPABASE_SERVICE_ROLE_KEY** (if needed by functions)
   - Value: Your service role key
   - Found in: **Project Settings** → **API** → **service_role** key (⚠️ Keep secret!)

3. **ONESIGNAL_APP_ID** (if using OneSignal)
   - Value: Your OneSignal App ID

4. **ONESIGNAL_REST_API_KEY** (if using OneSignal)
   - Value: Your OneSignal REST API Key

---

## 4. 📊 Database Functions & Triggers

### 4.1 Verify Cron Jobs Are Running
Go to **Database** → **Extensions** → Ensure `pg_cron` is enabled

If not enabled:
```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

### 4.2 Verify Materialized Views Refresh
Check that these views exist:
- `mv_trending_posts`
- `mv_trending_lessons`

If missing, they should be created by migration `20260206000002_materialized_views.sql`

---

## 5. 🔔 Notifications Setup (OneSignal)

### 5.1 OneSignal Configuration
1. Go to [OneSignal Dashboard](https://app.onesignal.com/)
2. Create an app or select existing
3. Get your **App ID** and **REST API Key**
4. Add them as Edge Function secrets (see section 3.2)

### 5.2 Android FCM Setup (For Push Notifications)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a project or select existing
3. Add Android app:
   - **Package name**: `com.skrolz.skrolz_app` (or your actual package name)
   - Download `google-services.json`
   - Place it in `android/app/`
4. Get **Server Key** from Firebase → Project Settings → Cloud Messaging
5. Add to OneSignal → Settings → Platforms → Google Android (FCM)

---

## 6. 🧪 Testing Checklist

After completing all steps, test these features:

### Authentication
- [ ] Email OTP sign-in works
- [ ] Google OAuth sign-in works (opens browser, redirects back)
- [ ] User profile is created automatically on signup

### Content
- [ ] Can create posts
- [ ] Can create lessons
- [ ] Feed loads content
- [ ] Can like/save content
- [ ] Can comment on content

### Settings
- [ ] Account screen shows email
- [ ] Sign out works
- [ ] Delete account works (with confirmation)
- [ ] Privacy screen shows blocked users
- [ ] Can unblock users
- [ ] Content preferences save
- [ ] AI preferences save
- [ ] Accessibility settings save
- [ ] Language selection works

### Feed Filtering
- [ ] Mature content filter works (if enabled)
- [ ] Blocked users' content doesn't appear
- [ ] Feed ranking works (For You tab)

---

## 7. 🚨 Common Issues & Fixes

### Issue: Google OAuth redirects but doesn't complete login
**Fix**: 
- Verify redirect URL in Supabase matches exactly: `skrolzapp://login-callback`
- Check iOS `Info.plist` has `CFBundleURLSchemes` with `skrolzapp`
- Check Android `AndroidManifest.xml` has intent-filter for `skrolzapp`

### Issue: Edge Functions return 401 Unauthorized
**Fix**:
- Verify `SUPABASE_SERVICE_ROLE_KEY` is set in Edge Function secrets
- Check function has proper CORS headers

### Issue: RLS policies blocking queries
**Fix**:
- Go to **Authentication** → **Policies**
- Verify policies allow authenticated users to read/write their own data
- Check policies for public read access on approved content

### Issue: Storage uploads fail
**Fix**:
- Verify bucket exists and is public (if needed)
- Check Storage policies allow authenticated uploads
- Verify file size limits in Storage settings

---

## 8. 📝 Final Steps

1. **Test the app**: Run `flutter run` and test all features
2. **Monitor logs**: Check Supabase Dashboard → Logs for errors
3. **Check Edge Functions**: Go to **Edge Functions** → Click each function → View logs
4. **Verify database**: Check **Table Editor** to see data being created

---

## ✅ Success Indicators

You'll know everything is working when:
- ✅ Users can sign in with email OTP
- ✅ Users can sign in with Google
- ✅ Content appears in feed
- ✅ Users can interact (like, save, comment)
- ✅ Settings save and persist
- ✅ Push notifications work (if configured)
- ✅ No errors in Supabase logs

---

## 📞 Need Help?

- **Supabase Docs**: https://supabase.com/docs
- **Flutter Supabase**: https://supabase.com/docs/reference/dart/introduction
- **Edge Functions**: https://supabase.com/docs/guides/functions

---

**Last Updated**: February 2026
**App Version**: Skrolz 1.0.0
