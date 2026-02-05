import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shows Log In text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Log In'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Log In'), findsOneWidget);
  });
}
