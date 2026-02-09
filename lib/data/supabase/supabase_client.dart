import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase client singleton. Call [init] from main before runApp.
class AppSupabase {
  AppSupabase._();

  static bool _initialized = false;
  static String? _url;

  static bool get isInitialized => _initialized;

  /// True when app was built with placeholder Supabase URL (auth/API will not work).
  static bool get isPlaceholder =>
      _url == null || _url!.contains('placeholder');

  static Future<void> init() async {
    if (_initialized) return;
    _url = const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://placeholder.supabase.co',
    );
    final anonKey = const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'placeholder-anon-key',
    );
    try {
      await supabase.Supabase.initialize(
        url: _url!,
        anonKey: anonKey,
      );
      _initialized = true;
    } catch (_) {
      // App runs without backend when URL/key are placeholders or invalid
    }
  }

  static supabase.SupabaseClient get client => supabase.Supabase.instance.client;
  static supabase.GoTrueClient get auth => client.auth;
}
