import 'package:anchor/core/security/key_hierarchy_manager.dart';
import 'package:anchor/core/services/vault_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_session.dart';
import 'helpers/fake_supabase_server.dart';

const _secretPassword = 'Netfl!x-S3cret-2026';
const _passportNumber = 'Z1234567';

void main() {
  final repo = VaultRepository();
  late FakeSupabaseServer server;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    server = await initSupabaseAs(atharva);
    await KeyHierarchyManager().setupNewVault('atharva-master-123');
  });

  // Tests run in order and share one fake server.
  test('documents are saved, and the holder and ID number are encrypted', () async {
    await repo.addDocument(
      title: 'Passport',
      category: 'Identity',
      holderName: 'Atharva Shewale',
      idNumber: _passportNumber,
      expiryDate: DateTime(2027, 2, 14),
    );

    final row = server.table('documents').single;
    expect(row['owner_id'], atharva.id);
    expect(row['title'], 'Passport');
    final meta = server.table('document_metadata').single;
    expect(meta['expiry_date'], '2027-02-14');
    expect(meta['encrypted_metadata_blob'], isNot(contains(_passportNumber)));
    expect(meta['encrypted_metadata_blob'], isNot(contains('Atharva Shewale')));

    final docs = await repo.fetchDocuments();
    expect(docs.single.title, 'Passport');
    expect(docs.single.idNumber, _passportNumber);
    expect(docs.single.holderName, 'Atharva Shewale');
    expect(docs.single.expiryDate, DateTime(2027, 2, 14));
  });

  test('passwords are encrypted before upload and can be revealed', () async {
    await repo.addPassword(
      websiteTitle: 'Netflix',
      username: 'atharva@example.com',
      password: _secretPassword,
      category: 'OTT & Entertainment',
      accessLevel: 'Only Me',
    );

    final row = server.table('password_items').single;
    expect(row['encrypted_password'], isNot(_secretPassword));
    expect(row['password_mac'], isNotNull);
    expect(row['access_level'], 'Only Me');
    for (final request in server.requests) {
      expect(request.body.contains(_secretPassword), isFalse, reason: 'Plaintext password sent to ${request.url}');
    }

    final items = await repo.fetchPasswords();
    expect(items.single.websiteTitle, 'Netflix');
    expect(items.single.strengthLabel, 'Strong');
    expect(await repo.revealPassword(items.single), _secretPassword);
    expect(await repo.countPasswords(), 1);
  });

  test('emergency contacts are saved and loaded', () async {
    await repo.addEmergencyContact(name: 'Dr. Mehta', relationship: 'Family Doctor', phone: '+91 90000 22222');

    expect(server.table('emergency_contacts').single['user_id'], atharva.id);
    final contacts = await repo.fetchEmergencyContacts();
    expect(contacts.single.name, 'Dr. Mehta');
    expect(contacts.single.phone, '+91 90000 22222');
  });

  test('each save is recorded in the activity log, newest first', () async {
    final activity = await repo.fetchRecentActivity();
    expect(activity.map((a) => a.action), ['EMERGENCY_CONTACT_ADDED', 'PASSWORD_ADDED', 'DOCUMENT_ADDED']);
  });

  test('saving is refused while the vault is locked', () async {
    KeyHierarchyManager().lockVault();
    addTearDown(() => KeyHierarchyManager().unlockVault('atharva-master-123'));

    await expectLater(repo.addPassword(
      websiteTitle: 'Bank',
      username: 'me',
      password: 'x',
      category: 'Accounts',
      accessLevel: 'Only Me',
    ), throwsStateError);
    expect(server.table('password_items'), hasLength(1));
  });

  test("another account sees none of Atharva's data", () async {
    await switchUserTo(otherUser);
    addTearDown(() => switchUserTo(atharva));

    expect(await repo.fetchDocuments(), isEmpty);
    expect(await repo.fetchPasswords(), isEmpty);
    expect(await repo.fetchEmergencyContacts(), isEmpty);
    expect(await repo.fetchRecentActivity(), isEmpty);
  });

  test('password strength scoring', () {
    expect(VaultRepository.scorePassword('abc'), lessThan(50));
    expect(VaultRepository.scorePassword('abcdefgh1'), inInclusiveRange(50, 79));
    expect(VaultRepository.scorePassword(_secretPassword), greaterThanOrEqualTo(80));
  });
}
