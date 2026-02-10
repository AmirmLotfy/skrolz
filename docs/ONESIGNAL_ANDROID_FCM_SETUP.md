# OneSignal Android FCM Configuration Guide

## Overview

This guide will help you complete the OneSignal Android (FCM) configuration. You need to:
1. Create/configure a Firebase project
2. Download the Service Account JSON file
3. Upload it to OneSignal
4. Complete the Android app configuration

---

## Step 1: Firebase Console Setup

### 1.1 Create/Select Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or select existing project
3. If creating new:
   - Enter project name (e.g., "Skrolz")
   - Enable/disable Google Analytics (optional)
   - Click **"Create project"**

### 1.2 Add Android App to Firebase

1. In Firebase Console, click **"Add app"** → Select **Android** icon
2. Fill in the Android package name:
   - **Package name**: `com.skrolz.app` (or your actual package name)
   - **App nickname**: Skrolz (optional)
   - **Debug signing certificate SHA-1**: (optional for now)
3. Click **"Register app"**

### 1.3 Download google-services.json

1. Download the `google-services.json` file
2. **Place it in**: `android/app/google-services.json`
3. **Important**: This file contains your Firebase configuration

### 1.4 Enable Cloud Messaging API

1. In Firebase Console, go to **Project Settings** → **Cloud Messaging** tab
2. Ensure **Cloud Messaging API (Legacy)** is enabled
3. If not enabled, click **"Enable"**

---

## Step 2: Get Service Account JSON

### 2.1 Create Service Account

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project (same as above)
3. Navigate to **IAM & Admin** → **Service Accounts**
4. Click **"Create Service Account"**
5. Fill in:
   - **Service account name**: `onesignal-fcm` (or any name)
   - **Service account ID**: Auto-generated
   - **Description**: "Service account for OneSignal FCM"
6. Click **"Create and Continue"**

### 2.2 Grant Permissions

1. In **Grant this service account access to project**:
   - Select role: **"Firebase Cloud Messaging Admin"** or **"Firebase Admin SDK Administrator Service Agent"**
2. Click **"Continue"** → **"Done"**

### 2.3 Generate JSON Key

1. Find your newly created service account in the list
2. Click on the service account email
3. Go to **"Keys"** tab
4. Click **"Add Key"** → **"Create new key"**
5. Select **JSON** format
6. Click **"Create"**
7. **The JSON file will download automatically** - **SAVE THIS FILE SECURELY**

---

## Step 3: Upload to OneSignal

### 3.1 Upload Service Account JSON

