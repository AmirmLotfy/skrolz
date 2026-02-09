import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/providers/auth_provider.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _loading = false;

  Future<void> _signOut() async {
    setState(() => _loading = true);
    await AppSupabase.auth.signOut();
    if (mounted) {
      context.go(AppPaths.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authUserProvider).value;

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
                        'Account',
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
                          Text(
                            'Email',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.textDarkSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user?.email ?? 'Unknown',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _loading ? null : _signOut,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                              foregroundColor: AppColors.warning,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.warning,
                                    ),
                                  )
                                : const Text('Sign Out'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                     GlassSurface(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.all(20),
                      blur: 25,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Delete Account',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Permanently delete your account and all data. This action cannot be undone.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                           const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF1E1E1E),
                                  title: const Text('Delete Account?', style: TextStyle(color: Colors.white)),
                                  content: const Text(
                                    'Are you sure you want to delete your account? This action is irreversible and will remove all your data.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        setState(() => _loading = true);
                                        try {
                                          await AppSupabase.client.rpc('delete_own_account');
                                          // Sign out handled automatically by session change, but explicit navigation helps
                                          if (mounted) context.go(AppPaths.auth);
                                        } catch (e) {
                                          if (mounted) {
                                            setState(() => _loading = false);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to delete account: $e')),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                                    ),
                                  ],
                                ),
                              );
                            },
                             style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(color: AppColors.danger),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Delete Account'),
                          ),
                        ],
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
