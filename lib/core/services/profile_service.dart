import 'package:supabase_flutter/supabase_flutter.dart';
import 'current_user.dart';

/// Every vault table references `profiles(id)`, so the signed-in user's
/// profile row must exist before anything else is written.
class ProfileService {
  ProfileService._();

  static String? _ensuredFor;

  static Future<void> ensureProfile() async {
    final uid = CurrentUser.id;
    if (uid == null) throw StateError('Not signed in.');
    if (_ensuredFor == uid) return;

    await Supabase.instance.client.from('profiles').upsert({
      'id': uid,
      'email': CurrentUser.email,
      'full_name': CurrentUser.displayName,
    });
    _ensuredFor = uid;
  }
}
