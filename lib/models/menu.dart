import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/checklist/loading_vrm.dart';
import 'package:flutter_application_1/welcome_page.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/auth_controller.dart';
import 'package:flutter_application_1/edit_profile_page.dart';
import 'package:flutter_application_1/reset_password_page.dart';

class MenuWidget extends StatelessWidget {
  User? user;
  MenuWidget({super.key, this.user});

  @override
  Widget build(BuildContext context) => Drawer(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget> [
          buildHeader(context),
          buildMenuItems(context),
        ],
      ),
    ),
  );

  Widget buildHeader(BuildContext context) => Material(
    color: Colors.purple,
    child: InkWell(
      onTap: () {
        Navigator.pop(context);
        Get.to(() => WelcomePage());
      },
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: 24,
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage("assets/images/836.jpg"),
            ),
            const SizedBox(height: 12),
            Text(
              "${user?.email}",
              style: const TextStyle(
                  fontSize: 28,
                  color: Colors.black
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget buildMenuItems(BuildContext context) => Wrap(
    runSpacing: 16, // vertical spacing
    children: [
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
        leading: const Icon(Icons.edit, color: Colors.purple),
        title: const Text('Modifier vos informations'),
        onTap: () {
          Navigator.pop(context);
          Get.to(() => ModifyProfilePage());
        },
      ),
      ListTile(
        leading: const Icon(Icons.mail, color: Colors.purple),
        title: const Text('Messagerie'),
        onTap: () {
          Navigator.pop(context);
          //Get.to(() => ModifyProfilePage());  // Pousser une nouvelle route vers la page de réinitialisation de mot de passe
        },
      ),
      ListTile(
        leading: const Icon(Icons.shopping_cart, color: Colors.purple),
        title: const Text('Accéder au shop'),
        onTap: () {
          Navigator.pop(context);
          //Get.to(() => ModifyProfilePage());  // Pousser une nouvelle route vers la page de réinitialisation de mot de passe
        },
      ),

      ListTile(
        leading: const Icon(Icons.lock, color: Colors.purple),
        title: const Text('Modifier mot de passe'),
        onTap: () {
          Navigator.pop(context);
          Get.to(() => ResetPasswordPage());  // Pousser une nouvelle route vers la page de réinitialisation de mot de passe
        },
      ),

      const Divider(color: Colors.purple),

      ListTile(
        leading: const Icon(Icons.lock, color: Colors.purple),
        title: const Text('Get datas'),
        onTap: () {
          Navigator.pop(context);
          Get.to(() => const LoadingData());  // Pousser une nouvelle route vers la page de réinitialisation de mot de passe
        },
      ),
    ]
  );
}