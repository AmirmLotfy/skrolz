import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/services/sdk_bootstrap.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Paywall Preview: gradient hero, feature cards with glass effect, modern pricing.
class PaywallPreviewScreen extends StatefulWidget {
  const PaywallPreviewScreen({super.key});

  @override
  State<PaywallPreviewScreen> createState() => _PaywallPreviewScreenState();
}

class _PaywallPreviewScreenState extends State<PaywallPreviewScreen> {
  Offerings? _offerings;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (isRevenueCatConfigured) {
      Purchases.getOfferings().then((o) {
        if (mounted) setState(() => _offerings = o);
      });
    }
  }

  Future<void> _purchase(Package package) async {
    // Subscriptions disabled - skip to permissions
    if (mounted) context.go(AppPaths.permissions);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.premiumGradient,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.star, size: 64, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'onboarding.paywall_preview'.tr(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock exclusive features',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textDarkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    ActionCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Curated feed',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'AI-ranked stories with "Why you saw this"',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ActionCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.psychology, color: Colors.white),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Study Buddy',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '2 tips + 1 action + 1 micro-quiz',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ActionCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.school, color: Colors.white),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create lessons',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Multi-slide lessons + quizzes',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ActionCard(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        children: [
                          Icon(Icons.download, color: Colors.white),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Offline packs',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Download collections to read offline',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_error != null)
                      ContentCard(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _error!,
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                    if (_offerings?.current != null) ...[
                      ...(_offerings!.current!.availablePackages.map((p) {
                        return ContentCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          onTap: _loading ? null : () => _purchase(p),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.storeProduct.title,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.storeProduct.priceString,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 18),
                            ],
                          ),
                        );
                      })),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
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
                        onPressed: _loading
                            ? null
                            : () {
                                final cur = _offerings?.current;
                                final pkg = cur?.annual ??
                                    cur?.monthly ??
                                    (cur?.availablePackages.isNotEmpty == true
                                        ? cur!.availablePackages.first
                                        : null);
                                if (pkg != null && isRevenueCatConfigured) {
                                  _purchase(pkg);
                                } else {
                                  context.go(AppPaths.permissions);
                                }
                              },
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Start free trial',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loading ? null : () => context.go(AppPaths.permissions),
                      child: Text(
                        'Maybe later',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textDarkSecondary,
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
