# Quick Start: Create Your Keystore

## Option 1: Interactive (Recommended for First Time)

Run the interactive script and follow the prompts:

```bash
cd android
./create_keystore.sh
```

You'll be asked to:
- Enter a keystore password (at least 6 characters)
- Re-enter the password
- Enter a key password (can be same as keystore password)
- Enter your name and organization details

## Option 2: Non-Interactive (Using Environment Variables)

If you want to automate it, use the non-interactive script:

```bash
cd android
KEYSTORE_PASSWORD="your-strong-password-here" \
KEY_PASSWORD="your-strong-password-here" \
./create_keystore_noninteractive.sh
```

**⚠️ Security Warning:** Don't put passwords in command history. Use environment variables or type them when prompted.

## After Creating the Keystore

1. **Update `android/key.properties`** with your passwords:
   ```properties
   storePassword=your-actual-store-password
   keyPassword=your-actual-key-password
   keyAlias=skrolz
   storeFile=../skrolz-release-key.jks
   ```

2. **Verify the keystore was created:**
   ```bash
   ls -lh ../skrolz-release-key.jks
   ```

3. **Test a release build:**
   ```bash
   flutter build apk --release
   ```

## Need Help?

See `KEYSTORE_SETUP_GUIDE.md` for detailed instructions and troubleshooting.
