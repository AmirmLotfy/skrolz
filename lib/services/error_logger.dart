import 'package:skrolz_app/data/supabase/supabase_client.dart';

/// Error logging service for tracking errors and crashes.
class ErrorLogger {
  /// Log an error with optional stack trace and context.
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
    String? tag,
  }) async {
    try {
      // Log to console in debug mode
      print('[$tag] Error: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
      if (context != null) {
        print('Context: $context');
      }

      // In production, log to Supabase or external service
      if (AppSupabase.isInitialized) {
        try {
          // Create error_logs table if it doesn't exist, or use existing logging mechanism
          // For now, we'll just print. In production, implement proper logging.
          // await AppSupabase.client.from('error_logs').insert({
          //   'error_message': error.toString(),
          //   'stack_trace': stackTrace?.toString(),
          //   'context': context,
          //   'tag': tag,
          //   'created_at': DateTime.now().toUtc().toIso8601String(),
          // });
        } catch (_) {
          // Fail silently if logging fails
        }
      }
    } catch (_) {
      // Fail silently
    }
  }

  /// Log a warning.
  static Future<void> logWarning(String message, {Map<String, dynamic>? context}) async {
    await logError(message, null, context: context, tag: 'WARNING');
  }

  /// Log an info message.
  static void logInfo(String message, {Map<String, dynamic>? context}) {
    print('[INFO] $message');
    if (context != null) {
      print('Context: $context');
    }
  }
}
