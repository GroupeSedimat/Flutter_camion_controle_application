// ignore_for_file: use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/user/edit_profile_page.dart';
import 'package:flutter_application_1/pages/user/reset_password_page.dart';
import 'package:flutter_application_1/services/app_colors.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //_buildSectionTitle(context, 'appearance'),
            _buildSettingCard(
              context,
              icon: Icons.dark_mode,
              title: AppLocalizations.of(context)!.darkMode,
              trailing: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                onChanged: (ThemeMode? newThemeMode) {
                  if (newThemeMode != null) {
                    themeProvider.changeThemeMode(newThemeMode);
                  }
                },
                underline: Container(),
                items: ThemeMode.values.map((ThemeMode mode) {
                  return DropdownMenuItem<ThemeMode>(
                    value: mode,
                    child: Text(
                      mode == ThemeMode.light
                          ? AppLocalizations.of(context)!.colorLight
                          : mode == ThemeMode.dark
                              ? AppLocalizations.of(context)!.colorDark
                              : AppLocalizations.of(context)!.colorAutomatic,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              context,
              icon: Icons.color_lens,
              title: AppLocalizations.of(context)!.color,
              trailing: DropdownButton<AppColor>(
                value: AppColor.values.firstWhere(
                  (color) => color.color == themeProvider.customColor,
                  orElse: () => AppColor.blue,
                ),
                onChanged: (AppColor? newColor) {
                  if (newColor != null) {
                    themeProvider.changeColor(newColor.color);
                  }
                },
                underline: Container(),
                items: AppColor.values
                    .map<DropdownMenuItem<AppColor>>((AppColor color) {
                  return DropdownMenuItem<AppColor>(
                    value: color,
                    child: Text(color.name),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // _buildSectionTitle(context, 'preferences'),
            _buildSettingCard(
              context,
              icon: Icons.language,
              title: AppLocalizations.of(context)!.language,
              trailing: DropdownButton<String>(
                value: localeProvider.locale.languageCode,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    localeProvider.setLocale(newValue);
                    Get.updateLocale(Locale(newValue));
                  }
                },
                underline: Container(),
                items: <String>['en', 'fr', 'pl', 'ar', 'nl']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(_getLanguageName(value)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            //_buildSectionTitle(context, 'account'),
            _buildClickableCard(
              context,
              icon: Icons.edit,
              title: AppLocalizations.of(context)!.editInformation,
              onTap: () async {
                //Navigator.pop(context);

                // Récupérer l'utilisateur actuel depuis Firestore
                final userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(AuthController.instance.getCurrentUserUID())
                    .get();

                if (userDoc.exists) {
                  final currentUser = MyUser.fromJson(userDoc.data()!);

                  // Passe l'utilisateur à ModifyProfilePage
                  Get.to(() => ModifyProfilePage(user: currentUser));
                } else {
                  Get.snackbar(
                    "Erreur",
                    "Impossible de récupérer les informations de l'utilisateur.",
                    backgroundColor: Colors.red,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            _buildClickableCard(
              context,
              icon: Icons.lock,
              title: AppLocalizations.of(context)!.passChange,
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildClickableCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).primaryColor),
          title: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        ),
      ),
    );
  }

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
      case 'nl':
        return 'Dutch';
      default:
        return '';
    }
  }
}
