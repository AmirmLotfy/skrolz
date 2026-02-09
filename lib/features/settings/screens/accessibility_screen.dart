import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/profile_repository.dart';
import 'package:skrolz_app/providers/auth_provider.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Accessibility: dynamic type, reduce motion, RTL, numerals. Persists to profiles.preferences.
class AccessibilityScreen extends ConsumerStatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  ConsumerState<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends ConsumerState<AccessibilityScreen> {
  bool _reduceMotion = false;
  bool _preferRtl = false;
  String _numerals = 'western';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = ref.read(authUserProvider).value;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    final profile = await ProfileRepository.getProfile(user.id);
    final prefs = profile?['preferences'];
    final acc = prefs is Map ? prefs['accessibility'] : null;
    if (acc is Map) {
      setState(() {
        _reduceMotion = acc['reduce_motion'] == true;
        _preferRtl = acc['prefer_rtl'] == true;
        _numerals = acc['numerals'] is String ? acc['numerals'] as String : 'western';
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _save(Map<String, dynamic> accessibility) async {
    final user = ref.read(authUserProvider).value;
    if (user == null) return;
    setState(() => _saving = true);
    await ProfileRepository.updatePreferences(user.id, {'accessibility': accessibility});
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.darkGradient,
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GlassSurface(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(8),
                      blur: 20,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'profile.accessibility'.tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    GlassSurface(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.all(20),
                      blur: 25,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ContentCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reduce motion',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Minimize animations',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _reduceMotion,
                                  onChanged: (v) {
                                    setState(() => _reduceMotion = v);
                                    _save({'reduce_motion': v, 'prefer_rtl': _preferRtl, 'numerals': _numerals});
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ContentCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Prefer RTL',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Right-to-left layout',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _preferRtl,
                                  onChanged: (v) {
                                    setState(() => _preferRtl = v);
                                    _save({'reduce_motion': _reduceMotion, 'prefer_rtl': v, 'numerals': _numerals});
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ContentCard(
                            onTap: () {
                              final next = _numerals == 'western' ? 'arabic' : 'western';
                              setState(() => _numerals = next);
                              _save({'reduce_motion': _reduceMotion, 'prefer_rtl': _preferRtl, 'numerals': next});
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Numerals',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _numerals == 'arabic' ? 'Arabic (٠١٢)' : 'Western (012)',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white70),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_saving) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
