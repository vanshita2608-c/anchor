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

  bool get isVaultUnlocked => _unwrappedVek != null;

  SecretKey? get activeVek => _unwrappedVek;

  /// Initializes a new master password vault key hierarchy
  Future<void> setupNewVault(String masterPassword) async {
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

    _unwrappedVek = vek;
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
