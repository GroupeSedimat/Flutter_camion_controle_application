// app_colors.dart

import 'package:flutter/material.dart';

enum AppColor {
  blue,
  red,
  green,
  purple,
  orange,

  
}

extension AppColorExtension on AppColor {
  MaterialColor get color {
    switch (this) {
      case AppColor.blue:
        return Colors.blue;
      case AppColor.red:
        return Colors.red;
      case AppColor.green:
        return Colors.green;
      case AppColor.purple:
        return Colors.purple;
      case AppColor.orange:
        return Colors.orange;
      
    }
  }

  String get name {
    switch (this) {
      case AppColor.blue:
        return 'Bleu';
      case AppColor.red:
        return 'Rouge';
      case AppColor.green:
        return 'Vert';
      case AppColor.purple:
        return 'Violet';
      case AppColor.orange:
        return 'Orange';
    }
  }

 
  static AppColor fromMaterialColor(MaterialColor color) {
    switch (color) {
      case Colors.blue:
        return AppColor.blue;
      case Colors.red:
        return AppColor.red;
      case Colors.green:
        return AppColor.green;
      case Colors.purple:
        return AppColor.purple;
      case Colors.orange:
        return AppColor.orange;
     
      default:
        return AppColor.blue;  
    }
  }
}

  