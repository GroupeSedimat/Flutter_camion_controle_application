// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/admin/UserManagementPage.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/checklist/loading_vrm.dart';
import 'package:flutter_application_1/pages/welcome_page.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/pages/user/edit_profile_page.dart';
import 'package:flutter_application_1/pages/user/reset_password_page.dart';

class MenuWidget extends StatelessWidget {
  String username = "";
  String role = "";
  MenuWidget({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<MyUser>(
    future: UserService().getCurrentUserData(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      } else if (snapshot.hasData) {
        final MyUser userData = snapshot.data!;
        username = userData.username;
        role = userData.role;
        return Drawer(
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
      } else {
        return const Center(child: Text("No data available"));
      }
    },
  );



  Widget buildHeader(BuildContext context) => Material(
    //menu head background color
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
              username,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.black,
              ),
            ),
            Text(
              'Role: $role',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
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
        leading: const Icon(Icons.data_exploration, color: Colors.purple),
        title: const Text('Get datas'),
        onTap: () {
          Navigator.pop(context);
          Get.to(() => const LoadingData());  // Pousser une nouvelle route vers la page de réinitialisation de mot de passe
        },
      ),
      ListTile(
        leading: const Icon(Icons.view_list, color: Colors.purple),
        title: const Text('Go to checklist'),
        onTap: () {
          Navigator.pop(context);
          Get.to(() => const CheckList());  // Pousser une nouvelle route vers la page de réinitialisation de mot de passe
        },
      ),
      if (role == 'admin') // Condition pour afficher uniquement si l'utilisateur est un administrateur
        ListTile(
          leading: const Icon(Icons.edit, color: Colors.purple),
          title: const Text('Gestion des utilisateurs'),
          onTap: () {
            Navigator.pop(context);
            Get.to(() => UserManagementPage());  // Pousser une nouvelle route vers la page de gestion des utilisateurs
          },
        ),
    ],
  );
}
