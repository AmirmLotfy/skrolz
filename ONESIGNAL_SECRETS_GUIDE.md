# How to Get OneSignal Secrets

This guide shows exactly where to get each secret needed for OneSignal push notifications in Skrolz.

---

## 1. OneSignal App ID (required for the app)

**Used in:** Flutter app (`--dart-define=ONESIGNAL_APP_ID=...`)

### Steps

1. Go to **[OneSignal Dashboard](https://app.onesignal.com/)** and sign in.
2. Create an app if you don’t have one:
   - **New App/Website** → name it (e.g. "Skrolz") → choose **Google Android (FCM)**.
3. Open your app → left sidebar **Settings** (gear) → **Keys & IDs**.
4. Copy **OneSignal App ID** (e.g. `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).

**Use it when building:**
```bash
flutter build apk --release --dart-define=ONESIGNAL_APP_ID=your-app-id-here
```

---

## 2. OneSignal REST API Key (for backend / Supabase)

**Used in:** Supabase Edge Functions (e.g. `notify-digest`) to send push from the server.

### Steps

1. In OneSignal Dashboard → **Settings** → **Keys & IDs**.
2. Under **REST API Key**, click **Copy** or **Reveal** and copy the key.

**Add in Supabase:**

- **Supabase Dashboard** → your project → **Project Settings** → **Edge Functions** → **Secrets**.
- Add:
  - Name: `ONESIGNAL_APP_ID` → value: same App ID from step 1.
  - Name: `ONESIGNAL_REST_API_KEY` → value: the REST API Key you just copied.

---

## 3. Android (FCM): Firebase + Service Account JSON

**Used for:** OneSignal to send push to Android devices. You need a Firebase project and a Service Account key, then give it to OneSignal.

### 3.1 Create / use a Firebase project

1. Go to **[Firebase Console](https://console.firebase.google.com/)**.
2. **Add project** (or select existing) → name it (e.g. "Skrolz") → finish.
3. **Add app** → **Android**.
4. **Android package name:** `com.skrolz.skrolz_app` (must match your app).
5. Register app → download **google-services.json**.
6. Put the file here: **`android/app/google-services.json`**.

### 3.2 Enable Cloud Messaging

1. In Firebase: **Project Settings** (gear) → **Cloud Messaging**.
2. If you see **Cloud Messaging API (Legacy)** or **Cloud Messaging**, ensure it’s enabled (enable if asked).

### 3.3 Create Service Account and download JSON

1. Go to **[Google Cloud Console](https://console.cloud.google.com/)**.
2. At the top, select the **same project** as your Firebase project.
3. **IAM & Admin** → **Service Accounts**.
4. **Create Service Account**:
   - Name: e.g. `onesignal-fcm`
   - **Create and Continue**.
5. **Grant access:** add role **Firebase Cloud Messaging Admin** (or **Firebase Admin SDK Administrator Service Agent**).
6. **Done**.
7. Click the new service account → **Keys** tab → **Add Key** → **Create new key** → **JSON** → **Create**.
8. The JSON file downloads. **Keep it private.**

### 3.4 Give the JSON to OneSignal

1. In **OneSignal Dashboard** → your app → **Settings** → **Platforms** → **Google Android (FCM)**.
2. Under **FCM Configuration**, use **Upload** or **Service Account JSON**.
3. Upload the JSON file you downloaded (or paste contents if that’s the only option).
4. Save. OneSignal will use this to send to your Android app.

---

## Quick checklist

| Secret | Where to get it | Where to use it |
|--------|-----------------|------------------|
| **OneSignal App ID** | OneSignal → Settings → Keys & IDs | App: `--dart-define=ONESIGNAL_APP_ID=...`; Supabase secret `ONESIGNAL_APP_ID` |
| **OneSignal REST API Key** | OneSignal → Settings → Keys & IDs | Supabase secret `ONESIGNAL_REST_API_KEY` |
| **FCM (Android)** | Firebase project + Service Account JSON | Upload in OneSignal → Platforms → Google Android (FCM); put `google-services.json` in `android/app/` |

---

## Testing

1. Build and run the app with your App ID:
   ```bash
   flutter run --dart-define=ONESIGNAL_APP_ID=your-app-id
   ```
2. Accept notification permission when prompted.
3. In OneSignal Dashboard → **Audience** → **All Users** you should see the device.
4. Send a test notification from **Messages** → **New Push** to verify delivery.

---

## Links

- OneSignal Dashboard: https://app.onesignal.com/
- OneSignal Keys & IDs: Dashboard → Settings → Keys & IDs
- Firebase Console: https://console.firebase.google.com/
- Google Cloud Console: https://console.cloud.google.com/
- OneSignal Android setup: https://documentation.onesignal.com/docs/android-sdk-setup

For full FCM setup (including `google-services.json` and Gradle), see **ONESIGNAL_ANDROID_FCM_SETUP.md**.
