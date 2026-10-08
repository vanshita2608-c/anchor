import 'package:anchor/core/services/family_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_session.dart';
import 'helpers/fake_supabase_server.dart';

void main() {
  final family = FamilyService();
  late FakeSupabaseServer server;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    server = await initSupabaseAs(otherUser);
  });

  // Tests run in order and share one fake server.
  test('vault name and members are saved to Supabase', () async {
    family.initializeOwner();
    await family.saveVaultName('Shah Family');
    await family.addMember(name: 'Mom', email: 'mom@example.com', relation: 'Mother', role: 'Emergency Contact');

    expect(server.table('families').single['name'], 'Shah Family Vault');
    final invite = server.table('family_invitations').single;
    expect(invite['invitee_name'], 'Mom');
    expect(invite['role'], 'EMERGENCY_CONTACT');
    expect(invite['inviter_id'], otherUser.id);
    expect(family.memberCount, 2);
  });

  test('members are loaded back from Supabase after a restart', () async {
    family.reset();
    await family.load();

    expect(family.vaultName, 'Shah Family Vault');
    expect(family.members.map((m) => m['name']), [otherUser.fullName, 'Mom']);
    expect(family.members[1]['role'], 'Emergency Contact');
  });

  test('another account signing in does not inherit the previous family', () async {
    await switchUserTo(atharva);
    family.initializeOwner();

    expect(family.memberCount, 1);
    expect(family.members.single['email'], atharva.email);
    expect(family.vaultName, "Atharva's Family Vault");

    await family.load();
    expect(family.memberCount, 1, reason: "Vanshita's invitations must not load for Atharva");
  });

  test('reset clears members and vault name', () {
    family.reset();
    expect(family.members, isEmpty);
    expect(family.vaultName, "Atharva's Family Vault");
  });
}
