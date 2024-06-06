// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors 

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/pages/checklist/loading_vrm.dart';
import 'package:flutter_application_1/pages/checklist/wrapper.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/checklist/diagrams.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController());
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

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
