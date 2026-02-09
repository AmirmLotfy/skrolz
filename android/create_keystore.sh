#!/bin/bash

# Script to create release keystore for Skrolz Android app
# This will prompt you for passwords and create the keystore file

set -e

KEYSTORE_NAME="skrolz-release-key.jks"
KEYSTORE_PATH="../$KEYSTORE_NAME"
KEY_ALIAS="skrolz"

echo "=========================================="
echo "Skrolz Release Keystore Creation"
echo "=========================================="
echo ""
echo "This script will create a release keystore for signing your Android app."
echo "You will be prompted to enter passwords - make sure to save them securely!"
echo ""

# Check if keystore already exists
if [ -f "$KEYSTORE_PATH" ]; then
    echo "⚠️  WARNING: Keystore file already exists at: $KEYSTORE_PATH"
    read -p "Do you want to overwrite it? (yes/no): " overwrite
    if [ "$overwrite" != "yes" ]; then
        echo "Aborted. Keystore creation cancelled."
        exit 1
    fi
fi

echo "Creating keystore..."
echo ""

# Create the keystore
keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$KEY_ALIAS" \
    -storetype JKS

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore created successfully!"
    echo ""
    echo "Keystore location: $KEYSTORE_PATH"
    echo "Key alias: $KEY_ALIAS"
    echo ""
    echo "Next steps:"
    echo "1. Copy android/key.properties.template to android/key.properties"
    echo "2. Fill in your passwords in android/key.properties"
    echo "3. Update the storeFile path if needed"
    echo ""
    echo "⚠️  IMPORTANT: Keep your keystore file and passwords secure!"
    echo "   If you lose them, you won't be able to update your app on Google Play."
else
    echo ""
    echo "❌ Failed to create keystore. Please check the error messages above."
    exit 1
fi
