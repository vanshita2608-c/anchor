import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:anchor/core/config/app_config.dart';
import 'package:anchor/features/auth/auth_screen.dart';

void main() {
  testWidgets('Anchor AuthScreen smoke test', (WidgetTester tester) async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthScreen(),
      ),
    );
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
