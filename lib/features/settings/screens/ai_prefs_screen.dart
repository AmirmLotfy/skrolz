import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/profile_repository.dart';
import 'package:skrolz_app/providers/auth_provider.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// AI preferences: persist to profiles.preferences.
class AiPrefsScreen extends ConsumerStatefulWidget {
  const AiPrefsScreen({super.key});

  @override
  ConsumerState<AiPrefsScreen> createState() => _AiPrefsScreenState();
}

class _AiPrefsScreenState extends ConsumerState<AiPrefsScreen> {
  bool _personalizedTips = true;
  bool _loading = true;

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
    final ai = prefs is Map ? prefs['ai_prefs'] : null;
    if (ai is Map) {
      setState(() => _personalizedTips = ai['personalized_tips'] != false);
    }
    setState(() => _loading = false);
  }

  Future<void> _save(Map<String, dynamic> aiPrefs) async {
    final user = ref.read(authUserProvider).value;
    if (user == null) return;
    await ProfileRepository.updatePreferences(user.id, {'ai_prefs': aiPrefs});
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
                        'AI preferences',
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
                      child: ContentCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Personalized study tips',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Switch(
                              value: _personalizedTips,
                              onChanged: (v) {
                                setState(() => _personalizedTips = v);
                                _save({'personalized_tips': v});
                              },
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
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
