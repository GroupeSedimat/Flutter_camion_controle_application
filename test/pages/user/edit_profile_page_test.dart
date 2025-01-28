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

 //Tester les fonctionnalités locales 
  testWidgets('Username field updates on input', (WidgetTester tester) async {
  final usernameController = TextEditingController();

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TextField(
          controller: usernameController,
          decoration: InputDecoration(labelText: 'Username'),
        ),
      ),
    ),
  );


  await tester.enterText(find.byType(TextField), 'TestUser');
  await tester.pump();


  expect(usernameController.text, 'TestUser');
});

//Simplifier la logique
testWidgets('Confirm button can be tapped', (WidgetTester tester) async {
  bool buttonPressed = false;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ElevatedButton(
          onPressed: () {
            buttonPressed = true;
          },
          child: Text('Confirm'),
        ),
      ),
    ),
  );

  // Vérifier que le bouton est affiché
  expect(find.text('Confirm'), findsOneWidget);

  // Simuler un clic sur le bouton
  await tester.tap(find.text('Confirm'));
  await tester.pump();

  // Vérifier que le bouton a été cliqué
  expect(buttonPressed, isTrue);
});

}
