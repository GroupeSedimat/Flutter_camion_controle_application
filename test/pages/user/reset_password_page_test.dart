import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/user/reset_password_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResetPasswordPage Tests', () {
    testWidgets('Vérifie la présence du titre et des widgets principaux', (WidgetTester tester) async {
    
      await tester.pumpWidget(
        MaterialApp(
          home: ResetPasswordPage(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
       
          ],
          supportedLocales: const [
            Locale('en'), 
          ],
        ),
      );

     
      expect(find.text('Password Reset'), findsOneWidget);

      
      expect(find.byType(TextField), findsOneWidget);

     
      expect(find.widgetWithText(ElevatedButton, 'Send Email'), findsOneWidget);
    });

    testWidgets('Simule la saisie d\'un email dans le champ', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: ResetPasswordPage(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), 
          ],
        ),
      );

      final emailField = find.byType(TextField);

      await tester.enterText(emailField, 'test@example.com');

      
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Vérifie que le bouton Envoyer est cliquable', (WidgetTester tester) async {
    
      await tester.pumpWidget(
        MaterialApp(
          home: ResetPasswordPage(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), 
          ],
        ),
      );

      
      final sendButton = find.widgetWithText(ElevatedButton, 'Send Email');

    
      expect(sendButton, findsOneWidget);

  
      await tester.tap(sendButton);

  
      await tester.pump();

      
    });
  });
}