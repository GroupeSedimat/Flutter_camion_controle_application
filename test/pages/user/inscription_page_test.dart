import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Text visibility test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Text('Welcome to the app!'),
        ),
      ),
    );

    // Vérifie si le texte est bien visible
    expect(find.text('Welcome to the app!'), findsOneWidget);
  });
}
