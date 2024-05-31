import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/menu.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/user_service.dart';

class BasePage extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  BasePage({super.key, required this.body, this.appBar});


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.purple[99],
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
      drawer: FutureBuilder<MyUser>(
        future: UserService().getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final MyUser userData = snapshot.data!;
            return MenuWidget(username: userData.username, role: userData.role);
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
      body: body,
    );
  }
}