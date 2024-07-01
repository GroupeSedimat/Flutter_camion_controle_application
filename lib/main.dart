
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/checklist/loading_vrm.dart';
import 'package:flutter_application_1/pages/wrapper.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/checklist/diagrams.dart';
import 'package:get/get.dart';


import 'pages/splash_screen.dart';

void main() async {
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
