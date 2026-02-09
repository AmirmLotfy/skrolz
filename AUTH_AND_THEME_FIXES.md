# Auth & Theme Fixes Summary

## 1. Styling and dark/light mode
- **Auth screen**: Uses `theme.brightness` to switch between `AppColors.darkGradient` and `AppColors.lightGradient`; text and divider colors adapt.
- **Onboarding screen**: Same theme-aware background and text colors; skip button and dots respect light/dark.
- **Language & Reading Style screen**: Theme-aware background.
- **AppColors**: Added `lightGradient` for light mode.
- **Google button**: Background uses theme brightness (white in light, translucent in dark).

## 2. Google sign-in
- **Placeholder URL**: If the app is built without real `SUPABASE_URL`/`SUPABASE_ANON_KEY`, the auth screen shows a warning and disables Google sign-in. No more redirect to `placeholder.supabase.co`.
- **Supabase client**: Added `AppSupabase.isPlaceholder` (true when URL contains `placeholder`). Stored URL at init for this check.
- **Google icon**: Replaced globe icon with `_GoogleLogoIcon` that uses `assets/images/google_logo.png` when present, otherwise `Icons.g_mobiledata_rounded`.  
  **To use the official Google “G” logo**: Download the asset from [Google Identity Guidelines](https://developers.google.com/identity/branding-guidelines) and save as `assets/images/google_logo.png`.

## 3. Text alignment and Cairo font
- **Auth titles/subtitles**: All use `textAlign: TextAlign.center`.
- **Email field**: `textDirection: TextDirection.ltr` and `textAlign: TextAlign.start` so email is always LTR.
- **Cairo for Arabic**: Already applied in `AppTypography.forLocale(locale)` (Cairo for `ar`, Plus Jakarta Sans for `en`). Theme is built with locale in `AppTheme.light(locale)` / `AppTheme.dark(locale)`.
- **Localization**: Added `common.skip`, `auth.welcome`, `auth.sign_in_to_continue`, `auth.enter_code_sent`, `auth.or_continue_with`, `onboarding.language_subtitle` in EN and AR so no raw keys appear.

## 4. Auth flow and scenarios
- **Placeholder backend**: Clear message and Google button disabled when `AppSupabase.isPlaceholder` is true.
- **Email OTP**: Unchanged; still requires a real Supabase project.
- **Google OAuth**: Redirect `skrolzapp://login-callback`; Android intent-filter already set. Supabase SDK handles the deep link and session.
- **Build for production**: Use:
  ```bash
  flutter build apk --release \
    --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
    --dart-define=SUPABASE_ANON_KEY=your-anon-key
  ```
  Then configure the same redirect URL in Supabase Dashboard → Authentication → URL Configuration.

## Files changed
- `lib/data/supabase/supabase_client.dart` – Placeholder detection and URL storage.
- `lib/features/auth/screens/auth_screen.dart` – Theme-aware UI, placeholder handling, Google icon widget, localized strings, center alignment.
- `lib/features/onboarding/screens/onboarding_screen.dart` – Theme-aware background and skip/dots; `common.skip` used (key added to l10n).
- `lib/features/onboarding/screens/language_style_screen.dart` – Theme-aware background, `onboarding.language_subtitle`.tr().
- `lib/theme/app_colors.dart` – `lightGradient` added.
- `assets/l10n/en.json`, `assets/l10n/ar.json` – New keys: `common.skip`, auth.*, `onboarding.language_subtitle`.
