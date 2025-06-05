// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/pages/admin/admin_page.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
      ],
      home: child,
    );
  }

  testWidgets('Affiche AdminPage avec le bon titre',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        createTestWidget(const AdminPage(userRole: UserRole.admin)));

    expect(find.text('Super Admin Page'), findsOneWidget);
  });

  testWidgets('Vérifie la présence des boutons du dashboard',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        createTestWidget(const AdminPage(userRole: UserRole.admin)));

    // Attendre que l'interface se charge complètement
    await tester.pumpAndSettle();

    final List<String> expectedTexts = [
      'Manage Users',
      'Checklist',
      'The list of lists',
      'Company',
    ];

    bool testPassed = true;

    for (String text in expectedTexts) {
      if (find.text(text).evaluate().isEmpty) {
        testPassed = false;
        debugPrint('❌ Texte non trouvé : $text');
      } else {
        debugPrint('✅ Texte trouvé : $text');
      }
    }

    // Vérifier que tous les textes sont trouvés
    expect(testPassed, true,
        reason: "Certains textes ne sont pas affichés correctement.");
  });

  testWidgets('Déboguer affichage des widgets', (WidgetTester tester) async {
    await tester.pumpWidget(
        createTestWidget(const AdminPage(userRole: UserRole.admin)));

    await tester.pumpAndSettle();

    // Lister tous les widgets texte affichés
    tester.allWidgets.forEach((widget) {
      if (widget is Text) {
        debugPrint('Texte affiché: ${widget.data}');
      }
    });
  });
}
