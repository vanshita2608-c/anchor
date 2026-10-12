import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App configuration loaded from the `.env` file at startup (see main.dart).
/// Copy `.env.example` to `.env` and fill in the values.
class AppConfig {
  AppConfig._();

  static String? _getOptional(String key) {
    if (!dotenv.isInitialized) return null;
    return dotenv.maybeGet(key)?.trim();
  }

  static String _require(String key) {
    if (!dotenv.isInitialized) {
      throw StateError('Missing $key in .env. Copy .env.example to .env and fill it in.');
    }
    final value = dotenv.maybeGet(key)?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('Missing $key in .env. Copy .env.example to .env and fill it in.');
    }
    return value;
  }

  static String get supabaseUrl => _require('SUPABASE_URL');
  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  static const String appName = 'Anchor';
  static const String appTagline = 'Your Family. Secured.';

  // Google OAuth Credentials (optional; Google Sign-In falls back to platform config when empty)
  static String get googleServerClientId {
    final val = _getOptional('GOOGLE_SERVER_CLIENT_ID');
    return (val != null && val.isNotEmpty)
        ? val
        : '6673167196-gkd8vppi7cg4npvnlf4d5137ld1ttde6.apps.googleusercontent.com';
  }

  static String get googleIosClientId {
    final val = _getOptional('GOOGLE_IOS_CLIENT_ID');
    return (val != null && val.isNotEmpty)
        ? val
        : '6673167196-c7cq5go0mir0gumhg2v2api24ai900j1.apps.googleusercontent.com';
  }

  // Gemini AI / OCR API Key
  static String get geminiApiKey {
    final val = _getOptional('GEMINI_API_KEY');
    return (val != null && val.isNotEmpty)
        ? val
        : const String.fromEnvironment('GEMINI_API_KEY');
  }
}
