import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/menu.dart';
import 'package:flutter_application_1/services/auth_controller.dart';

class BasePage extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final String username;
  final String role;

  BasePage({super.key, required this.body, this.appBar, required this.username, required this.role});


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: appBar ?? AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              AuthController.instance.logOut();
              Navigator.pushReplacementNamed(context, '/wrapper');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      drawer: MenuWidget(username: username, role: role,),
      body: body,
    );
  }
}