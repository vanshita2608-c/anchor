import 'package:anchor/core/security/key_hierarchy_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_session.dart';

const _password = 'atharva-master-123';

void main() {
  const storage = FlutterSecureStorage();
  final manager = KeyHierarchyManager();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Device already holds an old unscoped vault (with a plaintext password)
    // plus another account's scoped vault.
    await initSupabaseAs(atharva, secureStorage: {
      'anchor_kdf_salt': 'legacy-salt',
      'anchor_wrapped_vek': 'legacy-vek',
      'anchor_vek_nonce': 'legacy-nonce',
      'anchor_vek_mac': 'legacy-mac',
      'anchor_raw_vek': 'legacy-raw',
      'anchor_saved_pwd': 'vanshitas-plaintext-password',
      'anchor_kdf_salt_${otherUser.id}': 'other-salt',
      'anchor_wrapped_vek_${otherUser.id}': 'other-vek',
    });
  });

  // Tests run in order and share one device keychain.
  test('a new user does not see the old or another account\'s vault', () async {
    expect(await manager.hasExistingVault(), isFalse);
  });

  test('old unscoped keys, including the plaintext password, are wiped', () async {
    final all = await storage.readAll();
    expect(all.keys.where((k) => !k.contains('_${otherUser.id}')), isEmpty);
    expect(all.values, isNot(contains('vanshitas-plaintext-password')));
  });

  test('biometric unlock cannot bypass a vault that was never unlocked', () async {
    expect(await manager.unlockWithSavedBiometrics(), isFalse);
    expect(manager.isVaultUnlocked, isFalse);
  });

  test('creating a vault stores keys under this user only, never the password', () async {
    await manager.setupNewVault(_password);
    final all = await storage.readAll();

    expect(all.containsKey('anchor_kdf_salt_${atharva.id}'), isTrue);
    expect(all.containsKey('anchor_wrapped_vek_${atharva.id}'), isTrue);
    expect(all.containsKey('anchor_kdf_salt'), isFalse);
    expect(all.values, isNot(contains(_password)));
    expect(await manager.hasExistingVault(), isTrue);
  });

  test('wrong master password is rejected, correct one unlocks', () async {
    manager.lockVault();
    expect(await manager.unlockVault('wrong-password'), isFalse);
    expect(manager.isVaultUnlocked, isFalse);

    expect(await manager.unlockVault(_password), isTrue);
    expect(manager.isVaultUnlocked, isTrue);
  });

  test('biometric unlock works after a real password unlock', () async {
    manager.lockVault();
    expect(await manager.unlockWithSavedBiometrics(), isTrue);
  });

  test('switching accounts hides the previous user\'s vault', () async {
    await switchUserTo(otherUser);
    manager.lockVault();
    expect(await manager.unlockVault(_password), isFalse);

    await switchUserTo(atharva);
    expect(await manager.hasExistingVault(), isTrue);
  });
}
