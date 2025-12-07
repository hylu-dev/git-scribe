import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for accessing environment variables and configuration
class Env {
  /// Check if compile-time environment variables are available
  static bool get _hasCompileTimeVars {
    final compileTimeUrl = const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    final compileTimeKey = const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );
    return compileTimeUrl.isNotEmpty && compileTimeKey.isNotEmpty;
  }

  /// Get Supabase project URL from environment variables
  static String get supabaseUrl {
    // Try compile-time environment variable first
    final compileTimeUrl = const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    if (compileTimeUrl.isNotEmpty) {
      return compileTimeUrl;
    }

    // Fall back to dotenv (only if not using compile-time vars)
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception(
        'SUPABASE_URL is not set. '
        'Please set it via --dart-define=SUPABASE_URL=... or in .env file. '
        'Please copy .env.example to .env and fill in your values.',
      );
    }
    return url;
  }

  /// Get Supabase anonymous key from environment variables
  static String get supabaseAnonKey {
    // Try compile-time environment variable first
    final compileTimeKey = const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );
    if (compileTimeKey.isNotEmpty) {
      return compileTimeKey;
    }

    // Fall back to dotenv (only if not using compile-time vars)
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY is not set. '
        'Please set it via --dart-define=SUPABASE_ANON_KEY=... or in .env file. '
        'Please copy .env.example to .env and fill in your values.',
      );
    }
    return key;
  }

  /// Check if environment variables are loaded
  static bool get isConfigured {
    // Check compile-time variables first
    if (_hasCompileTimeVars) {
      return true;
    }

    // Fall back to checking dotenv
    return dotenv.env['SUPABASE_URL'] != null &&
        dotenv.env['SUPABASE_ANON_KEY'] != null;
  }

  /// Check if dotenv needs to be loaded
  /// Returns true if compile-time variables are not available
  static bool get needsDotenv {
    return !_hasCompileTimeVars;
  }
}
