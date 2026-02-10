# Android Production Build Checklist

## ✅ Completed Items

- [x] App version configured (1.0.0+1)
- [x] Application ID set (com.skrolz.skrolz_app)
- [x] AndroidManifest.xml configured with permissions
- [x] Deep linking configured for OAuth
- [x] ProGuard/R8 enabled (default)
- [x] Min/Target SDK versions configured
- [x] App name set ("Skrolz")
- [x] Icon configured (@mipmap/ic_launcher)

## ⚠️ Critical Issues to Fix Before Production

### 1. **App Signing Configuration** 🔴 CRITICAL
**Status**: Currently using debug signing for release builds
**Location**: `android/app/build.gradle.kts` line 37
**Action Required**: 
- Create a release keystore
- Configure signing in `android/app/build.gradle.kts`
- Store keystore securely (NOT in git)

**Steps**:
```bash
# Generate keystore
keytool -genkey -v -keystore ~/skrolz-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias skrolz

# Create android/key.properties (add to .gitignore)
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=skrolz
storeFile=<path-to-keystore>
```

### 2. **Environment Variables** 🔴 CRITICAL
**Status**: Using placeholders/default values
**Location**: `lib/data/supabase/supabase_client.dart`
**Action Required**: 
- Set `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `--dart-define` when building
- Ensure OneSignal App ID is set if using push notifications
- RevenueCat API key (optional, since subscriptions are disabled)

**Build Command**:
```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=ONESIGNAL_APP_ID=your-onesignal-app-id
```

### 3. **Debug Logging** 🟡 RECOMMENDED
**Status**: Router debug logging enabled
**Location**: `lib/router/app_router.dart` line 119
**Action Required**: Disable in production builds

### 4. **ProGuard/R8 Rules** 🟡 RECOMMENDED
**Status**: No custom rules defined
**Action Required**: Add rules for third-party libraries if needed

## 📋 Pre-Build Checklist

- [ ] **Signing**: Release keystore created and configured
- [ ] **Environment Variables**: Supabase URL/Key set via `--dart-define`
- [ ] **OneSignal**: App ID configured (if using push notifications)
- [ ] **Version**: Update version in `pubspec.yaml` if needed
- [ ] **Testing**: Test release build on device before uploading
- [ ] **Google Play Console**: App listing prepared
- [ ] **Privacy Policy**: URL added to Play Console
- [ ] **App Icon**: Ensure all sizes are present
- [ ] **Screenshots**: Prepare for Play Store listing

## 🔧 Build Commands

### Release APK (for testing)
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=your-url \
  --dart-define=SUPABASE_ANON_KEY=your-key \
  --dart-define=ONESIGNAL_APP_ID=your-app-id
```

### Release App Bundle (for Play Store)
```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=your-url \
  --dart-define=SUPABASE_ANON_KEY=your-key \
  --dart-define=ONESIGNAL_APP_ID=your-app-id
```

## 📝 Notes

- The app uses environment variables for configuration, so ensure they're set during build
- Debug signing is currently enabled for release - this MUST be changed before production
- All features are free (subscriptions disabled), so RevenueCat key is optional
- Google OAuth requires manual setup in Google Cloud Console (see SUPABASE_GOOGLE_AUTH_SETUP.md)

## 🚀 Next Steps

1. Create release keystore
2. Configure signing in build.gradle.kts
3. Set environment variables
4. Build and test release APK
5. Build App Bundle for Play Store
6. Upload to Google Play Console
