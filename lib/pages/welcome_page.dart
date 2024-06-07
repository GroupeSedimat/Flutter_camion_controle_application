// ignore_for_file: prefer_const_constructors, use_super_parameters, prefer_const_constructors_in_immutables, sort_child_properties_last
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/menu.dart';
import 'package:flutter_application_1/pages/admin/UserManagementPage.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/user_service.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.purple[99],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: FutureBuilder<MyUser?>(
        future: UserService().getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Drawer(
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Drawer(
              child: Center(child: Text("Error: ${snapshot.error}")),
            );
          } else if (snapshot.hasData) {
            final MyUser? userData = snapshot.data;
            if (userData == null) {
              return Drawer(
                child: Center(child: Text("No user data found")),
              );
            }
            return MenuWidget(username: userData.username, role: userData.role);
          } else {
            return Drawer(
              child: Center(child: Text("No data available")),
            );
          }
        },
      ),
      body: FutureBuilder<MyUser?>(
        future: UserService().getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final MyUser? userData = snapshot.data;
            if (userData == null) {
              return Center(child: Text("No user data found"));
            }

            String welcomeMessage = userData.role == 'admin'
                ? 'Bienvenue sur la page admin, ${userData.username}!'
                : 'Bienvenue sur votre profil, ${userData.username}!';
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: w,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/image2.webp"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: h * 0.05),
                        CircleAvatar(
                          radius: 100,
                          backgroundImage: AssetImage("assets/images/836.jpg"),
                        ),
                        SizedBox(height: h * 0.05),
                      ],
                    ),
                  ),
                  SizedBox(height: 65),
                  Text(
                    welcomeMessage,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    userData.username,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.purple[300],
                    ),
                  ),
                  SizedBox(height: 200),
                  Container(
                    width: w * 0.3,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: DecorationImage(
                        image: AssetImage("assets/images/purple-wallpaper.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/loadingdata');
                      },
                      label: const Text('Go to data'),
                      icon: const Icon(Icons.bar_chart),
                    ),
                  ),
                  SizedBox(height: 200),
                  GestureDetector(
                    onTap: () {
                      AuthController.instance.logOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vous avez été déconnecté'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Container(
                      width: w * 0.3,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: DecorationImage(
                          image: AssetImage("assets/images/purple-wallpaper.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Se déconnecter",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                ],
              ),
            );
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
    );
  }
}