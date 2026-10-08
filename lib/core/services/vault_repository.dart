import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/audit_entry.dart';
import '../models/document_item.dart';
import '../models/emergency_contact.dart';
import '../models/password_item.dart';
import '../security/crypto_engine.dart';
import '../security/key_hierarchy_manager.dart';
import 'current_user.dart';
import 'profile_service.dart';

/// Reads and writes the signed-in user's vault data in Supabase.
///
/// Sensitive values (document ID numbers, holder names, passwords) are
/// encrypted on the device with the vault key before upload, so Supabase only
/// ever stores ciphertext for them. Every query is filtered by the user's id
/// on top of the row-level security policies.
///
/// Listeners are notified after every successful write so screens like the
/// dashboard can refresh.
class VaultRepository extends ChangeNotifier {
  static final VaultRepository _instance = VaultRepository._internal();
  factory VaultRepository() => _instance;
  VaultRepository._internal();

  SupabaseClient get _db => Supabase.instance.client;

  String get _uid {
    final uid = CurrentUser.id;
    if (uid == null) throw StateError('Not signed in.');
    return uid;
  }

  SecretKey get _vek {
    final vek = KeyHierarchyManager().activeVek;
    if (vek == null) throw StateError('Vault is locked. Unlock it with your master password.');
    return vek;
  }

  Future<String> _seal(Map<String, dynamic> data) async {
    final box = await CryptoEngine.encryptString(plaintext: jsonEncode(data), secretKey: _vek);
    return jsonEncode(box);
  }

