/// Service for accessing environment variables and configuration
class Env {
  /// Get Supabase project URL from environment variables
  static String get supabaseUrl {
    const url = String.fromEnvironment('SUPABASE_URL');
    if (url.isEmpty) {
      throw Exception(
        'SUPABASE_URL is not set. '
        'Please set it via --dart-define=SUPABASE_URL=... or '
        '--dart-define-from-file=.env',
      );
    }
    return url;
  }

  /// Get Supabase anonymous key from environment variables
  static String get supabaseAnonKey {
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (key.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY is not set. '
        'Please set it via --dart-define=SUPABASE_ANON_KEY=... or '
        '--dart-define-from-file=.env',
      );
    }
    return key;
  }

  /// Get Gemini API key from environment variables
  static String get geminiApiKey {
    const key = String.fromEnvironment('GEMINI_API_KEY');
    if (key.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY is not set. '
        'Please set it via --dart-define=GEMINI_API_KEY=... or '
        '--dart-define-from-file=.env',
      );
    }
    return key;
  }

  /// Check if Gemini API key is configured
  static bool get hasGeminiApiKey {
    return const String.fromEnvironment('GEMINI_API_KEY').isNotEmpty;
  }

  /// Check if environment variables are loaded
  static bool get isConfigured {
    return const String.fromEnvironment('SUPABASE_URL').isNotEmpty &&
        const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty;
  }
}
