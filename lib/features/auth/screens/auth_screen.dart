import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/profile_repository.dart';
import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/glass_surface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

const _kOnboardingCompletedKey = 'skrolz_onboarding_completed';

/// Auth: modern glassmorphism inputs, rounded buttons with gradients.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _sentOtp = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email');
      return;
    }
    if (!AppSupabase.isInitialized) {
      setState(() => _error = 'App not connected. Use real Supabase URL.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AppSupabase.auth.signInWithOtp(email: email);
      setState(() {
        _sentOtp = true;
        _loading = false;
        _error = null;
      });
    } on supabase.AuthException catch (e) {
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final token = _otpController.text.trim();
    if (token.isEmpty) {
      setState(() => _error = 'Enter the code from your email');
      return;
    }
    if (!AppSupabase.isInitialized) {
      setState(() => _error = 'App not connected.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AppSupabase.auth.verifyOTP(
        type: supabase.OtpType.email,
        token: token,
        email: email,
      );
      // Ensure profile exists after signup
      final user = AppSupabase.auth.currentUser;
      if (user != null) {
        await ProfileRepository.ensureProfileExists(user.id);
      }
      final prefs = await SharedPreferences.getInstance();
      final returningUser = prefs.getBool(_kOnboardingCompletedKey) ?? false;
      if (!mounted) return;
      setState(() => _loading = false);
      if (returningUser) {
        context.go(AppPaths.home);
      } else {
        context.go(AppPaths.interests);
      }
    } on supabase.AuthException catch (e) {
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    if (AppSupabase.isPlaceholder) {
      setState(() => _error = 'Sign-in requires a configured backend. Build the app with SUPABASE_URL and SUPABASE_ANON_KEY.');
      return;
    }
    if (!AppSupabase.isInitialized) {
      setState(() => _error = 'App not connected.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AppSupabase.auth.signInWithOAuth(
        supabase.OAuthProvider.google,
        redirectTo: 'skrolzapp://login-callback',
      );
    } on supabase.AuthException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGradient : AppColors.lightGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'auth.welcome'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _sentOtp ? 'auth.enter_code_sent'.tr() : 'auth.sign_in_to_continue'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ),
                if (AppSupabase.isPlaceholder) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Backend not configured. Use email or build with SUPABASE_URL.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Expanded(
                  child: _sentOtp ? _buildOtpForm() : _buildEmailForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassSurface(
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          blur: 25,
          child: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.start,
              style: theme.textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              labelText: 'auth.email'.tr(),
              border: InputBorder.none,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textDarkSecondary,
              ),
              alignLabelWithHint: true,
            ),
              enabled: !_loading,
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          GlassSurface(
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(12),
            blur: 20,
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FilledButton(
            onPressed: _loading ? null : _sendOtp,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'auth.send_otp'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black26)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'auth.or_continue_with'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : AppColors.textLightSecondary,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black26)),
              ],
            ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: (_loading || AppSupabase.isPlaceholder) ? null : _signInWithGoogle,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _GoogleLogoIcon(size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Google',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildOtpForm() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassSurface(
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          blur: 25,
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              labelText: 'auth.enter_otp'.tr(),
              border: InputBorder.none,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textDarkSecondary,
              ),
            ),
            enabled: !_loading,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          GlassSurface(
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(12),
            blur: 20,
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FilledButton(
            onPressed: _loading ? null : _verifyOtp,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'auth.verify'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Official-style Google "G" for Sign in with Google. Uses asset if present, else Material G icon.
class _GoogleLogoIcon extends StatelessWidget {
  const _GoogleLogoIcon({this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/google_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.g_mobiledata_rounded,
          size: size,
          color: Colors.black87,
        ),
      ),
    );
  }
}
