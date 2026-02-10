# Keystore Setup Guide for Production Builds

## Overview
This guide will help you create a release keystore for signing your Android app for production release on Google Play Store.

## Quick Start

### Option 1: Using the Automated Script (Recommended)

1. **Run the keystore creation script:**
   ```bash
   cd android
   ./create_keystore.sh
   ```

2. **Follow the prompts:**
   - Enter a strong password for the keystore (store password)
   - Enter a strong password for the key (key password) - can be the same
   - Fill in your details (name, organization, etc.)

3. **Configure key.properties:**
   - The file `android/key.properties` already exists with placeholders
   - Open `android/key.properties` and replace `CHANGE_ME` with your actual passwords:
     ```properties
     storePassword=your-actual-store-password
     keyPassword=your-actual-key-password
     keyAlias=skrolz
     storeFile=../skrolz-release-key.jks
     ```

### Option 2: Manual Creation

1. **Create the keystore:**
   ```bash
   keytool -genkey -v \
     -keystore skrolz-release-key.jks \
     -keyalg RSA \
     -keysize 2048 \
     -validity 10000 \
     -alias skrolz \
     -storetype JKS
   ```

2. **Move the keystore:**
   ```bash
   mv skrolz-release-key.jks android/
   ```

3. **Configure key.properties:**
   - Copy `android/key.properties.template` to `android/key.properties`
   - Fill in your passwords

## File Locations

- **Keystore file**: `android/skrolz-release-key.jks` (or custom path)
- **Properties file**: `android/key.properties`
- **Template**: `android/key.properties.template`

## Security Best Practices

1. **Never commit these files to Git:**
   - `android/key.properties` is already in `.gitignore`
   - `android/*.jks` and `android/*.keystore` are already in `.gitignore`
   - Keep your keystore file secure and backed up

2. **Use strong passwords:**
   - Store password: At least 12 characters, mix of letters, numbers, symbols
   - Key password: Can be the same or different, but also strong

3. **Backup your keystore:**
   - Store a copy in a secure location (encrypted cloud storage, password manager)
   - If you lose the keystore, you cannot update your app on Google Play
   - You'll need to create a new app listing if the keystore is lost

4. **Document passwords securely:**
   - Use a password manager
   - Don't store passwords in plain text files
   - Share securely with team members if needed

## Verifying Your Keystore

To verify your keystore was created correctly:

```bash
keytool -list -v -keystore android/skrolz-release-key.jks -alias skrolz
```

You'll be prompted for the store password. This will show you the keystore details.

## Building Release APK/AAB

Once your keystore is configured, build your release app:

### Build App Bundle (for Google Play):
```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=ONESIGNAL_APP_ID=your-onesignal-app-id
```

### Build APK (for direct distribution):
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=ONESIGNAL_APP_ID=your-onesignal-app-id
```

The output will be in:
- **AAB**: `build/app/outputs/bundle/release/app-release.aab`
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

### Error: "Keystore file not found"
- Make sure `storeFile` path in `key.properties` is correct
- Use relative path from `android/` directory: `../skrolz-release-key.jks`
- Or use absolute path: `/full/path/to/skrolz-release-key.jks`

### Error: "Password was incorrect"
- Double-check your passwords in `key.properties`
- Make sure there are no extra spaces or special characters
- Try regenerating the keystore if you're unsure

### Error: "Key alias not found"
- Verify the alias in `key.properties` matches the one used when creating the keystore
- Default alias is `skrolz`

### Build still uses debug signing
- Make sure `key.properties` exists and is properly configured
- Check that `build.gradle.kts` is loading the properties correctly
- Verify the keystore file exists at the specified path

## Next Steps

After creating your keystore:

1. ✅ Test building a release APK locally
2. ✅ Install and test the release APK on a physical device
3. ✅ Verify all features work correctly
4. ✅ Upload AAB to Google Play Console (Internal Testing track first)
5. ✅ Test thoroughly before releasing to production

## Support

If you encounter issues:
1. Check the error messages carefully
2. Verify all file paths and passwords
3. Ensure Java keytool is installed (`keytool -version`)
4. Review the build logs for detailed error information
