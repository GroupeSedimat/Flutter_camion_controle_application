// ignore_for_file: prefer_const_constructors, use_super_parameters
import 'package:flutter/material.dart';
import 'auth_controller.dart';

class WelcomePage extends StatelessWidget {
  final String email;
  const WelcomePage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.purple[99],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Ouvrir le menu hamburger
            Scaffold.of(context).openDrawer();
          },
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
              child: Text(
                'Paramètres',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Modifier le profil'),
              onTap: () {
                // Implémentez l'action à effectuer lors du clic sur "Modifier le profil"
                Navigator.pop(context); // Fermer le menu
                // Naviguer vers l'écran de modification du profil
              },
            ),
            ListTile(
              title: Text('Modifier le mot de passe'),
              onTap: () {
                // Implémentez l'action à effectuer lors du clic sur "Modifier le mot de passe"
                Navigator.pop(context); // Fermer le menu
                // Naviguer vers l'écran de modification du mot de passe
              },
            ),
            // Ajoutez d'autres options de menu selon vos besoins
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
              email,
              style: TextStyle(
                fontSize: 18,
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
        backgroundColor: Colors.green, // Couleur du SnackBar
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
