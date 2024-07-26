// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/menu.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class BasePage extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final String? title;
  BasePage({super.key, required this.body, this.appBar, this.title});


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: appBar ?? AppBar(
        backgroundColor: Colors.purple,
        title: Text(
            title ?? "",
            style: TextStyle(
              color: Colors.amber,
            ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.to(() => SettingsPage());
            },
          ),
        ],
      ),
      drawer: MenuWidget(),
      body: body,
    );
  }
}