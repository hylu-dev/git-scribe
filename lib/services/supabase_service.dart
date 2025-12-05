import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for accessing Supabase client
class SupabaseService {
  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Get the current user session
  static User? get currentUser => client.auth.currentUser;
  
  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}

