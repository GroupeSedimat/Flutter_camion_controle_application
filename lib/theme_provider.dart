import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  MaterialColor _customColor = Colors.blue;

  ThemeProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  MaterialColor get customColor => _customColor;

  void changeColor(MaterialColor newColor) {
    if (newColor != _customColor) {
      _customColor = newColor;
      _saveColor(newColor);
      notifyListeners();
    }
  }

ThemeData lightTheme = ThemeData.from(
  colorScheme: ColorScheme.light(primary: Colors.blue),
);

ThemeData darkTheme = ThemeData.from(
  colorScheme: ColorScheme.dark(primary: Colors.blue),
);

  // Change le mode de thème directement et le sauvegarde
  void changeThemeMode(ThemeMode newMode) {
    _themeMode = newMode;
    _saveThemeMode();
    notifyListeners();
  }

  void _saveColor(MaterialColor color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('customColor', AppColorExtension.fromMaterialColor(color).index);
  }

  void _saveThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', _themeMode.index);
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? colorIndex = prefs.getInt('customColor');
    int? themeModeIndex = prefs.getInt('themeMode');

    if (colorIndex != null) {
      _customColor = AppColor.values[colorIndex].color;
    }

    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }

    notifyListeners();
  }
}
