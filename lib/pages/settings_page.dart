// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/user/edit_profile_page.dart';
import 'package:flutter_application_1/pages/user/reset_password_page.dart';
import 'package:flutter_application_1/services/app_colors.dart';
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
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.darkMode,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              trailing: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                onChanged: (ThemeMode? newThemeMode) {
                  if (newThemeMode != null) {
                    themeProvider.changeThemeMode(newThemeMode);
                  }
                },
                items: ThemeMode.values.map((ThemeMode mode) {
                  return DropdownMenuItem<ThemeMode>(
                    value: mode,
                    child: Text(
                      mode == ThemeMode.light
                          ? AppLocalizations.of(context)!.colorLight
                          : mode == ThemeMode.dark
                              ? AppLocalizations.of(context)!.colorDark
                              : AppLocalizations.of(context)!.colorAutomatic,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Sélection de la couleur du thème
            ListTile(
              title: Text(AppLocalizations.of(context)!.color),
              trailing: DropdownButton<AppColor>(
                value: AppColor.values.firstWhere(
                    (color) => color.color == themeProvider.customColor,
                    orElse: () => AppColor.blue),
                onChanged: (AppColor? newColor) {
                  if (newColor != null) {
                    themeProvider.changeColor(newColor.color);
                  }
                },
                items: AppColor.values.map<DropdownMenuItem<AppColor>>((AppColor color) {
                  return DropdownMenuItem<AppColor>(
                    value: color,
                    child: Text(color.name),
                  );
                }).toList(),
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
                items: <String>['en', 'fr', 'pl', 'ar']
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

            // Modifier le mot de passe
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

  // A function that returns the names of languages in selected languages
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
      case 'ar':
        return 'Arabic';
      default:
        return '';
    }
  }
}