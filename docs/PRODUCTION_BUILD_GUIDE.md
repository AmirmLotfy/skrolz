# Production Build Guide for Skrolz Android App

## 🚨 Critical: Before Building for Production

### 1. Create Release Keystore

**Generate a keystore file** (one-time setup):
```bash
keytool -genkey -v -keystore ~/skrolz-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias skrolz
```

**Important**: 
- Store the keystore file securely (NOT in git)
- Remember the passwords you set
- Keep a backup of the keystore file
- You'll need this keystore for all future app updates

### 2. Configure Signing

**Create `android/key.properties`** (add to `.gitignore`):
```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=skrolz
storeFile=/path/to/skrolz-release-key.jks
```

**Update `android/app/build.gradle.kts`**:
Replace the `buildTypes` section with the production configuration from `build.gradle.kts.production.example`.

### 3. Set Environment Variables

You MUST provide these when building:
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key
- `ONESIGNAL_APP_ID`: Your OneSignal App ID (if using push notifications)

## 📦 Building for Production

### Option 1: Build App Bundle (Recommended for Play Store)

```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=ONESIGNAL_APP_ID=your-onesignal-app-id
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

### Option 2: Build APK (For Testing or Direct Distribution)

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=ONESIGNAL_APP_ID=your-onesignal-app-id
```

**Output**: `build/app/outputs/flutter-apk/app-release.apk`

### Option 3: Split APKs by ABI (Smaller file size)

```bash
flutter build apk --split-per-abi --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=ONESIGNAL_APP_ID=your-onesignal-app-id
```

**Output**: Separate APKs for `arm64-v8a`, `armeabi-v7a`, `x86_64`

## ✅ Pre-Upload Checklist

- [ ] Keystore created and secured
- [ ] `key.properties` configured (not in git)
- [ ] `build.gradle.kts` updated with release signing
- [ ] Environment variables set correctly
- [ ] Release build tested on physical device
- [ ] App version updated in `pubspec.yaml` if needed
- [ ] Google Play Console account ready
- [ ] App listing prepared (description, screenshots, etc.)
- [ ] Privacy Policy URL ready
- [ ] Content rating questionnaire completed

## 🔍 Testing Release Build

Before uploading to Play Store:

1. **Install on device**:
   ```bash
   flutter install --release
   ```

2. **Test critical flows**:
   - [ ] App launches correctly
   - [ ] Authentication works (email + Google OAuth)
   - [ ] Feed loads and displays content
   - [ ] Navigation works correctly
   - [ ] Push notifications work (if enabled)
   - [ ] Offline functionality works
   - [ ] No crashes or errors

3. **Check logs** (if issues):
   ```bash
   adb logcat | grep flutter
   ```

## 📤 Uploading to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app or select existing
3. Go to **Release** → **Production** → **Create new release**
4. Upload the `.aab` file from `build/app/outputs/bundle/release/`
5. Fill in release notes
6. Review and roll out

## 🔐 Security Notes

- **Never commit**:
  - `key.properties`
  - `*.jks` or `*.keystore` files
  - API keys or secrets in code
  
- **Use environment variables** for all sensitive data
- **Keep keystore backup** in secure location
- **Use different keystores** for different apps/environments

## 🐛 Troubleshooting

### Build fails with "Signing config not found"
- Ensure `key.properties` exists and is correctly formatted
- Check that `build.gradle.kts` references the signing config correctly

### App crashes on release build
- Check ProGuard rules in `proguard-rules.pro`
- Test with `isMinifyEnabled = false` first to isolate issues
- Check logs: `adb logcat | grep -i error`

### Environment variables not working
- Ensure you're using `--dart-define` flag
- Check that variables are accessed via `String.fromEnvironment()`
- Verify no typos in variable names

## 📚 Additional Resources

- [Flutter Build and Release](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer/)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
