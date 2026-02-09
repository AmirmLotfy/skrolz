import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skrolz_app/data/supabase/supabase_client.dart';

/// Current auth user (null if signed out).
final authUserProvider = StreamProvider<User?>((ref) {
  if (!AppSupabase.isInitialized) return Stream.value(null);
  return AppSupabase.auth.onAuthStateChange.map((e) => e.session?.user);
});

/// Whether user is signed in.
final isSignedInProvider = Provider<bool>((ref) {
  final async = ref.watch(authUserProvider);
  return async.value != null;
});