1. In OneSignal Dashboard (where you're currently at):
2. Click **"Select file"** under **Service Account JSON**
3. Upload the JSON file you downloaded in Step 2.3
4. OR click **"Retrieve from your Firebase Console"** if OneSignal supports auto-retrieval

### 3.2 Verify Upload

- OneSignal will validate the JSON file
- If valid, you'll see a success message
- If invalid, check:
  - File is valid JSON
  - Service account has correct permissions
  - Firebase project matches your app

---

## Step 4: Android App Configuration

### 4.1 Add google-services.json to Project

**File location**: `android/app/google-services.json`

```bash
# If you haven't already, place the downloaded google-services.json here:
android/app/google-services.json
```

### 4.2 Update Android Build Files

The project should already have OneSignal configured, but verify:

**File**: `android/build.gradle.kts` (or `build.gradle`)

Should include:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

**File**: `android/app/build.gradle.kts` (or `build.gradle`)

Should include at the bottom:
```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

### 4.3 Verify AndroidManifest.xml

**File**: `android/app/src/main/AndroidManifest.xml`

Should have internet permission (usually already present):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## Step 5: Complete OneSignal Configuration

### 5.1 App Settings

After uploading the Service Account JSON:

1. **App Name**: Skrolz (or your app name)
2. **Package Name**: `com.skrolz.app` (must match Firebase)
3. **Google Play Store URL**: (optional, add when published)

### 5.2 SDK Selection

- Select **Flutter SDK** (already configured in your project)
- OneSignal Flutter SDK version: `^5.4.0` (already in pubspec.yaml)

### 5.3 Install and Test

1. Click **"Save & Continue"**
2. Follow OneSignal's test instructions
3. Test push notifications on a physical Android device

---

## Step 6: Update App Configuration

### 6.1 Get OneSignal App ID

After completing setup:
1. Go to OneSignal Dashboard → **Settings** → **Keys & IDs**
2. Copy your **OneSignal App ID**
3. Update in Supabase Edge Functions secrets:
   ```bash
   supabase secrets set ONE_SIGNAL_APP_ID="your-actual-app-id"
   ```

### 6.2 Get REST API Key

1. Same page: **Keys & IDs**
2. Copy **REST API Key**
3. Update in Supabase Edge Functions secrets:
   ```bash
   supabase secrets set ONE_SIGNAL_REST_KEY="your-actual-rest-key"
   ```

### 6.3 Update Flutter App (Optional)

If you want to hardcode the App ID for testing (not recommended for production):

**File**: `lib/services/sdk_bootstrap.dart`

Currently uses environment variable:
```dart
const String _oneSignalAppId = String.fromEnvironment(
  'ONESIGNAL_APP_ID',
  defaultValue: '',
);
```

For local testing, you can temporarily set:
```dart
const String _oneSignalAppId = 'your-onesignal-app-id';
```

---

## Step 7: Verify Configuration

### 7.1 Check Files Exist

```bash
# Verify google-services.json exists
ls -la android/app/google-services.json

# Should show the file with proper permissions
```

### 7.2 Test OneSignal Integration

1. Run the app on an Android device
2. Grant notification permissions when prompted
3. Check OneSignal Dashboard → **Audience** → **All Users**
4. You should see your device registered

### 7.3 Test Push Notification

Use OneSignal Dashboard:
1. Go to **Messages** → **New Push**
2. Select your app
3. Enter test message
4. Click **"Send to Test Device"**
5. Should receive notification on device

---

## Troubleshooting

### Service Account JSON Issues

**Error**: "Invalid service account JSON"
- **Fix**: Ensure JSON file is valid and not corrupted
- **Fix**: Verify service account has Firebase Cloud Messaging Admin role

**Error**: "Permission denied"
- **Fix**: Check service account has correct IAM roles
- **Fix**: Ensure Firebase Cloud Messaging API is enabled

### Android Build Issues

**Error**: "google-services.json not found"
- **Fix**: Ensure file is at `android/app/google-services.json`
- **Fix**: Check file name is exactly `google-services.json` (case-sensitive)

**Error**: "Plugin with id 'com.google.gms.google-services' not found"
- **Fix**: Add Google Services plugin to `android/build.gradle.kts`
- **Fix**: Ensure classpath is correct version

### OneSignal Integration Issues

**Error**: "OneSignal not initialized"
- **Fix**: Check `ONESIGNAL_APP_ID` environment variable is set
- **Fix**: Verify OneSignal.initialize() is called in main.dart

**Error**: "Notifications not received"
- **Fix**: Check device has internet connection
- **Fix**: Verify notification permissions are granted
- **Fix**: Check OneSignal Dashboard for delivery status

---

## Security Notes

- **Never commit** `google-services.json` or Service Account JSON to public repositories
- Add to `.gitignore`:
  ```
  android/app/google-services.json
  *.json (service account files)
  ```
- Use environment variables for sensitive keys
- Rotate service account keys periodically

---

## Next Steps

After completing OneSignal setup:

1. ✅ Upload Service Account JSON to OneSignal
2. ✅ Complete Android app configuration
3. ✅ Test push notifications
4. ✅ Update Supabase secrets with OneSignal App ID and REST Key
5. ✅ Test Edge Functions (`notify-digest`, `notify-push`)

---

## Quick Reference

**Firebase Console**: https://console.firebase.google.com/
**Google Cloud Console**: https://console.cloud.google.com/
**OneSignal Dashboard**: https://app.onesignal.com/
**OneSignal Android Docs**: https://documentation.onesignal.com/docs/android-sdk-setup

---

**Status**: Ready for Service Account JSON upload to OneSignal! 🚀
