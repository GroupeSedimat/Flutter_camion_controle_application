import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Email validation works correctly', () {
    expect(Validator.isValidEmail('test@example.com'), isTrue); 
    expect(Validator.isValidEmail('invalidemail'), isFalse); 
  });

  test('Password validation works correctly', () {
    expect(Validator.isValidPassword('123456'), isTrue); 
    expect(Validator.isValidPassword('123'), isFalse); 
  });

  
}

class Validator {
  static bool isValidEmail(String email) {
    return email.contains('@');
  } 

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}




// test widget commenté 
/**void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Text('Welcome to MCTruckCheck')),
      ),
    );

    expect(find.text('Welcome to MCTruckCheck'), findsOneWidget);
  });

//Ceci permet de tester le bouton login
testWidgets('Log In button is tappable', (WidgetTester tester) async {
  bool buttonTapped = false;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: GestureDetector(
          onTap: () => buttonTapped = true,
          child: Text('Log In'),
        ), 
      ),
    ),
  );

  // Simule un clic sur le bouton "Log In"
  await tester.tap(find.text('Log In'));
  await tester.pump();

  // Vérifie que le bouton a été cliqué
  expect(buttonTapped, isTrue);
});

// Ce test permet de vérifier le lien qui mène à la page d'inscription via la login page
testWidgets('Sign In link navigates to InscriptionPage', (WidgetTester tester) async {
  bool navigatedToInscription = false;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: GestureDetector(
          onTap: () => navigatedToInscription = true,
          child: Text('Sign In'),
        ),
      ),
    ),
  );

  // Simule un clic sur le lien "Sign In"
  await tester.tap(find.text('Sign In'));
  await tester.pump();

  // Vérifie que la navigation a été effectuée
  expect(navigatedToInscription, isTrue);
});

/**testWidgets('LoginPage displays all essential widgets', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(),
      ),
    );

    // Vérifie la présence des champs de texte
    expect(find.byKey(const Key('identifierField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);

    // Vérifie la présence du bouton "Log In"
    expect(find.byKey(const Key('loginButton')), findsOneWidget);

    // Vérifie la présence du lien "Sign In"
    expect(find.byKey(const Key('signInLink')), findsOneWidget);
  });**/


  }**/

  