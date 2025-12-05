import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for accessing environment variables and configuration
class Env {
  /// Get Supabase project URL from environment variables
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception(
        'SUPABASE_URL is not set in .env file. '
        'Please copy .env.example to .env and fill in your values.',
      );
    }
    return url;
  }

  /// Get Supabase anonymous key from environment variables
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY is not set in .env file. '
        'Please copy .env.example to .env and fill in your values.',
      );
    }
    return key;
  }

  /// Check if environment variables are loaded
  static bool get isConfigured {
    return dotenv.env['SUPABASE_URL'] != null &&
        dotenv.env['SUPABASE_ANON_KEY'] != null;
  }
}
