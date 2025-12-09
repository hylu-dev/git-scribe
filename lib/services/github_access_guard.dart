import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../widgets/common/toast.dart';
import 'supabase_service.dart';

/// Centralized helper to ensure GitHub access is available.
/// If no provider token is present, optionally shows a message and
/// redirects to the login screen.
class GitHubAccessGuard {
  static bool _hasToken() =>
      SupabaseService.client.auth.currentSession?.providerToken != null;

  /// Returns true when a provider token is present; otherwise redirects to login.
  static bool ensureAccess(
    BuildContext context, {
    bool mounted = true,
    bool showMessage = true,
    String? message,
  }) {
    if (_hasToken()) return true;

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
