// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, depend_on_referenced_packages

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/pages/map/map_page.dart';
import 'package:flutter_application_1/pages/checklist/loading_vrm.dart';
import 'package:flutter_application_1/pages/wrapper.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/checklist/diagrams.dart';
import 'package:flutter_application_1/pages/splash_screen.dart';
import 'package:flutter_application_1/pages/settings_page.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'theme_provider.dart';
import 'locale_provider.dart';

void main() async {

  /// SDK 23 nécessaire pour que ça marche!
  /// keytool -list -v -alias androiddebugkey -keystore C:\Users\%USERPROFILE%\.android\debug.keystore
  /// Alias name: androiddebugkey
  /// Creation date: 21 juil. 2023
  /// Entry type: PrivateKeyEntry
  /// Certificate chain length: 1
  /// Certificate[1]:
  /// Owner: C=US, O=Android, CN=Android Debug
  /// Issuer: C=US, O=Android, CN=Android Debug
  /// Serial number: 1
  /// Valid from: Fri Jul 21 14:35:57 CEST 2023 until: Sun Jul 13 14:35:57 CEST 2053
  /// Certificate fingerprints:
  ///          SHA1: 08:F9:0E:41:BC:4A:40:43:A5:39:B5:8C:47:6C:96:F1:CE:41:29:0D
  ///          SHA256: 8F:F2:10:D4:9B:DD:F4:49:3F:D1:FF:98:B4:47:55:7D:22:DB:95:1E:F1:DF:0B:82:4B:BC:45:E0:4B:B3:00:36
  /// Signature algorithm name: SHA256withRSA
  /// Subject Public Key Algorithm: 2048-bit RSA key
  /// Version: 1

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.playIntegrity,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    // appleProvider: AppleProvider.appAttest,
  );


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return GetMaterialApp(
            title: "Mobility corner app",
            themeMode: themeProvider.themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            locale: localeProvider.locale,
            supportedLocales: [
              Locale('en', ''), // English
              Locale('fr', ''), // French
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: SplashScreen(),
            routes: {
              '/wrapper': (context) => const Wrapper(),
              '/checklist': (context) => const CheckList(),
              '/diagrams': (context) => const Diagrams(),
              '/loadingdata': (context) => const LoadingData(),
              '/settings': (context) => SettingsPage(), // Page des paramètres
              '/map': (context) => MapPage(), // Ajoutez cette ligne
            },
          );
        },
      ),
    );
  }
}
