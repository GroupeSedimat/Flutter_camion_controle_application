// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale;

  LocaleProvider(String? savedLanguageCode)
      : _locale = savedLanguageCode != null
      ? Locale(savedLanguageCode)
      : Locale('en');

  Locale get locale => _locale;

  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }
}