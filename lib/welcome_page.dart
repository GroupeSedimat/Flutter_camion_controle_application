// ignore_for_file: prefer_const_constructors, use_super_parameters

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/menu.dart';
import 'package:flutter_application_1/auth_controller.dart';

class WelcomePage extends StatelessWidget {
  final String username = AuthController().getUserName();
  final String role = AuthController().getRole();

  WelcomePage({Key? key}) : super(key: key);
  // WelcomePage({Key? key, required this.username, required this.role}) : super(key: key);
  final User? user = AuthController().auth.currentUser;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;  
    double h = MediaQuery.of(context).size.height;

    String welcomeMessage = role == 'admin'
        ? 'Bienvenue sur la page admin, $username!'
        : 'Bienvenue sur votre profil, $username!';

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
      drawer: MenuWidget(username: username),
      body: SingleChildScrollView(
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
              username,
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
                // onPressed: () => {
                //   Navigator.pop(context),
                //   Get.to(() => LoadingData())
                // },
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
            SizedBox(height: 200),
            if (role == 'admin')
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
                      "Test",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            if (role != 'admin')
              ElevatedButton(
                onPressed: null, // Disabled state
                child: Text(
                  "Test",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, // Disabled color
                ),
              ),
          ],
        ),
      ),
    );
  }
}
