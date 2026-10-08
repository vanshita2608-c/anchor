import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/current_user.dart';
import '../services/profile_service.dart';
import 'crypto_engine.dart';

/// Thrown when creating a vault for an account that already has one in Supabase.
class VaultAlreadyExistsException implements Exception {
  @override
  String toString() => 'A vault already exists for this account.';
}

/// Manages Master Password KDF, VEK wrapping/unwrapping, and secure storage.
/// All stored keys are scoped to the signed-in user, so multiple accounts on
/// one device never see (or unlock) each other's vault.
///
/// The salt and the password-wrapped VEK are also kept in Supabase
/// (`user_keys`, `wrapped_vault_keys`) so the vault can be unlocked on a new
/// device. Only wrapped key material leaves the device, never the password.
class KeyHierarchyManager {
  static final KeyHierarchyManager _instance = KeyHierarchyManager._internal();
  factory KeyHierarchyManager() => _instance;
  KeyHierarchyManager._internal();

  final _secureStorage = const FlutterSecureStorage();
  SecretKey? _unwrappedVek;
  bool _legacyPurged = false;

  static const String _keySalt = 'anchor_kdf_salt';
  static const String _keyWrappedVek = 'anchor_wrapped_vek';
  static const String _keyVekNonce = 'anchor_vek_nonce';
  static const String _keyVekMac = 'anchor_vek_mac';
  static const String _keyRawVek = 'anchor_raw_vek';
  static const int _keyVersion = 1;

  // Older builds stored these without a user scope (and the master password in plaintext).
  static const List<String> _legacyKeys = [
    _keySalt,
    _keyWrappedVek,
    _keyVekNonce,
    _keyVekMac,
    _keyRawVek,
    'anchor_saved_pwd',
  ];

  bool get isVaultUnlocked => _unwrappedVek != null;

  SecretKey? get activeVek => _unwrappedVek;

  /// Storage key for the signed-in user. Throws if nobody is signed in.
  String _scoped(String key) {
    final uid = CurrentUser.id;
    if (uid == null) {
      throw StateError('No signed-in user; vault keys are unavailable.');
    }
    return '${key}_$uid';
  }

  Future<void> _purgeLegacyKeys() async {
    if (_legacyPurged) return;
    for (final key in _legacyKeys) {
      await _secureStorage.delete(key: key);
    }
    _legacyPurged = true;
  }

  /// Checks if the signed-in user has a vault, on this device or in Supabase.
  /// A vault found only in Supabase is cached on the device.
  /// Throws if Supabase can't be reached and there is no local vault.
  Future<bool> hasExistingVault() async {
    await _purgeLegacyKeys();
    if (CurrentUser.id == null) return false;
    final salt = await _secureStorage.read(key: _scoped(_keySalt));
    final wrappedVek = await _secureStorage.read(key: _scoped(_keyWrappedVek));
    if (salt != null && wrappedVek != null) return true;

    final remote = await _fetchRemoteVault();
    if (remote == null) return false;
    await _writeLocal(remote);
    return true;
  }

  SupabaseClient get _db => Supabase.instance.client;

  Future<Map<String, String>?> _fetchRemoteVault() async {
    final uid = CurrentUser.id!;
    final keys = await _db.from('user_keys').select('kdf_salt').eq('user_id', uid).limit(1);
    final wrapped = await _db
        .from('wrapped_vault_keys')
        .select('wrapped_vek, vek_nonce, vek_mac')
        .eq('user_id', uid)
        .eq('key_version', _keyVersion)
        .limit(1);
    if (keys.isEmpty || wrapped.isEmpty || wrapped.first['vek_mac'] == null) return null;
    return {
      'salt': keys.first['kdf_salt'] as String,
      'ciphertext': wrapped.first['wrapped_vek'] as String,
      'nonce': wrapped.first['vek_nonce'] as String,
      'mac': wrapped.first['vek_mac'] as String,
    };
  }

  Future<void> _uploadVault(Map<String, String> vault) async {
    final uid = CurrentUser.id!;
    await ProfileService.ensureProfile();
    await _db.from('user_keys').upsert({
      'user_id': uid,
      'kdf_algorithm': 'PBKDF2-SHA256',
      'kdf_iterations': 100000,
      'kdf_salt': vault['salt'],
      'key_version': _keyVersion,
    }, onConflict: 'user_id');
    await _db.from('wrapped_vault_keys').upsert({
      'user_id': uid,
      'key_version': _keyVersion,
      'wrapped_vek': vault['ciphertext'],
      'vek_nonce': vault['nonce'],
      'vek_mac': vault['mac'],
    }, onConflict: 'user_id,key_version');
  }

