import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/l10n/l10n.dart';
import 'package:flutter_application_1/pages/map/map_page.dart';
import 'package:flutter_application_1/pages/checklist/loading_vrm.dart';
import 'package:flutter_application_1/pages/wrapper.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/checklist/diagrams.dart';
import 'package:flutter_application_1/pages/splash_screen.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/dialog_services.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_provider.dart';
import 'locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use
    // the "AppleProvider" enum to choose your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider
    // (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    // appleProvider: AppleProvider.appAttest,
  );

  final database = await DatabaseHelper().database;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedLanguageCode = prefs.getString('languageCode');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NetworkService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider(savedLanguageCode)),
        Provider(create: (_) => DatabaseHelper()),
        Provider(create: (context) => SyncService(
          database,
          Provider.of<NetworkService>(context, listen: false),
        )),
      ],
      child: MyApp(savedLanguageCode: savedLanguageCode),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? savedLanguageCode;
  MyApp({this.savedLanguageCode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: DialogService().navigatorKey,
      title: "Mobility Corner App",
      themeMode: context.watch<ThemeProvider>().themeMode,

      // Thème clair
      theme: ThemeData(
        primaryColor: context.watch<ThemeProvider>().customColor,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: context.watch<ThemeProvider>().customColor,
          secondary: context.watch<ThemeProvider>().customColor.shade300,
          background: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black),
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.watch<ThemeProvider>().customColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.watch<ThemeProvider>().customColor),
          ),
        ),
      ),

      // Thème sombre
      darkTheme: ThemeData(
        primaryColor: context.watch<ThemeProvider>().customColor,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: context.watch<ThemeProvider>().customColor,
          secondary: context.watch<ThemeProvider>().customColor.shade300,
          background: Colors.black,
          surface: Colors.black,
          onSurface: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.watch<ThemeProvider>().customColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.watch<ThemeProvider>().customColor),
          ),
        ),
      ),

      locale: context.watch<LocaleProvider>().locale,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      fallbackLocale: Locale('en'),
      home: SplashScreen(),
      routes: {
        '/wrapper': (context) => const Wrapper(),
        '/checklist': (context) => const CheckList(),
        '/diagrams': (context) => const Diagrams(),
        '/loadingdata': (context) => const LoadingData(),
        '/settings': (context) => SettingsPage(),
        // '/map': (context) => MapPage(),
      },
    );
  }
}