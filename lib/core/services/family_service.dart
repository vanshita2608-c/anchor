import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FamilyService extends ChangeNotifier {
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;
  FamilyService._internal();

  String _vaultName = 'Shah Family Vault';
  final List<Map<String, String>> _members = [];

  String get vaultName => _vaultName;
  List<Map<String, String>> get members => List.unmodifiable(_members);
  int get memberCount => _members.length;

  void initializeOwner() {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'owner@example.com';
    final rawName = user?.userMetadata?['full_name'] ??
        (user?.email != null ? user!.email!.split('@').first : 'Vault Owner');

    final name = rawName.toString().isNotEmpty ? rawName.toString() : 'Vault Owner';

    final ownerMap = {
      'name': name,
      'email': email,
      'relation': 'Owner',
      'role': 'Owner',
    };

    if (_members.isEmpty) {
      _members.add(ownerMap);
    } else {
      _members[0] = ownerMap;
    }
    notifyListeners();
  }

  void setVaultName(String name) {
    if (name.trim().isNotEmpty) {
      _vaultName = name.trim().contains('Vault') ? name.trim() : '${name.trim()} Vault';
      notifyListeners();
    }
  }

  void addMember({
    required String name,
    required String email,
    required String relation,
    required String role,
  }) {
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

  void setMembers(List<Map<String, String>> membersList) {
    _members.clear();
    _members.addAll(membersList);
    notifyListeners();
  }
}
