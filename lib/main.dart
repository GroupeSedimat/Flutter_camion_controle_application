// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, depend_on_referenced_packages

import 'package:flutter/material.dart';
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
