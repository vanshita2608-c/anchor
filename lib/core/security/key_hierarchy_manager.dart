import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'crypto_engine.dart';

/// Manages Master Password KDF, VEK wrapping/unwrapping, and secure storage.
class KeyHierarchyManager {
  static final KeyHierarchyManager _instance = KeyHierarchyManager._internal();
  factory KeyHierarchyManager() => _instance;
  KeyHierarchyManager._internal();

  final _secureStorage = const FlutterSecureStorage();
  SecretKey? _unwrappedVek;

  static const String _keySalt = 'anchor_kdf_salt';
  static const String _keyWrappedVek = 'anchor_wrapped_vek';
  static const String _keyVekNonce = 'anchor_vek_nonce';
  static const String _keyVekMac = 'anchor_vek_mac';
  static const String _keySavedPassword = 'anchor_saved_pwd';

  bool get isVaultUnlocked => _unwrappedVek != null;

  SecretKey? get activeVek => _unwrappedVek;

  /// Checks if a master password vault key has already been created on this device
  Future<bool> hasExistingVault() async {
    final salt = await _secureStorage.read(key: _keySalt);
    final wrappedVek = await _secureStorage.read(key: _keyWrappedVek);
    return salt != null && wrappedVek != null;
  }

  /// Saves password securely for biometric unlock
  Future<void> savePasswordForBiometrics(String password) async {
    await _secureStorage.write(key: _keySavedPassword, value: password);
  }

  /// Unlocks the vault using saved biometric credentials
  Future<bool> unlockWithSavedBiometrics() async {
    try {
      final savedPwd = await _secureStorage.read(key: _keySavedPassword);
      if (savedPwd != null && savedPwd.isNotEmpty) {
        return await unlockVault(savedPwd);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Initializes a new master password vault key hierarchy
  Future<String> setupNewVault(String masterPassword) async {
    final salt = CryptoEngine.generateSalt();
    final kek = await CryptoEngine.deriveKeyFromPassword(masterPassword, salt);
    final vek = await CryptoEngine.generateVaultEncryptionKey();

    final vekBytes = await vek.extractBytes();
    final vekString = base64Url.encode(vekBytes);

    final encryptedVek = await CryptoEngine.encryptString(
      plaintext: vekString,
      secretKey: kek,
    );

    await _secureStorage.write(key: _keySalt, value: salt);
    await _secureStorage.write(key: _keyWrappedVek, value: encryptedVek['ciphertext']);
    await _secureStorage.write(key: _keyVekNonce, value: encryptedVek['nonce']);
    await _secureStorage.write(key: _keyVekMac, value: encryptedVek['mac']);
    await savePasswordForBiometrics(masterPassword);

    _unwrappedVek = vek;

    // Generate 16-character Offline Recovery Key
    final recoveryCode = 'ANCHOR-${salt.substring(0, 4).toUpperCase()}-${salt.substring(4, 8).toUpperCase()}-${salt.substring(8, 12).toUpperCase()}';
    return recoveryCode;
  }

  /// Unlocks the vault using the Master Password
  Future<bool> unlockVault(String masterPassword) async {
    try {
      final salt = await _secureStorage.read(key: _keySalt);
      final wrappedVek = await _secureStorage.read(key: _keyWrappedVek);
      final nonce = await _secureStorage.read(key: _keyVekNonce);
      final mac = await _secureStorage.read(key: _keyVekMac);

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
      await savePasswordForBiometrics(masterPassword);
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
