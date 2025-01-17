import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Text('Hello, Mobility Corner!')),
      ),
    );

    expect(find.text('Hello, Mobility Corner!'), findsOneWidget);
  });
  }

  