  Future<void> _writeLocal(Map<String, String> vault) async {
    await _secureStorage.write(key: _scoped(_keySalt), value: vault['salt']);
    await _secureStorage.write(key: _scoped(_keyWrappedVek), value: vault['ciphertext']);
    await _secureStorage.write(key: _scoped(_keyVekNonce), value: vault['nonce']);
    await _secureStorage.write(key: _scoped(_keyVekMac), value: vault['mac']);
  }

  /// Vaults created before cloud sync existed only on the device; upload them once.
  Future<void> _uploadIfMissing(Map<String, String> vault) async {
    try {
      if (await _fetchRemoteVault() == null) await _uploadVault(vault);
    } catch (e) {
      debugPrint('Vault cloud sync notice: $e');
    }
  }

  /// Caches the unwrapped VEK in the device keychain so biometrics can unlock the vault
  Future<void> _saveVekForBiometrics() async {
    if (_unwrappedVek == null) return;
    final vekBytes = await _unwrappedVek!.extractBytes();
    await _secureStorage.write(key: _scoped(_keyRawVek), value: base64Url.encode(vekBytes));
  }

  /// Unlocks the vault using the VEK cached after the last successful password unlock
  Future<bool> unlockWithSavedBiometrics() async {
    try {
      final rawVekBase64 = await _secureStorage.read(key: _scoped(_keyRawVek));
      if (rawVekBase64 == null || rawVekBase64.isEmpty) return false;
      _unwrappedVek = SecretKey(base64Url.decode(rawVekBase64));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Initializes a new master password vault key hierarchy and saves it to Supabase.
  /// Refuses to overwrite an existing cloud vault, since that would make
  /// everything already saved unreadable.
  Future<String> setupNewVault(String masterPassword) async {
    await _purgeLegacyKeys();
    if (await _fetchRemoteVault() != null) throw VaultAlreadyExistsException();
    final salt = CryptoEngine.generateSalt();
    final kek = await CryptoEngine.deriveKeyFromPassword(masterPassword, salt);
    final vek = await CryptoEngine.generateVaultEncryptionKey();

    final vekBytes = await vek.extractBytes();
    final vekString = base64Url.encode(vekBytes);

    final encryptedVek = await CryptoEngine.encryptString(
      plaintext: vekString,
      secretKey: kek,
    );

    final vault = {
      'salt': salt,
      'ciphertext': encryptedVek['ciphertext']!,
      'nonce': encryptedVek['nonce']!,
      'mac': encryptedVek['mac']!,
    };
    await _uploadVault(vault);
    await _writeLocal(vault);

    _unwrappedVek = vek;
    await _saveVekForBiometrics();

    // Generate 16-character Offline Recovery Key
    final recoveryCode = 'ANCHOR-${salt.substring(0, 4).toUpperCase()}-${salt.substring(4, 8).toUpperCase()}-${salt.substring(8, 12).toUpperCase()}';
    return recoveryCode;
  }

  /// Unlocks the vault using the Master Password
  Future<bool> unlockVault(String masterPassword) async {
    try {
      final salt = await _secureStorage.read(key: _scoped(_keySalt));
      final wrappedVek = await _secureStorage.read(key: _scoped(_keyWrappedVek));
      final nonce = await _secureStorage.read(key: _scoped(_keyVekNonce));
      final mac = await _secureStorage.read(key: _scoped(_keyVekMac));

      if (salt == null || wrappedVek == null || nonce == null || mac == null) {
        return false;
      }

      final kek = await CryptoEngine.deriveKeyFromPassword(masterPassword, salt);
      final vekBase64 = await CryptoEngine.decryptString(
        ciphertextBase64: wrappedVek,
        nonceBase64: nonce,
        macBase64: mac,
        secretKey: kek,
      );

      final vekBytes = base64Url.decode(vekBase64);
      _unwrappedVek = SecretKey(vekBytes);
      await _saveVekForBiometrics();
      await _uploadIfMissing({'salt': salt, 'ciphertext': wrappedVek, 'nonce': nonce, 'mac': mac});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Locks the vault and clears sensitive unwrapped keys from memory
  void lockVault() {
    _unwrappedVek = null;
  }
}
