import 'package:anchor/features/auth/auth_screen.dart';
import 'package:anchor/features/auth/master_password_screen.dart';
import 'package:anchor/features/dashboard/dashboard_screen.dart';
import 'package:anchor/features/documents/documents_screen.dart';
import 'package:anchor/features/emergency/emergency_screen.dart';
import 'package:anchor/features/passwords/passwords_screen.dart';
import 'package:anchor/features/profile/profile_screen.dart';
import 'package:anchor/features/security/security_screen.dart';
import 'package:anchor/shared/widgets/anchor_nav_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/fake_session.dart';

/// Strings from the old hardcoded sample data that must never reach a new user.
const _foreignData = [
  'Vanshita',
  'vanshita',
  'Shah',
  'J82930192',
  'Rajesh',
  'Malhotra',
  'Bandra',
  'Netflix (Family Plan)',
  '24 Items',
  '18 Saved',
];

List<String> _allVisibleText(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text, skipOffstage: false))
      .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
      .toList();
}

void _expectNoForeignData(WidgetTester tester) {
  for (final text in _allVisibleText(tester)) {
    for (final bad in _foreignData) {
      expect(text.contains(bad), isFalse, reason: 'Found "$bad" in "$text"');
    }
  }
}

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: screen));
  await tester.pump();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initSupabaseAs(atharva);
  });

  test('signed-in user is the fake Atharva account', () {
    expect(Supabase.instance.client.auth.currentUser?.email, atharva.email);
  });

  testWidgets('dashboard greets the signed-in user, not Vanshita', (tester) async {
    await _pump(tester, const DashboardScreen());
    expect(find.textContaining('Atharva'), findsWidgets);
    expect(find.textContaining("Atharva's Family Vault"), findsOneWidget);
    expect(find.textContaining('1 Member'), findsOneWidget);
    expect(find.text('No activity yet'), findsOneWidget);
    _expectNoForeignData(tester);
  });

  testWidgets('documents screen starts empty', (tester) async {
    await _pump(tester, const DocumentsScreen());
    expect(find.text('No documents in All'), findsOneWidget);
    _expectNoForeignData(tester);
  });

  testWidgets('passwords screen starts empty', (tester) async {
    await _pump(tester, const PasswordsScreen());
    expect(find.text('No passwords saved yet'), findsOneWidget);
    _expectNoForeignData(tester);
  });

  testWidgets('emergency screen starts with no contacts', (tester) async {
    await _pump(tester, const EmergencyScreen());
    expect(find.textContaining('No emergency contacts yet'), findsOneWidget);
    _expectNoForeignData(tester);
  });

  testWidgets('profile shows the signed-in user details', (tester) async {
    await _pump(tester, const ProfileScreen());
    expect(find.text('Atharva Shewale'), findsOneWidget);
    expect(find.text(atharva.email), findsOneWidget);
    expect(find.text('@atharva_s • +91 90000 11111'), findsOneWidget);
    _expectNoForeignData(tester);
  });

  testWidgets('security audit trail shows the signed-in email', (tester) async {
    await _pump(tester, const SecurityScreen());
    expect(find.text(atharva.email), findsOneWidget);
    _expectNoForeignData(tester);
  });

  testWidgets('no tab of the main app shows Vanshita data', (tester) async {
    await _pump(tester, const AnchorNavShell());
    for (final label in ['Vault', 'Family', 'Security', 'Profile', 'Home']) {
      await tester.tap(find.text(label).last);
      await tester.pump();
      _expectNoForeignData(tester);
    }
  });

  testWidgets('failed sign-in stays on the login screen', (tester) async {
    await _pump(tester, const AuthScreen());
    await tester.enterText(find.widgetWithText(TextField, 'Email Address'), 'atharva@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'wrong-password');

    // The test HTTP client answers every request with 400, i.e. a failed login.
    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await Future<void>.delayed(const Duration(seconds: 2));
    });
    await tester.pump();

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.byType(MasterPasswordScreen), findsNothing);
  });
}
