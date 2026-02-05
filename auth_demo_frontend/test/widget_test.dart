import 'package:flutter_test/flutter_test.dart';
import 'package:auth_demo_frontend/main.dart';

void main() {
  testWidgets('Shows Login screen by default', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Log In'), findsOneWidget);
  });
}
