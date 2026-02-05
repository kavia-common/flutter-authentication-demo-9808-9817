import 'package:auth_demo_frontend/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shows Log In text', (WidgetTester tester) async {
    await tester.pumpWidget(const AuthDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('Log In'), findsOneWidget);
  });
}
