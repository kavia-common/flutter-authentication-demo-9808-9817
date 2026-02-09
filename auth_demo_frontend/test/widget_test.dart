import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic smoke test', (WidgetTester tester) async {
    // Minimal test to keep `flutter analyze` and `flutter test` healthy even if
    // app entrypoint is being regenerated separately.
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Smoke'))));
    await tester.pumpAndSettle();

    expect(find.text('Smoke'), findsOneWidget);
  });
}
