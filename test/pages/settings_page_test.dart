import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:flutter_application_1/locale_provider.dart';
import 'package:flutter_application_1/pages/user/edit_profile_page.dart';
import 'package:flutter_application_1/pages/user/reset_password_page.dart';
import 'package:flutter_application_1/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); 
  

  testWidgets('✅ SettingsPage affiche les éléments principaux', (WidgetTester tester) async {
  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider("en");

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
      ],
      child: GetMaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('fr', ''),
        ],
        home: SettingsPage(),
      ),
    ),
  );

  await tester.pumpAndSettle();

  final context = tester.element(find.byType(SettingsPage));
  final localizations = AppLocalizations.of(context)!;

  // Vérifie si les textes traduits sont affichés
  expect(find.text(localizations.settings), findsOneWidget);
   expect(find.text(localizations.darkMode), findsOneWidget);
  expect(find.text(localizations.language), findsOneWidget);
  expect(find.text(localizations.editInformation), findsOneWidget);
  expect(find.text(localizations.passChange), findsOneWidget);
});


testWidgets('LocaleProvider change langue', (WidgetTester tester) async {
  final localeProvider = LocaleProvider("en");

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: localeProvider,
      child: Builder(
        builder: (context) => MaterialApp(
          home: Text(Provider.of<LocaleProvider>(context).locale.languageCode),
        ),
      ),
    ),
  );

  expect(find.text('en'), findsOneWidget);

  localeProvider.setLocale('fr');
  await tester.pumpAndSettle();

  // Vérifie que la langue est bien passée à 'fr'
  expect(find.text('fr'), findsOneWidget);
});



testWidgets('Naviguer vers ResetPasswordPage fonctionne', (WidgetTester tester) async {
  // Initialisation des providers nécessaires
  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider("en");

  // Charger l'application avec les providers et SettingsPage
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
      ],
      child: GetMaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('fr', ''),
        ],
        home: SettingsPage(), // Page testée
        getPages: [
          GetPage(name: '/reset_password', page: () => ResetPasswordPage()),
        ],
      ),
    ),
  );

  await tester.pumpAndSettle(); // Attendre le rendu

  // 📌 Vérifier que le bouton "Change Password" est bien présent
  final changePasswordFinder = find.text(AppLocalizations.of(Get.context!)!.passChange);
  expect(changePasswordFinder, findsOneWidget);

  // 📌 Appuyer sur le bouton
  await tester.tap(changePasswordFinder);
  await tester.pumpAndSettle();

  // 📌 Vérifier que la page ResetPasswordPage est bien affichée
  expect(find.byType(ResetPasswordPage), findsOneWidget);
});

testWidgets('Naviguer vers ModifyProfilePage fonctionne', (WidgetTester tester) async {
  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider("en");

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
      ],
      child: GetMaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('fr', ''),
        ],
        home: SettingsPage(),
        getPages: [
          GetPage(name: '/', page: () => SettingsPage()), 
          GetPage(name: '/modify_profile', page: () => ModifyProfilePage()),
        ],
      ),
    ),
  );

  await tester.pumpAndSettle(); // Laisser le rendu se terminer

  // 📌 Récupération dynamique du texte du bouton via AppLocalizations
  final editInfoText = AppLocalizations.of(Get.context!)!.editInformation;

  // 📌 Vérifier que le bouton existe
  final buttonFinder = find.text(editInfoText);
  expect(buttonFinder, findsOneWidget);

  // 📌 Appuyer sur le bouton
  await tester.tap(buttonFinder);
  await tester.pumpAndSettle();

  // 📌 Vérifier que ModifyProfilePage est bien affichée
  expect(find.byType(ModifyProfilePage), findsOneWidget);
});


}

