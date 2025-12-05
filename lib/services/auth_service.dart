import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Service for handling authentication
class AuthService {
  static final SupabaseClient _supabase = SupabaseService.client;

  /// Sign in with GitHub using OAuth
  /// Returns true if the OAuth flow was initiated successfully
  Future<bool> signInWithGitHub() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: kIsWeb
            ? '${Uri.base.origin}/auth/callback}' // ← web: let Supabase pick the right URL
            : _getRedirectUrl(), // ← mobile: your deep link
      );
      return true;
    } catch (e) {
      throw Exception('Failed to initiate GitHub login: $e');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Get the current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get user's display name
  String? get userDisplayName {
    final user = currentUser;
    if (user == null) return null;
    return user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String? ??
        user.email ??
        user.userMetadata?['preferred_username'] as String?;
  }

  /// Get user's avatar URL
  String? get userAvatarUrl {
    final user = currentUser;
    if (user == null) return null;
    return user.userMetadata?['avatar_url'] as String?;
  }

  /// Get user's email
  String? get userEmail => currentUser?.email;

  /// Get redirect URL for OAuth callback
  /// This should match the redirect URL configured in Supabase dashboard
  String _getRedirectUrl() {
    // For mobile apps, use the deep link scheme
    // Make sure this matches the URL scheme configured in:
    // 1. Supabase Dashboard > Authentication > URL Configuration
    // 2. Android: AndroidManifest.xml (already configured)
    // 3. iOS: Info.plist (already configured)
    //
    // IMPORTANT: Add this exact URL to your Supabase Dashboard:
    // Authentication > URL Configuration > Redirect URLs
    return 'io.supabase.gitscribe://callback';
  }

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
