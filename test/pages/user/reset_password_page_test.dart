import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/user/reset_password_page.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); 

  testWidgets('ResetPasswordPage permet la saisie d\'email', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate, 
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
         Locale('en', ''),
        Locale('fr', ''), 
        ],
        home: ResetPasswordPage(),
      ),
    );

    await tester.pumpAndSettle();

   
    final emailField = find.byType(TextField);
    expect(emailField, findsOneWidget);

   
    await tester.enterText(emailField, 'test@example.com');

    await tester.pump();

 
    expect(find.text('test@example.com'), findsOneWidget);
  });
}