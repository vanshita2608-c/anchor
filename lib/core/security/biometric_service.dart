import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyBiometricsEnabled = 'anchor_biometrics_enabled';
  static const String _keyAutoLockEnabled = 'anchor_autolock_enabled';

  Future<bool> isBiometricsAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics && isDeviceSupported;
    } catch (e) {
      debugPrint('Biometrics check notice: $e');
      return false;
    }
  }

  Future<bool> isBiometricsEnabled() async {
    final val = await _storage.read(key: _keyBiometricsEnabled);
    return val == null || val == 'true';
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometricsEnabled, value: enabled ? 'true' : 'false');
  }

  Future<bool> isAutoLockEnabled() async {
    final val = await _storage.read(key: _keyAutoLockEnabled);
    return val == null || val == 'true';
  }

  Future<void> setAutoLockEnabled(bool enabled) async {
    await _storage.write(key: _keyAutoLockEnabled, value: enabled ? 'true' : 'false');
  }

  Future<bool> authenticateWithBiometrics({required String reason}) async {
    return authenticate(localizedReason: reason);
  }

  Future<bool> authenticate({required String localizedReason}) async {
    try {
      final available = await isBiometricsAvailable();
      if (!available) return false;

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      debugPrint('Biometrics authentication notice: $e');
      return false;
    }
  }
}
