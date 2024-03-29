import 'package:flutter/material.dart';
import 'package:flutter_application_1/inscription_page.dart';
import 'package:flutter_application_1/login_page.dart';
import 'package:flutter_application_1/welcome_page.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
void main() => runApp(MaterialApp ( 
  home: LoginPage  (),
  ));

  class MyApp extends StatelessWidget{
    @override
    Widget build(BuildContext context){
      return GetMaterialApp(
       
       title:"Mobility corner app",
       theme: ThemeData(
        primarySwatch: Colors.purple,
       )
        
       
        
        );
    }
  }