# Skrolz

**Short reads, one story at a time.**  
A vertical, full-screen content app (TikTok-style) powered by **Google Gemini 3**.

Built for the [Gemini 3 Hackathon](https://gemini3.devpost.com) (Feb 2026).

---

## Gemini 3 integration (~200 words)

Skrolz uses the **Gemini 3 API** (`gemini-3-flash-preview`) in three Supabase Edge Functions that are central to the product:

1. **generate-post** — Users enter a topic (and optional tone/length); Gemini 3 returns three distinct post variants in seconds. We use `thinkingLevel: "low"` and `temperature: 1.0` for fast, creative output and enforce a 280-character limit with validation.

2. **study-buddy** — For any topic, Gemini 3 returns two study tips, one actionable step, and one multiple-choice quiz in structured JSON. We use `thinkingLevel: "high"` and `responseMimeType: "application/json"` for reliable, well-reasoned answers and parse the response with fallbacks for robustness.

3. **moderate-content** — Every post and lesson is checked by Gemini 3 for safety (harassment, hate speech, etc.) before going live. We use explicit **cached contents** for system instructions to reduce tokens and latency, plus retries with exponential backoff for rate limits.

All three functions log `usageMetadata` for cost visibility, validate outputs before returning to the app, and handle errors gracefully. The Flutter app calls them via the Supabase client; the rest of the feed (ranking, recommendations) uses PostgreSQL and materialized views.

---

## Test account (hackathon judges & QA)

| Field       | Value                |
|------------|----------------------|
| **Name**   | Gemini Team          |
| **Email**  | `gemini@skrolz.app`  |
| **Password** | `Gemini@Skrolz26` |

This account is set up as **premium** in the backend for full access (see [TEST_ACCOUNT_SETUP.md](TEST_ACCOUNT_SETUP.md) for one-time backend setup).

---

## Repo & demo

- **Code:** [github.com/AmirmLotfy/skrolz](https://github.com/AmirmLotfy/skrolz)
- **Demo / PWA:** *(add your public app link if you deploy)*

---

## Tech stack

- **Frontend:** Flutter (Dart), Riverpod, go_router, Supabase Flutter, easy_localization (EN/AR), Drift (local cache)
- **Backend:** Supabase (PostgreSQL, Edge Functions on Deno), Gemini 3 API
- **Features:** Auth (email OTP, Google), For You feed, bookmarks, AI Post, Study Buddy, content moderation, bilingual UI

---

## Run locally

1. Clone and install:
   ```bash
   git clone https://github.com/AmirmLotfy/skrolz.git && cd skrolz
   flutter pub get
   ```

2. Configure Supabase (or run with placeholders for UI-only):
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

3. Optional: [Create the test user and grant premium](TEST_ACCOUNT_SETUP.md) in your Supabase project.

---

## Project structure

- `lib/` — Flutter app (screens, providers, theme, router)
- `supabase/functions/` — Edge Functions (`generate-post`, `study-buddy`, `moderate-content` use Gemini 3)
- `supabase/migrations/` — PostgreSQL schema and migrations

---

## Hackathon

- **Event:** [Gemini 3 Hackathon — Build what's next](https://gemini3.devpost.com)
- **Submission:** See [DEVPOST_SUBMISSION.md](DEVPOST_SUBMISSION.md) for pitch, story, and built-with list.
