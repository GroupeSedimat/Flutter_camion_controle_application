// ignore_for_file: prefer_const_constructors, use_super_parameters

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import 'edit_profile_page.dart';
import 'reset_password_page.dart'; 

class WelcomePage extends StatelessWidget {
  final String username;

  const WelcomePage({Key? key, required this.username}) : super(key: key);

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
              /**   ListTile(
              leading: Icon(Icons.slideshow, color: Colors.purple), 
              title: Text('Voir mes informations'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => ProfileInfoPage(
                  username: 'NomUtilisateur',
                  dob: 'DateDeNaissance',
                  email: 'adresse@example.com',
                ));
              },
             ), */
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
              //Get.to(() => ModifyProfilePage());  // Pousser une nouvelle route vers la page de réinitialisation de mot de passe
              },
            ),
             ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.purple),
              title: Text('Accéder au shop'),
              onTap: () {
                Navigator.pop(context);
              //Get.to(() => ModifyProfilePage());  // Pousser une nouvelle route vers la page de réinitialisation de mot de passe
              },
            ),
            
            ListTile(
              leading: Icon(Icons.lock, color: Colors.purple),
              title: Text('Modifier mot de passe'),
              onTap: () {
                Navigator.pop(context);
              Get.to(() => ResetPasswordPage());  // Pousser une nouvelle route vers la page de réinitialisation de mot de passe
              },
            ),
            
            // Autres options de menu
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
              "Bienvenue sur votre profil",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
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
          ],
        ),
      ),
    );
  }
}
