import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anchor/features/documents/documents_screen.dart';

void main() {
  testWidgets('Anchor DocumentsScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DocumentsScreen(),
        ),
      ),
    );
    expect(find.byType(DocumentsScreen), findsOneWidget);
    expect(find.text('Document Vault'), findsOneWidget);
  });
}
