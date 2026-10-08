import 'package:supabase_flutter/supabase_flutter.dart';

/// Read-only accessors for the signed-in Supabase user's identity.
/// Every screen should use these instead of hardcoded placeholder names.
class CurrentUser {
  CurrentUser._();

  static User? get _user => Supabase.instance.client.auth.currentUser;

  static String? get id => _user?.id;

  static String get email => _user?.email ?? '';

  static String get displayName {
    final meta = _user?.userMetadata;
    final name = (meta?['full_name'] ?? meta?['name'])?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
    if (email.isNotEmpty) return email.split('@').first;
    return 'User';
  }

  static String get firstName => displayName.split(' ').first;

  static String get username {
    final value = _user?.userMetadata?['username']?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
    return email.isNotEmpty ? email.split('@').first : '';
  }

  static String get mobile => _user?.userMetadata?['mobile']?.toString().trim() ?? '';

  static String get defaultVaultName {
    final name = displayName;
    return name.contains(' ') ? '${name.split(' ').first}\'s Family' : '$name Family';
  }
}
