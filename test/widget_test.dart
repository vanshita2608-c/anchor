import 'package:flutter_test/flutter_test.dart';
import 'package:anchor/main.dart';

void main() {
  testWidgets('Anchor app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AnchorApp());
    expect(find.byType(AnchorApp), findsOneWidget);
  });
}
