// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/user/edit_profile_page.dart';
import 'package:flutter_application_1/pages/user/reset_password_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../locale_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Mode sombre'),
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ),
            ListTile(
              title: Text('Langue'),
              trailing: DropdownButton<String>(
                value: localeProvider.locale.languageCode,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    localeProvider.setLocale(newValue);
                  }
                },
                items: <String>['en', 'fr'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'en' ? 'Anglais' : 'Français'),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text('Modifier vos informations'),
              trailing: Icon(Icons.edit),
              onTap: () {
               Navigator.pop(context);
               Get.to(() => ModifyProfilePage());
              },
            ),
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