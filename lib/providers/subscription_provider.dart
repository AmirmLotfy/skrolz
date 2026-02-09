import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skrolz_app/data/supabase/profile_repository.dart';
import 'package:skrolz_app/providers/auth_provider.dart';
import 'package:skrolz_app/services/sdk_bootstrap.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Subscription status: free | premium | trialing | cancelled.
/// RevenueCat webhook updates Supabase profiles.subscription_status;
/// client reads from Supabase profile when signed in; optionally from RevenueCat entitlement when configured.
final subscriptionStatusProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(authUserProvider).value;
  if (user == null) return 'free';
  if (isRevenueCatConfigured) {
    try {
      final info = await Purchases.getCustomerInfo();
      final premium = info.entitlements.all['premium'];
      if (premium != null && premium.isActive) return 'premium';
    } catch (_) {}
  }
  final profile = await ProfileRepository.getProfile(user.id);
  final status = profile?['subscription_status'];
  if (status is String) return status;
  return 'free';
});

/// Whether the user has access to premium features (curated feed, study buddy, lesson creation, offline packs).
/// All features are now free - always returns true.
final isPremiumProvider = Provider<bool>((ref) {
  // All features are free - subscriptions disabled
  return true;
});
