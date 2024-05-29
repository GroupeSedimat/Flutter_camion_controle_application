// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors 

import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController());
  runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Mobility corner app",
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: SplashScreen(),
    );
  }
}
