import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

/// Anchor Zero-Knowledge Cryptography Engine
/// Implements AES-256-GCM encryption/decryption, PBKDF2 key derivation,
/// and cryptographically secure random nonces.
class CryptoEngine {
  CryptoEngine._();

  static final _aesGcm = AesGcm.with256bits();
  static final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  );

  /// Generates a cryptographically secure random salt (32 bytes / 256 bits)
  static String generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// Generates a cryptographically secure 96-bit (12-byte) AES-GCM nonce
  static List<int> generateNonce() {
    final random = Random.secure();
    return List<int>.generate(12, (i) => random.nextInt(256));
  }

  /// Derives Key Encryption Key (KEK) from Master Password + Salt
  static Future<SecretKey> deriveKeyFromPassword(String masterPassword, String saltBase64) async {
    final saltBytes = base64Url.decode(saltBase64);
    final secretKey = await _pbkdf2.deriveKeyFromPassword(
      password: masterPassword,
      nonce: saltBytes,
    );
    return secretKey;
  }

  /// Generates a random 256-bit Vault Encryption Key (VEK)
  static Future<SecretKey> generateVaultEncryptionKey() async {
    return await _aesGcm.newSecretKey();
  }

  /// Encrypts plaintext string using AES-256-GCM
  static Future<Map<String, String>> encryptString({
    required String plaintext,
    required SecretKey secretKey,
  }) async {
    final nonce = generateNonce();
    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    return {
      'ciphertext': base64Url.encode(secretBox.cipherText),
      'nonce': base64Url.encode(secretBox.nonce),
      'mac': base64Url.encode(secretBox.mac.bytes),
    };
  }

  /// Decrypts ciphertext string using AES-256-GCM
  static Future<String> decryptString({
    required String ciphertextBase64,
    required String nonceBase64,
    required String macBase64,
    required SecretKey secretKey,
  }) async {
    final cipherText = base64Url.decode(ciphertextBase64);
    final nonce = base64Url.decode(nonceBase64);
    final macBytes = base64Url.decode(macBase64);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    final clearTextBytes = await _aesGcm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(clearTextBytes);
  }
}
