import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App configuration loaded from the `.env` file at startup (see main.dart).
/// Copy `.env.example` to `.env` and fill in the values.
class AppConfig {
  AppConfig._();

  static String _require(String key) {
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
  static String get googleServerClientId => dotenv.maybeGet('GOOGLE_SERVER_CLIENT_ID')?.trim() ?? '';
  static String get googleIosClientId => dotenv.maybeGet('GOOGLE_IOS_CLIENT_ID')?.trim() ?? '';
}
