import 'package:anchor/core/services/family_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_session.dart';

void main() {
  final family = FamilyService();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initSupabaseAs(otherUser);
  });

  test('another account signing in does not inherit the previous family', () async {
    family.initializeOwner();
    family.setVaultName('Shah Family');
    family.addMember(name: 'Mom', email: 'mom@example.com', relation: 'Mother', role: 'Member');
    expect(family.memberCount, 2);

    await switchUserTo(atharva);
    family.initializeOwner();

    expect(family.memberCount, 1);
    expect(family.members.single['email'], atharva.email);
    expect(family.vaultName, "Atharva's Family Vault");
  });

  test('reset clears members and vault name', () {
    family.setVaultName('Custom');
    family.reset();
    expect(family.members, isEmpty);
    expect(family.vaultName, "Atharva's Family Vault");
  });
}
