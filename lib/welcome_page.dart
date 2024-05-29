// ignore_for_file: prefer_const_constructors, use_super_parameters, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_application_1/user_role.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import 'edit_profile_page.dart';
import 'reset_password_page.dart'; 

class WelcomePage extends StatelessWidget {
  final String username;
  final String role;

  const WelcomePage({Key? key, required this.username, required this.role}) : super(key: key);

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
              child: Icon(
                Icons.settings,
                size: 80,
                color: Colors.grey,
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.purple),
              title: Text('Modifier vos informations'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => ModifyProfilePage());
              },
            ),
            ListTile(
              leading: Icon(Icons.mail, color: Colors.purple),
              title: Text('Messagerie'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.purple),
              title: Text('Accéder au shop'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.purple),
              title: Text('Modifier mot de passe'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => ResetPasswordPage());
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: w,
              height: h * 0.3,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/image2.webp"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: h * 0.12),
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: AssetImage("assets/images/836.jpg"),
                  ),
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