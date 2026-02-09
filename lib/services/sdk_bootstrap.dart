import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat API key (from env or build config). Empty = skip configure.
const String _revenueCatApiKey = String.fromEnvironment(
  'REVENUECAT_API_KEY',
  defaultValue: '',
);

/// OneSignal disabled for now. When re-enabling, set ONESIGNAL_APP_ID and add onesignal_flutter back.
bool get isOneSignalInitialized => false;

bool _revenueCatConfigured = false;

bool get isRevenueCatConfigured => _revenueCatConfigured;

/// Call from main after AppSupabase.init(). Configures RevenueCat when key is set;
/// syncs app_user_id when user signs in/out. OneSignal is disabled.
Future<void> initSdks() async {
  if (_revenueCatApiKey.isNotEmpty) {
    try {
      await Purchases.configure(PurchasesConfiguration(_revenueCatApiKey));
      _revenueCatConfigured = true;
      _syncRevenueCatUser();
      if (AppSupabase.isInitialized) {
        AppSupabase.auth.onAuthStateChange.listen((_) => _syncRevenueCatUser());
      }
    } catch (_) {
      // ignore
    }
  }
}

Future<void> _syncRevenueCatUser() async {
  if (!_revenueCatConfigured || !AppSupabase.isInitialized) return;
  final user = AppSupabase.auth.currentUser;
  try {
    if (user != null) {
      await Purchases.logIn(user.id);
    } else {
      await Purchases.logOut();
    }
  } catch (_) {}
}
