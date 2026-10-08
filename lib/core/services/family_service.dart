import 'package:flutter/foundation.dart';
import 'current_user.dart';
import 'vault_repository.dart';

/// In-memory view of the signed-in user's family vault, backed by Supabase
/// (`families` + `family_invitations`) through [VaultRepository].
class FamilyService extends ChangeNotifier {
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;
  FamilyService._internal();

  String? _vaultName;
  final List<Map<String, String>> _members = [];

  String get vaultName => _vaultName ?? '${CurrentUser.defaultVaultName} Vault';
  List<Map<String, String>> get members => List.unmodifiable(_members);
  int get memberCount => _members.length;

  void initializeOwner() {
    final email = CurrentUser.email;
    final name = CurrentUser.displayName;

    // A different account signed in: drop the previous user's members.
    if (_members.isNotEmpty && _members[0]['email'] != email) {
      reset(notify: false);
    }

    final ownerMap = {
      'name': name,
      'email': email,
      'relation': 'Owner',
      'role': 'Owner',
    };

    // Screens call this from initState; only notify on a real change so
    // listeners aren't marked dirty mid-build.
    if (_members.isNotEmpty && mapEquals(_members[0], ownerMap)) return;

    if (_members.isEmpty) {
      _members.add(ownerMap);
    } else {
      _members[0] = ownerMap;
    }
    notifyListeners();
  }

  /// Loads the saved vault name and added members from Supabase.
  Future<void> load() async {
    final repo = VaultRepository();
    final name = await repo.fetchFamilyName();
    final invitations = await repo.fetchFamilyInvitations();

    initializeOwner();
    _vaultName = name ?? _vaultName;
    _members
      ..removeRange(1, _members.length)
      ..addAll(invitations);
    notifyListeners();
  }

  /// Saves the vault name to Supabase.
  Future<void> saveVaultName(String name) async {
    if (name.trim().isEmpty) return;
    final fullName = name.trim().contains('Vault') ? name.trim() : '${name.trim()} Vault';
    await VaultRepository().saveFamilyName(fullName);
    _vaultName = fullName;
    notifyListeners();
  }

  /// Saves a new family member (as an invitation) to Supabase.
  Future<void> addMember({
    required String name,
    required String email,
    required String relation,
    required String role,
  }) async {
    await VaultRepository().addFamilyInvitation(name: name, email: email, relation: relation, role: role);
    if (_members.isEmpty) {
      initializeOwner();
    }
    _members.add({
      'name': name,
      'email': email,
      'relation': relation,
      'role': role,
    });
    notifyListeners();
  }

  /// Clears all in-memory state; called on sign-out.
  void reset({bool notify = true}) {
    _vaultName = null;
    _members.clear();
    if (notify) notifyListeners();
  }
}
