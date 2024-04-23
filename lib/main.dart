// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors 

import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth_controller.dart';
import 'package:flutter_application_1/checklist/loading_vrm.dart';
import 'package:flutter_application_1/checklist/wrapper.dart';
import 'package:flutter_application_1/checklist/checklist.dart';
import 'package:flutter_application_1/checklist/diagrams.dart';
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
      routes: {
        '/wrapper': (context) => const Wrapper(),
        '/checklist': (context) => const CheckList(),
        '/diagrams': (context) => const Diagrams(),
        '/loadingdata': (context) => const LoadingData(),
      },
    );
  }
}
