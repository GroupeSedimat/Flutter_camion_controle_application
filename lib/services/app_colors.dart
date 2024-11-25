// app_colors.dart

import 'package:flutter/material.dart';

enum AppColor {
  blue,
  red,
  green,
  purple,
  orange,
  //yellow,
  brown,
  cyan,
  pink,
  indigo

  
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
      //case AppColor.yellow:
       // return Colors.yellow;
      case AppColor.brown:
        return Colors.brown;  
      case AppColor.cyan:
        return Colors.cyan;   
      case AppColor.pink:
        return Colors.pink;    
      case AppColor.indigo:
        return Colors.indigo;
      
      
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
      //case AppColor.yellow:
        //return 'Jaune';  
      case AppColor.brown:
        return 'Marron'; 
      case AppColor.cyan:
        return 'Cyan';   
      case AppColor.pink:
        return 'Rose';   
      case AppColor.indigo:
        return 'Indigo';
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
      //case Colors.yellow:
        //return AppColor.yellow; 
      case Colors.brown:
        return AppColor.brown;   
      case Colors.cyan:
        return AppColor.cyan;  
      case Colors.pink:
        return AppColor.pink;  
      case Colors.indigo:
        return AppColor.indigo;  
     
      default:
        return AppColor.blue;  
    }
  }
}

  