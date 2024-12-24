import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/menu.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class BasePage extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final String? title;
  const BasePage({super.key, required this.body, this.appBar, this.title});


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: appBar ?? AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
            title ?? "",
            style: TextStyle(
              color: Colors.black,
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