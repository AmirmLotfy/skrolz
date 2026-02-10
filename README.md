# Skrolz

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Short reads, one story at a time.**

Skrolz is a vertical, full-screen content app (TikTok-style) for bite-sized reading: swipe through short posts and multi-slide lessons, one story at a time. It is powered by **Google Gemini 3** for AI-powered creation, study help, and content moderation.

Built for the [Gemini 3 Hackathon](https://gemini3.devpost.com) (Feb 2026).

---

## About the app

Skrolz brings the short-form, swipeable experience to text. Instead of endless feeds, you get **one full-screen card at a time**—short posts (up to 280 characters) or multi-slide lessons with takeaways and quizzes. The app is **bilingual (English + Arabic)** with RTL support and runs on **Android, iOS, Web (PWA), and desktop** via Flutter.

**For readers:** A personalized “For You” feed, bookmarks, and the ability to dive deeper with **Study Buddy** (tips, actions, and a micro-quiz per topic).

**For creators:** Write posts or lessons manually, or use **AI Post** to generate up to three variants from a topic and optional tone/length. All content is checked by **Gemini 3** for safety before it goes live.

---

## Try the app

| | |
|---|---|
| **Android APK** | [Download app-release.apk](https://drive.google.com/file/d/1pYCpM-KuAW7JsGY00C8QHmm7SqtZcXmT/view?usp=sharing) — install on your device and sign in with the test account below. |
| **Source code** | [github.com/AmirmLotfy/skrolz](https://github.com/AmirmLotfy/skrolz) |

### Test account (judges & QA)

| Field | Value |
|-------|--------|
| **Name** | Gemini Team |
| **Email** | `gemini@skrolz.app` |
| **Password** | `Gemini@Skrolz26` |

This account has **premium** access (e.g. Study Buddy). Backend setup: [TEST_ACCOUNT_SETUP.md](TEST_ACCOUNT_SETUP.md).

---

## How Gemini 3 is used

Skrolz uses the **Gemini 3 API** (`gemini-3-flash-preview`) in **three Supabase Edge Functions**. Each is central to the product.

### 1. AI Post — `generate-post`

- **Purpose:** Generate up to three distinct post variants from a topic (and optional tone/length).
- **Flow:** The app sends `topic`, `tone`, and `target_length` to the Edge Function; the function calls Gemini 3 and returns an array of strings. Each post is then validated (e.g. 280-character limit) and can be passed to the moderation function before the user publishes.
- **Gemini settings:** `thinkingLevel: "low"` and `temperature: 1.0` for fast, creative output. System instructions define the role (content creator), goal, constraints (max 280 chars, no labels), and output format (one post per line).
- **Implementation:** [supabase/functions/generate-post/index.ts](supabase/functions/generate-post/index.ts)

### 2. Study Buddy — `study-buddy`

- **Purpose:** For a given topic (or content id), return two study tips, one actionable step, and one multiple-choice question with three options and the correct index.
- **Flow:** The app sends `topic` (or `content_id`); the function calls Gemini 3 with a structured prompt and parses the response as JSON. Fallbacks (strip markdown, regex, schema checks) ensure the app always gets a valid object.
- **Gemini settings:** `thinkingLevel: "high"` and `responseMimeType: "application/json"` for reliable, well-reasoned answers and consistent JSON. The prompt specifies the exact JSON shape: `tips`, `action`, `question`, `options`, `correct_index`.
- **Implementation:** [supabase/functions/study-buddy/index.ts](supabase/functions/study-buddy/index.ts)

### 3. Content moderation — `moderate-content`

- **Purpose:** Evaluate post and lesson text for safety (e.g. harassment, hate speech, spam) before content goes live. Used for both user-created and AI-generated content.
- **Flow:** The app (or other functions) send `text` and optional `content_type` / `content_id`. The function uses **cached contents** for the system instructions when possible to reduce tokens and latency. Gemini returns a safety verdict; the function returns allow/reject (and optional quarantine) to the client.
- **Gemini settings:** `gemini-3-flash-preview` with explicit **cached contents** for the moderation system prompt (TTL e.g. 1 hour). Retries with exponential backoff on rate limits. A rule-based fallback runs when the API is unavailable.
- **Implementation:** [supabase/functions/moderate-content/index.ts](supabase/functions/moderate-content/index.ts)

### Summary

| Function | Model | Thinking level | Main use |
|----------|--------|----------------|----------|
| **generate-post** | `gemini-3-flash-preview` | low | Creative post variants, 280-char validation |
| **study-buddy** | `gemini-3-flash-preview` | high | Structured JSON: tips, action, quiz |
| **moderate-content** | `gemini-3-flash-preview` | — | Safety check with cached system instructions |

Feed ranking, recommendations, and “why you saw this” use **Supabase (PostgreSQL and materialized views)** only; no Gemini there.

---

## Features

- **Auth:** Email OTP and Google Sign-In (Supabase Auth).
- **Feed:** For You feed, one full-screen card at a time; bookmarks; offline-capable cache (Drift).
- **Creation:** Write a post or a multi-slide lesson; **AI Post** (Gemini 3) for three post variants; **Study Buddy** (Gemini 3, premium) for tips, action, and quiz.
- **Safety:** All posts and lessons moderated by **moderate-content** (Gemini 3) before going live.
- **Localization:** English and Arabic (easy_localization, RTL).
- **Platforms:** Android, iOS, Web (PWA), macOS, Windows, Linux (Flutter).

---

## Tech stack

- **App:** Flutter (Dart), Riverpod, go_router, Supabase Flutter, easy_localization, Drift (local DB), google_fonts, cached_network_image, lottie, share_plus, image_picker.
- **Backend:** Supabase (PostgreSQL, Edge Functions on Deno), Gemini 3 API (`gemini-3-flash-preview`). Optional: RevenueCat for premium (Study Buddy).
- **Infra:** Supabase Auth, Realtime, Storage; materialized views and RLS for feed and security.

---

## Run locally

```bash
git clone https://github.com/AmirmLotfy/skrolz.git && cd skrolz
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

To use the **test account** and premium features, create the user and grant premium in your Supabase project: [TEST_ACCOUNT_SETUP.md](TEST_ACCOUNT_SETUP.md).

---

## Project layout

| Path | Contents |
|------|----------|
| `lib/` | Flutter app: screens, providers, theme, router, data layer |
| `supabase/functions/` | Edge Functions; **generate-post**, **study-buddy**, **moderate-content** use Gemini 3 |
| `supabase/migrations/` | PostgreSQL schema, RLS, triggers, materialized views |
| `assets/` | Images, l10n (en.json, ar.json), fonts, animations |
| `docs/` | [Setup and operations guides](docs/README.md) (Supabase, Android, OneSignal, etc.) |

---

## Hackathon

- **Event:** [Gemini 3 Hackathon — Build what's next](https://gemini3.devpost.com)
- **Submission copy:** [DEVPOST_SUBMISSION.md](DEVPOST_SUBMISSION.md) (pitch, story, built-with list for the form).

---

## License

MIT — see [LICENSE](LICENSE).