  Future<Map<String, dynamic>?> _open(String? blob) async {
    if (blob == null || blob.isEmpty) return null;
    try {
      final box = Map<String, dynamic>.from(jsonDecode(blob) as Map);
      final plain = await CryptoEngine.decryptString(
        ciphertextBase64: box['ciphertext'] as String,
        nonceBase64: box['nonce'] as String,
        macBase64: box['mac'] as String,
        secretKey: _vek,
      );
      return Map<String, dynamic>.from(jsonDecode(plain) as Map);
    } catch (e) {
      debugPrint('Vault decrypt notice: $e');
      return null;
    }
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---------------------------------------------------------------- Documents

  Future<List<DocumentItem>> fetchDocuments() async {
    final rows = await _db
        .from('documents')
        .select('id, title, category, created_at, document_metadata(expiry_date, encrypted_metadata_blob)')
        .eq('owner_id', _uid)
        .order('created_at', ascending: false);

    final items = <DocumentItem>[];
    for (final row in rows) {
      final rawMeta = row['document_metadata'];
      final meta = rawMeta is List ? (rawMeta.isEmpty ? null : rawMeta.first) : rawMeta;
      final details = await _open(meta?['encrypted_metadata_blob'] as String?);
      final expiry = meta?['expiry_date'] as String?;
      items.add(DocumentItem(
        id: row['id'] as String,
        title: row['title'] as String,
        category: row['category'] as String,
        holderName: details?['holder_name'] as String? ?? '',
        idNumber: details?['id_number'] as String? ?? '',
        expiryDate: expiry != null ? DateTime.parse(expiry) : null,
        createdAt: DateTime.parse(row['created_at'] as String),
      ));
    }
    return items;
  }

  Future<void> addDocument({
    required String title,
    required String category,
    String holderName = '',
    String idNumber = '',
    DateTime? expiryDate,
  }) async {
    await ProfileService.ensureProfile();
    final blob = await _seal({'holder_name': holderName, 'id_number': idNumber});

    final inserted = await _db
        .from('documents')
        .insert({'owner_id': _uid, 'title': title, 'category': category})
        .select('id');
    final docId = inserted.first['id'] as String;

    try {
      await _db.from('document_metadata').insert({
        'document_id': docId,
        'expiry_date': expiryDate != null ? _isoDate(expiryDate) : null,
        'encrypted_metadata_blob': blob,
      });
    } catch (_) {
      await _db.from('documents').delete().eq('id', docId);
      rethrow;
    }

    await _log('DOCUMENT_ADDED', 'DOCUMENT', docId);
    notifyListeners();
  }

  // ---------------------------------------------------------------- Passwords

  Future<List<PasswordItem>> fetchPasswords() async {
    final rows = await _db
        .from('password_items')
        .select('id, website_title, username, category, access_level, security_score_rating, '
            'encrypted_password, password_nonce, password_mac, created_at')
        .eq('owner_id', _uid)
        .order('created_at', ascending: false);

    return rows
        .map((row) => PasswordItem(
              id: row['id'] as String,
              websiteTitle: row['website_title'] as String,
              username: row['username'] as String,
              category: row['category'] as String? ?? 'General',
              accessLevel: row['access_level'] as String? ?? 'Only Me',
              securityScore: row['security_score_rating'] as int? ?? 0,
              encryptedPassword: row['encrypted_password'] as String,
              passwordNonce: row['password_nonce'] as String,
              passwordMac: row['password_mac'] as String? ?? '',
              createdAt: DateTime.parse(row['created_at'] as String),
            ))
        .toList();
  }

  Future<void> addPassword({
    required String websiteTitle,
    required String username,
    required String password,
    required String category,
    required String accessLevel,
  }) async {
    await ProfileService.ensureProfile();
    final box = await CryptoEngine.encryptString(plaintext: password, secretKey: _vek);

    final inserted = await _db.from('password_items').insert({
      'owner_id': _uid,
      'website_title': websiteTitle,
      'username': username,
      'encrypted_password': box['ciphertext'],
      'password_nonce': box['nonce'],
      'password_mac': box['mac'],
      'category': category,
      'access_level': accessLevel,
      'security_score_rating': scorePassword(password),
    }).select('id');

    await _log('PASSWORD_ADDED', 'PASSWORD', inserted.first['id'] as String);
    notifyListeners();
  }

  Future<String> revealPassword(PasswordItem item) {
    return CryptoEngine.decryptString(
      ciphertextBase64: item.encryptedPassword,
      nonceBase64: item.passwordNonce,
      macBase64: item.passwordMac,
      secretKey: _vek,
    );
  }

  /// Simple 0-100 strength score from length and character variety.
  static int scorePassword(String password) {
    var score = (password.length * 5).clamp(0, 50);
    if (RegExp(r'[a-z]').hasMatch(password)) score += 10;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 10;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 15;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score += 15;
    return score.clamp(0, 100);
  }

  // ------------------------------------------------------- Emergency contacts

  Future<List<EmergencyContact>> fetchEmergencyContacts() async {
    final rows = await _db
        .from('emergency_contacts')
        .select('id, contact_name, relationship, contact_phone')
        .eq('user_id', _uid)
        .order('created_at');

    return rows
        .map((row) => EmergencyContact(
              id: row['id'] as String,
              name: row['contact_name'] as String? ?? '',
              relationship: row['relationship'] as String? ?? 'Emergency Contact',
              phone: row['contact_phone'] as String? ?? '',
            ))
        .toList();
  }

  Future<void> addEmergencyContact({
    required String name,
    required String relationship,
    required String phone,
  }) async {
    await ProfileService.ensureProfile();
    final inserted = await _db.from('emergency_contacts').insert({
      'user_id': _uid,
      'contact_name': name,
      'relationship': relationship,
      'contact_phone': phone,
    }).select('id');

    await _log('EMERGENCY_CONTACT_ADDED', 'EMERGENCY_CONTACT', inserted.first['id'] as String);
    notifyListeners();
  }

  // ------------------------------------------------------------------- Family

  /// Returns the user's family vault name, or null if none was saved yet.
  Future<String?> fetchFamilyName() async {
    final rows = await _db.from('families').select('name').eq('owner_id', _uid).limit(1);
    return rows.isEmpty ? null : rows.first['name'] as String;
  }

  Future<String> _familyId() async {
    final rows = await _db.from('families').select('id').eq('owner_id', _uid).limit(1);
    if (rows.isNotEmpty) return rows.first['id'] as String;
    return saveFamilyName('${CurrentUser.defaultVaultName} Vault');
  }

  /// Creates or renames the user's family vault and returns its id.
  Future<String> saveFamilyName(String name) async {
    await ProfileService.ensureProfile();
    final rows = await _db
        .from('families')
        .upsert({'owner_id': _uid, 'name': name}, onConflict: 'owner_id')
        .select('id');
    return rows.first['id'] as String;
  }

  /// Family members the user added (stored as invitations until they join).
  Future<List<Map<String, String>>> fetchFamilyInvitations() async {
    final rows = await _db
        .from('family_invitations')
        .select('invitee_name, invitee_email, relation, role, status')
        .eq('inviter_id', _uid)
        .order('created_at');

    return rows
        .map((row) => {
              'name': row['invitee_name'] as String? ?? '',
              'email': row['invitee_email'] as String,
              'relation': row['relation'] as String? ?? '',
              'role': roleLabel(row['role'] as String),
            })
        .toList();
  }

  Future<void> addFamilyInvitation({
    required String name,
    required String email,
    required String relation,
    required String role,
  }) async {
    final familyId = await _familyId();
    final inserted = await _db.from('family_invitations').insert({
      'family_id': familyId,
      'inviter_id': _uid,
      'invitee_name': name,
      'invitee_email': email,
      'relation': relation,
      'role': roleCode(role),
      'invitation_code': _randomCode(),
      'expires_at': DateTime.now().toUtc().add(const Duration(days: 30)).toIso8601String(),
    }).select('id');

    await _log('FAMILY_MEMBER_INVITED', 'FAMILY_INVITATION', inserted.first['id'] as String);
    notifyListeners();
  }

  static String roleCode(String label) => label.toUpperCase().replaceAll(' ', '_');

  static String roleLabel(String code) => code
      .split('_')
      .map((w) => w.isEmpty ? w : w[0] + w.substring(1).toLowerCase())
      .join(' ');

  static String _randomCode() {
    final rnd = Random.secure();
    return base64Url.encode(List<int>.generate(12, (_) => rnd.nextInt(256))).replaceAll('=', '');
  }

  // ---------------------------------------------------------------- Activity

  Future<void> _log(String action, String targetType, String targetId) async {
    try {
      await _db.from('audit_logs').insert({
        'user_id': _uid,
        'action': action,
        'target_type': targetType,
        'target_id': targetId,
      });
    } catch (e) {
      debugPrint('Audit log notice: $e');
    }
  }

  Future<List<AuditEntry>> fetchRecentActivity({int limit = 5}) async {
    final rows = await _db
        .from('audit_logs')
        .select('id, action, created_at')
        .eq('user_id', _uid)
        .order('created_at', ascending: false)
        .limit(limit);

    return rows
        .map((row) => AuditEntry(
              id: row['id'] as String,
              action: row['action'] as String,
              createdAt: DateTime.parse(row['created_at'] as String),
            ))
        .toList();
  }

  Future<int> countPasswords() async {
    final rows = await _db.from('password_items').select('id').eq('owner_id', _uid);
    return rows.length;
  }
}
