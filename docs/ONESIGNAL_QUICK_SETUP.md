# OneSignal Android FCM - Quick Setup Checklist

## 🎯 What You Need to Do Right Now

You're at **Step 1** of the OneSignal Android configuration. Here's exactly what to do:

---

## ✅ Step 1: Get Firebase Service Account JSON

### Option A: Retrieve from Firebase Console (Easiest)

1. **Click "Retrieve from your Firebase Console"** button in OneSignal
2. OneSignal will guide you through the process
3. Follow the prompts to authorize OneSignal to access Firebase

### Option B: Manual Upload (If Option A doesn't work)

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project** (or create one for "Skrolz")
3. **Go to Project Settings** (gear icon) → **Service Accounts** tab
4. **Click "Generate New Private Key"**
5. **Download the JSON file** (this is your Service Account JSON)
6. **Upload it** to OneSignal using "Select file" button

---

## 📋 Your App Details for OneSignal

When configuring in OneSignal, use these values:

- **Package Name**: `com.skrolz.skrolz_app`
- **App Name**: Skrolz
- **SDK**: Flutter SDK (already configured)

---

## 🔧 After Uploading JSON

Once you upload the Service Account JSON:

1. **Click "Save & Continue"**
2. **Select SDK**: Choose "Flutter SDK"
3. **Install and Test**: Follow OneSignal's test instructions

---

## 📝 Next Steps After OneSignal Setup

After completing the OneSignal configuration:

1. **Get your OneSignal App ID** from Dashboard → Settings → Keys & IDs
2. **Get your OneSignal REST API Key** from same page
3. **Update Supabase secrets**:
   ```bash
   supabase secrets set ONE_SIGNAL_APP_ID="your-app-id"
   supabase secrets set ONE_SIGNAL_REST_KEY="your-rest-key"
   ```

---

## 🚨 Important Notes

- **Package Name**: Must match exactly: `com.owlna.owlna_app`
- **Service Account JSON**: Keep this file secure, never commit to git
- **google-services.json**: You'll also need this file later (download from Firebase Console)

---

## 📚 Full Documentation

See `ONESIGNAL_ANDROID_FCM_SETUP.md` for complete detailed guide.

---

**Current Status**: Ready to upload Service Account JSON to OneSignal! 🚀
