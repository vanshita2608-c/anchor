import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/current_user.dart';
import 'crypto_engine.dart';

/// Manages Master Password KDF, VEK wrapping/unwrapping, and secure storage.
/// All stored keys are scoped to the signed-in user, so multiple accounts on
/// one device never see (or unlock) each other's vault.
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

  /// Checks if the signed-in user has already created a vault on this device
  Future<bool> hasExistingVault() async {
    await _purgeLegacyKeys();
    if (CurrentUser.id == null) return false;
    final salt = await _secureStorage.read(key: _scoped(_keySalt));
    final wrappedVek = await _secureStorage.read(key: _scoped(_keyWrappedVek));
    return salt != null && wrappedVek != null;
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

  /// Initializes a new master password vault key hierarchy
  Future<String> setupNewVault(String masterPassword) async {
    await _purgeLegacyKeys();
    final salt = CryptoEngine.generateSalt();
    final kek = await CryptoEngine.deriveKeyFromPassword(masterPassword, salt);
    final vek = await CryptoEngine.generateVaultEncryptionKey();

    final vekBytes = await vek.extractBytes();
    final vekString = base64Url.encode(vekBytes);

    final encryptedVek = await CryptoEngine.encryptString(
      plaintext: vekString,
      secretKey: kek,
    );

    await _secureStorage.write(key: _scoped(_keySalt), value: salt);
    await _secureStorage.write(key: _scoped(_keyWrappedVek), value: encryptedVek['ciphertext']);
    await _secureStorage.write(key: _scoped(_keyVekNonce), value: encryptedVek['nonce']);
    await _secureStorage.write(key: _scoped(_keyVekMac), value: encryptedVek['mac']);

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
