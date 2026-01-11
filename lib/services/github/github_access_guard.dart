import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/common/toast.dart';
import '../supabase_service.dart';

/// Centralized helper to ensure GitHub access is available.
/// If no provider token is present, optionally shows a message and
/// redirects to the login screen.
class GitHubAccessGuard {
  /// Check if we have a valid GitHub provider token
  /// First checks for a valid session, refreshing if needed
  static Future<bool> _hasToken() async {
    final client = SupabaseService.client;
    var session = client.auth.currentSession;

    // If we have a session, check if it's expired and try to refresh
    if (session != null) {
      // Check if session is expired (Supabase sessions typically expire after 1 hour)
      final expiresAt = session.expiresAt;
      if (expiresAt != null) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        // Refresh if session expires within the next 5 minutes
        if (expiresAt - now < 300) {
          try {
            // Try to refresh the session
            final response = await client.auth.refreshSession();
            session = response.session;
          } catch (e) {
            // Refresh failed, session might be invalid
            return false;
          }
        }
      }

      // Check if we have a provider token after refresh
      if (session?.providerToken != null) {
        return true;
      }
    }

    return false;
  }

  /// Returns true when a provider token is present; otherwise redirects to login.
  /// This method will attempt to refresh expired sessions before checking for the token.
  static Future<bool> ensureAccess(
    BuildContext context, {
    bool mounted = true,
    bool showMessage = false,
    String? message,
  }) async {
    if (await _hasToken()) return true;

    if (mounted) {
      if (showMessage) {
        Toast.error(context, message ?? 'Please sign in to GitHub.');
      }
      // Use post-frame callback to ensure navigation happens after current frame
      // Sign out first so router redirect will work properly
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        if (context.mounted) {
          // Sign out to clear authentication state so router redirect works
          await SupabaseService.client.auth.signOut();
          if (context.mounted) {
            context.go('/login');
          }
        }
      });
    }
    return false;
  }
}
