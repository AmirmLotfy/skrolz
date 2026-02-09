# Edge Functions Secrets Configuration

## ✅ All Edge Functions Deployed

All 7 core Edge Functions have been deployed and are active:

1. ✅ `rank-feed` - Feed ranking algorithm
2. ✅ `moderate-content` - Content moderation
3. ✅ `generate-post` - AI post generation
4. ✅ `study-buddy` - Study tips generation
5. ✅ `revenuecat-webhook` - Subscription webhook
6. ✅ `notify-digest` - Daily digest notifications
7. ✅ `recommend-content` - Content recommendations

---

## 🔐 Secrets Configuration

### Placeholder Secrets Set

The following placeholder secrets have been set. **Please replace them with actual values** in the Supabase Dashboard:

#### 1. **GEMINI_API_KEY** ⚠️ REQUIRED
- **Used by**: `moderate-content`, `generate-post`, `study-buddy`
- **Current Value**: `PLACEHOLDER_REPLACE_WITH_ACTUAL_GEMINI_API_KEY`
- **How to get**: 
  1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
  2. Create a new API key
  3. Copy the key
- **Update in Supabase**:
  - Dashboard → Project Settings → Edge Functions → Secrets
  - Find `GEMINI_API_KEY`
  - Replace placeholder with actual key

#### 2. **ONE_SIGNAL_APP_ID** ⚠️ REQUIRED
- **Used by**: `notify-digest`, `notify-push`
- **Current Value**: `PLACEHOLDER_REPLACE_WITH_ACTUAL_ONESIGNAL_APP_ID`
- **How to get**:
  1. Go to [OneSignal Dashboard](https://app.onesignal.com/)
  2. Select your app (or create one)
  3. Go to Settings → Keys & IDs
  4. Copy the App ID
- **Update in Supabase**:
  - Dashboard → Project Settings → Edge Functions → Secrets
  - Find `ONE_SIGNAL_APP_ID`
  - Replace placeholder with actual App ID

#### 3. **ONE_SIGNAL_REST_KEY** ⚠️ REQUIRED
- **Used by**: `notify-digest`, `notify-push`
- **Current Value**: `PLACEHOLDER_REPLACE_WITH_ACTUAL_ONESIGNAL_REST_KEY`
- **How to get**:
  1. Go to [OneSignal Dashboard](https://app.onesignal.com/)
  2. Select your app
  3. Go to Settings → Keys & IDs
  4. Copy the REST API Key
- **Update in Supabase**:
  - Dashboard → Project Settings → Edge Functions → Secrets
  - Find `ONE_SIGNAL_REST_KEY`
  - Replace placeholder with actual REST Key

---

## 🔄 Auto-Configured Secrets

These secrets are automatically set by Supabase and don't need manual configuration:

- ✅ `SUPABASE_URL` - Your Supabase project URL
- ✅ `SUPABASE_ANON_KEY` - Anonymous key for public access
- ✅ `SUPABASE_SERVICE_ROLE_KEY` - Service role key for admin operations
- ✅ `SUPABASE_DB_URL` - Database connection URL

---

## 📋 Functions and Their Secret Requirements

| Function | Secrets Required | Status |
|----------|----------------|--------|
| `rank-feed` | `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` | ✅ Auto-configured |
| `moderate-content` | `GEMINI_API_KEY` | ⚠️ Needs update |
| `generate-post` | `GEMINI_API_KEY` | ⚠️ Needs update |
| `study-buddy` | `GEMINI_API_KEY` | ⚠️ Needs update |
| `revenuecat-webhook` | `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` | ✅ Auto-configured |
| `notify-digest` | `ONE_SIGNAL_APP_ID`, `ONE_SIGNAL_REST_KEY` | ⚠️ Needs update |
| `recommend-content` | `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` | ✅ Auto-configured |

---

## 🚀 How to Update Secrets

### Option 1: Supabase Dashboard (Recommended)
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: **Skrolz** (`vbtalhrapzpuvxuagren`)
3. Navigate to: **Settings** → **Edge Functions** → **Secrets**
4. Find each placeholder secret
5. Click **Edit** and replace with actual value
6. Click **Save**

### Option 2: Supabase CLI
```bash
# Update GEMINI_API_KEY
supabase secrets set GEMINI_API_KEY="your-actual-gemini-api-key"

# Update OneSignal App ID
supabase secrets set ONE_SIGNAL_APP_ID="your-actual-onesignal-app-id"

# Update OneSignal REST Key
supabase secrets set ONE_SIGNAL_REST_KEY="your-actual-onesignal-rest-key"
```

---

## ✅ Verification

After updating secrets, verify they're set correctly:

```bash
supabase secrets list
```

You should see:
- `GEMINI_API_KEY` - (should NOT show "PLACEHOLDER")
- `ONE_SIGNAL_APP_ID` - (should NOT show "PLACEHOLDER")
- `ONE_SIGNAL_REST_KEY` - (should NOT show "PLACEHOLDER")

---

## 🧪 Testing Functions

After updating secrets, test the functions:

### Test moderate-content
```bash
curl -X POST https://vbtalhrapzpuvxuagren.supabase.co/functions/v1/moderate-content \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "This is a test post"}'
```

### Test generate-post
```bash
curl -X POST https://vbtalhrapzpuvxuagren.supabase.co/functions/v1/generate-post \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"topic": "Flutter development", "tone": "friendly"}'
```

### Test study-buddy
```bash
curl -X POST https://vbtalhrapzpuvxuagren.supabase.co/functions/v1/study-buddy \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"topic": "Machine Learning"}'
```

---

## 📝 Notes

- **Placeholder values**: Functions will work but may return fallback/default responses until real secrets are added
- **Security**: Never commit actual secrets to git
- **Rotation**: Update secrets regularly for security
- **Monitoring**: Check Edge Function logs in Supabase Dashboard if functions fail

---

## 🎯 Next Steps

1. ✅ All Edge Functions deployed
2. ⚠️ **Replace placeholder secrets with actual values** (see above)
3. ✅ Test functions after updating secrets
4. ✅ Monitor function logs for any issues

**All Edge Functions are deployed and ready - just need to update the placeholder secrets!** 🚀
