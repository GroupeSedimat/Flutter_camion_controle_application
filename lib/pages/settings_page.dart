// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/user/edit_profile_page.dart';
import 'package:flutter_application_1/pages/user/reset_password_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../theme_provider.dart';
import '../../locale_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.darkMode),
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.language),
              trailing: DropdownButton<String>(
                value: localeProvider.locale.languageCode,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    localeProvider.setLocale(newValue);
                    Get.updateLocale(Locale(newValue));
                  }
                },
                items: <String>['en', 'fr', 'pl']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(_getLanguageName(value)),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.editInformation),
              trailing: Icon(Icons.edit),
              onTap: () {
               Navigator.pop(context);
               Get.to(() => ModifyProfilePage());
              },
            ),
            ListTile(
              trailing: Icon(Icons.lock),
              title: Text(AppLocalizations.of(context)!.passChange),
              
              onTap: () {
                  Navigator.pop(context);
                 Get.to(() => ResetPasswordPage());
              },
            ),
          ],
        ),
      ),
    );
  }

  // Funkcja zwracająca nazwy języków w wybranych językach
  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'pl':
        return 'Polski';
      case 'wo':
        return 'Wolof';
      default:
        return '';
    }
  }
}