# Supabase & Google Auth Setup Guide

To make the "Sign in with Google" button work, you need to configure Google Cloud and Supabase.

## 1. Google Cloud Console Setup

1.  Go to the [Google Cloud Console](https://console.cloud.google.com/).
2.  Create a new project (or select existing).
3.  Search for **"OAuth consent screen"** and configure it:
    *   User Type: **External**
    *   Fill in app name ("Skrolz"), support email, etc.
4.  Search for **"Credentials"** -> **Create Credentials** -> **OAuth client ID**.
    *   **Application type**: Web application (Yes, "Web" is correct for Supabase).
    *   **Name**: "Supabase Auth"
    *   **Authorized redirect URIs**:
        *   You need your Supabase Project URL. Go to Supabase Dashboard -> Project Settings -> API -> URL.
        *   Add: `https://<YOUR_PROJECT_ID>.supabase.co/auth/v1/callback`
5.  Copy the **Client ID** and **Client Secret**.

## 2. Supabase Dashboard Setup

1.  Go to your [Supabase Project Dashboard](https://supabase.com/dashboard).
2.  Navigate to **Authentication** -> **Providers**.
3.  Select **Google**.
4.  Enable **Google enabled**.
5.  Paste the **Client ID** and **Client Secret** from Google Cloud.
6.  Click **Save**.

## 3. URL Configuration in Supabase

1.  Navigate to **Authentication** -> **URL Configuration**.
2.  **Site URL**: Set this to your main app website or deep link, e.g., `skrolzapp://login-callback`.
3.  **Redirect URLs**: Add the following:
    *   `skrolzapp://login-callback` (IMPORTANT: This matches the code in `AuthScreen`).

## 4. Verification

1.  Run the app: `flutter run`.
2.  Go to the Auth screen.
3.  Tap "Sign in with Google".
4.  It should open a browser window to sign in.
5.  After sign in, it should redirect back to the app and log you in.

## Notes

*   **iOS**: `Info.plist` has been updated with `CFBundleURLTypes` for `skrolzapp`.
*   **Android**: `AndroidManifest.xml` has been updated with an `intent-filter` for `skrolzapp`.
*   **Release**: For Android release builds, you may need to add SHA-1 keys to Firebase/Google Cloud if using native Google Sign-In, but Supabase OAuth via browser (which we implemented) works with just the Web Client ID setup above.
