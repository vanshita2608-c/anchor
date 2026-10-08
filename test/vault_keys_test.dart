import 'package:anchor/core/security/key_hierarchy_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_session.dart';
import 'helpers/fake_supabase_server.dart';

const _password = 'atharva-master-123';

void main() {
  const storage = FlutterSecureStorage();
  final manager = KeyHierarchyManager();
  late FakeSupabaseServer server;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Device already holds an old unscoped vault (with a plaintext password)
    // plus another account's scoped vault.
    server = await initSupabaseAs(atharva, secureStorage: {
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

  // Tests run in order and share one device keychain and one fake server.
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

  test('creating a vault stores keys for this user on the device and in Supabase', () async {
    await manager.setupNewVault(_password);
    final all = await storage.readAll();

    expect(all.containsKey('anchor_kdf_salt_${atharva.id}'), isTrue);
    expect(all.containsKey('anchor_wrapped_vek_${atharva.id}'), isTrue);
    expect(all.containsKey('anchor_kdf_salt'), isFalse);
    expect(all.values, isNot(contains(_password)));

    final keys = server.table('user_keys').single;
    final wrapped = server.table('wrapped_vault_keys').single;
    expect(keys['user_id'], atharva.id);
    expect(keys['kdf_salt'], all['anchor_kdf_salt_${atharva.id}']);
    expect(wrapped['user_id'], atharva.id);
    expect(wrapped['wrapped_vek'], all['anchor_wrapped_vek_${atharva.id}']);
    expect(wrapped['vek_mac'], isNotNull);
    expect(server.table('profiles').single['id'], atharva.id);
  });

  test('the master password is never sent to Supabase', () {
    for (final request in server.requests) {
      expect(request.body.contains(_password), isFalse, reason: 'Found password in ${request.url}');
    }
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

  test('on a new phone the vault is restored from Supabase', () async {
    FlutterSecureStorage.setMockInitialValues({});
    manager.lockVault();

    expect(await manager.unlockWithSavedBiometrics(), isFalse);
    expect(await manager.hasExistingVault(), isTrue);
    expect(await manager.unlockVault(_password), isTrue);
  });

  test('creating a second vault is refused so saved data stays readable', () async {
    await expectLater(manager.setupNewVault('another-password'), throwsA(isA<VaultAlreadyExistsException>()));
    expect(server.table('wrapped_vault_keys'), hasLength(1));
  });

  test('switching accounts hides the previous user\'s vault', () async {
    await switchUserTo(otherUser);
    manager.lockVault();
    expect(await manager.hasExistingVault(), isFalse);
    expect(await manager.unlockVault(_password), isFalse);

    await switchUserTo(atharva);
    expect(await manager.hasExistingVault(), isTrue);
  });

  test('without internet and no local vault, the check fails instead of offering a new vault', () async {
    FlutterSecureStorage.setMockInitialValues({});
    server.offline = true;
    addTearDown(() => server.offline = false);

    await expectLater(manager.hasExistingVault(), throwsA(anything));
  });
}
