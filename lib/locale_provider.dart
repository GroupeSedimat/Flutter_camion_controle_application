// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale;

  LocaleProvider(String? savedLanguageCode)
      : _locale = savedLanguageCode != null
      ? Locale(savedLanguageCode)
      : Locale('en'); // Domyślny język to angielski

  Locale get locale => _locale;

  // Zmienianie i zapisywanie języka
  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();

    // Zapisz nowy język w SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }
}