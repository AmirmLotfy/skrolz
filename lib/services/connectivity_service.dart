import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity service for detecting network status.
class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Stream of connectivity results.
  static Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;

  /// Check current connectivity status.
  static Future<List<ConnectivityResult>> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }

  /// Whether device is currently online.
  static Future<bool> get isOnline async {
    final results = await checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  static void dispose() {
    _subscription?.cancel();
  }
}

/// Provider for connectivity status.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return ConnectivityService.connectivityStream;
});

/// Provider for online/offline status.
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (results) => !results.contains(ConnectivityResult.none),
    loading: () => true, // Assume online while checking
    error: (_, __) => true, // Assume online on error
  );
});
