// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/user/edit_profile_page.dart';
import 'package:flutter_application_1/pages/user/reset_password_page.dart';
import 'package:flutter_application_1/services/app_colors.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
//import '../../locale_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    //final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Mode',
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
                          ? 'Clair'
                          : mode == ThemeMode.dark
                              ? 'Sombre'
                              : 'Automatique',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  );
                }).toList(),
              ),
            ),
          
            // ListTile(
            //   title: Text('Langue'),
            //   trailing: DropdownButton<String>(
            //     value: localeProvider.locale.languageCode,
            //     onChanged: (String? newValue) {
            //       if (newValue != null) {
            //         localeProvider.setLocale(newValue);
            //       }
            //     },
            //     items: <String>['en', 'fr'].map<DropdownMenuItem<String>>((String value) {
            //       return DropdownMenuItem<String>(
            //         value: value,
            //         child: Text(value == 'en' ? 'Anglais' : 'Français'),
            //       );
            //     }).toList(),
            //   ),
            // ),
            // Sélection de la couleur du thème
            ListTile(
              title: Text('Couleur'),
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

            // Modifier les informations utilisateur
            ListTile(
              title: Text('Modifier vos informations'),
              trailing: Icon(Icons.edit),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => ModifyProfilePage());
              },
            ),

            // Modifier le mot de passe
            ListTile(
              trailing: Icon(Icons.lock),
              title: Text('Modifier mot de passe'),
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
}