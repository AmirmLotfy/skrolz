# 🔐 Google Auth Setup - Step by Step Guide

Follow these steps to enable "Sign in with Google" in your Skrolz app.

---

## Step 1: Google Cloud Console Setup

### 1.1 Create/Select Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click the project dropdown at the top
3. Click **New Project** (or select existing)
4. Name: **Skrolz** (or your preferred name)
5. Click **Create**

### 1.2 Configure OAuth Consent Screen
1. In the left sidebar, go to **APIs & Services** → **OAuth consent screen**
2. Select **External** (unless you have a Google Workspace account)
3. Click **Create**

**Fill in the form:**
- **App name**: `Skrolz`
- **User support email**: Your email address
- **App logo**: (Optional - upload your Skrolz logo)
- **App domain**: (Optional - leave blank for now)
- **Application home page**: (Optional - your website if you have one)
- **Authorized domains**: (Optional - leave blank for now)
- **Developer contact information**: Your email address

4. Click **Save and Continue**

**Scopes:**
- The default scopes (`email`, `profile`, `openid`) should already be there
- Click **Save and Continue**

**Test users:**
- If your app is in "Testing" mode, add your email address as a test user
- Click **Save and Continue**
- Click **Back to Dashboard**

### 1.3 Create OAuth Credentials
1. Go to **APIs & Services** → **Credentials**
2. Click **+ Create Credentials** → **OAuth client ID**

**If prompted to configure consent screen:**
- Click **Configure Consent Screen** and complete Step 1.2 above first

**Create OAuth Client ID:**
- **Application type**: Select **Web application**
- **Name**: `Skrolz Auth`
- **Authorized JavaScript origins**: Leave empty (not needed for mobile)
- **Authorized redirect URIs**: Add this URL:
  ```
  https://vbtalhrapzpuvxuagren.supabase.co/auth/v1/callback
  ```
  (This is your Supabase project callback URL)

3. Click **Create**
4. **IMPORTANT**: Copy both:
   - **Client ID** (looks like: `123456789-abcdefghijklmnop.apps.googleusercontent.com`)
   - **Client Secret** (looks like: `GOCSPX-abcdefghijklmnopqrstuvwxyz`)

**⚠️ Save these securely - you'll need them in Step 2!**

---

## Step 2: Configure Supabase

### 2.1 Enable Google Provider
1. Go to your [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: **vbtalhrapzpuvxuagren**
3. Go to **Authentication** → **Providers**
4. Find **Google** in the list
5. Click the toggle to **Enable** Google provider

### 2.2 Add Credentials
1. In the Google provider settings, paste:
   - **Client ID (for OAuth)**: Paste the Client ID from Step 1.3
   - **Client Secret (for OAuth)**: Paste the Client Secret from Step 1.3
2. Click **Save**

### 2.3 Configure Redirect URLs
1. Still in **Authentication**, go to **URL Configuration**
2. **Site URL**: Set to:
   ```
   skrolzapp://login-callback
   ```
3. **Redirect URLs**: Add these (one per line):
   ```
   skrolzapp://login-callback
   http://localhost:3000
   https://vbtalhrapzpuvxuagren.supabase.co
   ```
4. Click **Save**

---

## Step 3: Verify App Configuration

### 3.1 iOS Configuration (Already Done ✅)
- ✅ `Info.plist` has `CFBundleURLSchemes` with `skrolzapp`
- ✅ Deep linking is configured

### 3.2 Android Configuration (Already Done ✅)
- ✅ `AndroidManifest.xml` has intent-filter for `skrolzapp://login-callback`
- ✅ Deep linking is configured

---

## Step 4: Test Google Sign-In

1. **Run your app**:
   ```bash
   flutter run
   ```

2. **Navigate to Auth Screen** (should be the first screen)

3. **Tap "Sign in with Google"** button

4. **Expected flow**:
   - Browser window opens (or in-app browser)
   - Google sign-in page appears
   - Select your Google account
   - Grant permissions
   - Browser redirects back to app
   - App should automatically log you in
   - You should see the home screen

---

## 🚨 Troubleshooting

### Issue: "Redirect URI mismatch"
**Fix**: 
- Check that the redirect URI in Google Cloud Console exactly matches:
  ```
  https://vbtalhrapzpuvxuagren.supabase.co/auth/v1/callback
  ```
- Check that Supabase redirect URLs include `skrolzapp://login-callback`

### Issue: Browser opens but doesn't redirect back
**Fix**:
- Verify `Info.plist` (iOS) has `skrolzapp` in `CFBundleURLSchemes`
- Verify `AndroidManifest.xml` has intent-filter for `skrolzapp`
- Check Supabase redirect URLs include `skrolzapp://login-callback`

### Issue: "OAuth consent screen not configured"
**Fix**:
- Complete Step 1.2 (OAuth Consent Screen) in Google Cloud Console
- Make sure you've added test users if app is in "Testing" mode

### Issue: "Invalid client credentials"
**Fix**:
- Double-check Client ID and Client Secret are correct in Supabase
- Make sure there are no extra spaces when copying/pasting
- Regenerate credentials in Google Cloud Console if needed

### Issue: App crashes when tapping Google sign-in
**Fix**:
- Check that `redirectTo: 'skrolzapp://login-callback'` matches exactly in `auth_screen.dart`
- Verify deep linking is properly configured (see Step 3)

---

## ✅ Success Checklist

You'll know it's working when:
- ✅ Google sign-in button opens browser
- ✅ You can select a Google account
- ✅ Browser redirects back to app automatically
- ✅ App shows you're logged in
- ✅ Profile is created automatically
- ✅ You can access all app features

---

## 📝 Quick Reference

**Your Supabase Project ID**: `vbtalhrapzpuvxuagren`

**Callback URL for Google Cloud**:
```
https://vbtalhrapzpuvxuagren.supabase.co/auth/v1/callback
```

**Deep Link Scheme**: `skrolzapp://login-callback`

**Where to find Supabase settings**:
- Dashboard: https://supabase.com/dashboard/project/vbtalhrapzpuvxuagren
- Authentication: https://supabase.com/dashboard/project/vbtalhrapzpuvxuagren/auth/providers
- URL Config: https://supabase.com/dashboard/project/vbtalhrapzpuvxuagren/auth/url-configuration

---

**Need help?** Check the full guide: `SUPABASE_COMPLETE_SETUP_GUIDE.md`
