# Skrolz

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Short reads, one story at a time.**  
A vertical, full-screen content app (TikTok-style) powered by **Google Gemini 3**.

Built for the [Gemini 3 Hackathon](https://gemini3.devpost.com) (Feb 2026).

---

## Try the app

| | |
|---|---|
| **Android APK** | [Download app-release.apk](https://drive.google.com/file/d/1pYCpM-KuAW7JsGY00C8QHmm7SqtZcXmT/view?usp=sharing) — install and sign in with the test account below. |
| **Source code** | [github.com/AmirmLotfy/skrolz](https://github.com/AmirmLotfy/skrolz) |

### Test account (judges & QA)

| Field | Value |
|-------|--------|
| **Name** | Gemini Team |
| **Email** | `gemini@skrolz.app` |
| **Password** | `Gemini@Skrolz26` |

This account has **premium** access. Backend setup: [TEST_ACCOUNT_SETUP.md](TEST_ACCOUNT_SETUP.md).

---

## Gemini 3 integration

Skrolz uses the **Gemini 3 API** (`gemini-3-flash-preview`) in three Supabase Edge Functions:

1. **generate-post** — Topic (and optional tone/length) → three post variants. `thinkingLevel: "low"`, 280-char validation.
2. **study-buddy** — Topic → two tips, one action, one quiz (JSON). `thinkingLevel: "high"`, `responseMimeType: "application/json"`.
3. **moderate-content** — All posts and lessons checked for safety; cached system instructions, retries with backoff.

The Flutter app calls these via the Supabase client; feed ranking uses PostgreSQL and materialized views.

---

## Tech stack

- **App:** Flutter (Dart), Riverpod, go_router, Supabase Flutter, easy_localization (EN/AR), Drift (local cache)
- **Backend:** Supabase (PostgreSQL, Edge Functions on Deno), Gemini 3 API
- **Features:** Email OTP + Google auth, For You feed, bookmarks, AI Post, Study Buddy, content moderation, bilingual UI

---

## Run locally

```bash
git clone https://github.com/AmirmLotfy/skrolz.git && cd skrolz
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Optional: [Create the test user and grant premium](TEST_ACCOUNT_SETUP.md) in your Supabase project.

---

## Project layout

| Path | Contents |
|------|----------|
| `lib/` | Flutter app (screens, providers, theme, router) |
| `supabase/functions/` | Edge Functions (`generate-post`, `study-buddy`, `moderate-content` use Gemini 3) |
| `supabase/migrations/` | PostgreSQL schema and migrations |
| `docs/` | [Setup and operations guides](docs/README.md) |

---

## Hackathon

- **Event:** [Gemini 3 Hackathon — Build what's next](https://gemini3.devpost.com)
- **Submission copy:** [DEVPOST_SUBMISSION.md](DEVPOST_SUBMISSION.md) (pitch, story, built-with)

---

## License

MIT — see [LICENSE](LICENSE).
