#!/bin/bash

# Non-interactive keystore creation script
# Usage: Set environment variables and run:
#   KEYSTORE_PASSWORD="your-password" KEY_PASSWORD="your-password" ./create_keystore_noninteractive.sh

set -e

KEYSTORE_NAME="skrolz-release-key.jks"
KEYSTORE_PATH="../$KEYSTORE_NAME"
KEY_ALIAS="skrolz"

# Check if passwords are provided
if [ -z "$KEYSTORE_PASSWORD" ] || [ -z "$KEY_PASSWORD" ]; then
    echo "❌ Error: KEYSTORE_PASSWORD and KEY_PASSWORD environment variables must be set"
    echo ""
    echo "Usage:"
    echo "  KEYSTORE_PASSWORD='your-store-password' KEY_PASSWORD='your-key-password' ./create_keystore_noninteractive.sh"
    echo ""
    echo "Or run the interactive script:"
    echo "  ./create_keystore.sh"
    exit 1
fi

# Check if keystore already exists
if [ -f "$KEYSTORE_PATH" ]; then
    echo "⚠️  WARNING: Keystore file already exists at: $KEYSTORE_PATH"
    read -p "Do you want to overwrite it? (yes/no): " overwrite
    if [ "$overwrite" != "yes" ]; then
        echo "Aborted. Keystore creation cancelled."
        exit 1
    fi
    rm -f "$KEYSTORE_PATH"
fi

echo "Creating keystore..."
echo ""

# Create keystore with provided passwords
# Using a dummy certificate (you can update CN, OU, O, L, ST, C as needed)
keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$KEY_ALIAS" \
    -storetype JKS \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=Skrolz App, OU=Development, O=Skrolz, L=City, ST=State, C=US"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore created successfully!"
    echo ""
    echo "Keystore location: $KEYSTORE_PATH"
    echo "Key alias: $KEY_ALIAS"
    echo ""
    echo "Next steps:"
    echo "1. Update android/key.properties with your passwords:"
    echo "   storePassword=$KEYSTORE_PASSWORD"
    echo "   keyPassword=$KEY_PASSWORD"
    echo ""
    echo "⚠️  IMPORTANT: Keep your keystore file and passwords secure!"
    echo "   If you lose them, you won't be able to update your app on Google Play."
else
    echo ""
    echo "❌ Failed to create keystore. Please check the error messages above."
    exit 1
fi
