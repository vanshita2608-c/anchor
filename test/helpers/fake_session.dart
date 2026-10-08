import 'dart:convert';
import 'package:anchor/core/config/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fake_supabase_server.dart';

class FakeUser {
  final String id;
  final String email;
  final String fullName;
  final Map<String, dynamic> extraMetadata;

  const FakeUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.extraMetadata = const {},
  });
}

const atharva = FakeUser(
  id: '11111111-1111-1111-1111-111111111111',
  email: 'atharva@example.com',
  fullName: 'Atharva Shewale',
  extraMetadata: {'username': 'atharva_s', 'mobile': '+91 90000 11111'},
);

const otherUser = FakeUser(
  id: '22222222-2222-2222-2222-222222222222',
  email: 'vanshita@example.com',
  fullName: 'Vanshita Shah',
);

/// Builds a persisted-session JSON string for [user] whose JWT expires far in the future.
String sessionJsonFor(FakeUser user) {
  String b64(Map<String, dynamic> m) => base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  final exp = DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch ~/ 1000;
  final jwt = '${b64({'alg': 'HS256', 'typ': 'JWT'})}.${b64({'sub': user.id, 'exp': exp, 'role': 'authenticated'})}.sig';
  return jsonEncode({
    'access_token': jwt,
    'token_type': 'bearer',
    'expires_in': 3600 * 24 * 365,
    'expires_at': exp,
    'refresh_token': 'fake-refresh-token',
    'user': {
      'id': user.id,
      'aud': 'authenticated',
      'email': user.email,
      'app_metadata': {'provider': 'email'},
      'user_metadata': {'full_name': user.fullName, ...user.extraMetadata},
      'created_at': '2026-01-01T00:00:00Z',
    },
  });
}

class _FakeLocalStorage extends LocalStorage {
  String? _session;
  _FakeLocalStorage(this._session);

  @override
  Future<void> initialize() async {}
  @override
  Future<bool> hasAccessToken() async => _session != null;
  @override
  Future<String?> accessToken() async => _session;
  @override
  Future<void> persistSession(String persistSessionString) async => _session = persistSessionString;
  @override
  Future<void> removePersistedSession() async => _session = null;
}

class _FakeAsyncStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => _items[key];
  @override
  Future<void> setItem({required String key, required String value}) async => _items[key] = value;
  @override
  Future<void> removeItem({required String key}) async => _items.remove(key);
}

/// Initializes Supabase against an in-memory [FakeSupabaseServer] with [user]
/// already signed in, and an in-memory secure storage seeded with [secureStorage].
Future<FakeSupabaseServer> initSupabaseAs(FakeUser user, {Map<String, String> secureStorage = const {}}) async {
  dotenv.loadFromString(envString: 'SUPABASE_URL=https://test-project.supabase.co\nSUPABASE_ANON_KEY=test-anon-key');
  FlutterSecureStorage.setMockInitialValues(Map.of(secureStorage));
  final server = FakeSupabaseServer();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    httpClient: server.client,
    authOptions: FlutterAuthClientOptions(
      localStorage: _FakeLocalStorage(sessionJsonFor(user)),
      pkceAsyncStorage: _FakeAsyncStorage(),
      autoRefreshToken: false,
      detectSessionInUri: false,
    ),
  );
  return server;
}

/// Switches the signed-in user without any network call.
Future<void> switchUserTo(FakeUser user) =>
    Supabase.instance.client.auth.setInitialSession(sessionJsonFor(user));
