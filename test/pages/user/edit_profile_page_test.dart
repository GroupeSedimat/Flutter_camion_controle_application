import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Text field input test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextField(
            key: Key('myTextField'),
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(Key('myTextField')), 'Test input');
    await tester.pump();

    expect(find.text('Test input'), findsOneWidget);
  });
}
