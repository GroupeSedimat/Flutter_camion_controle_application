// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/UserManagementPage.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:get/get.dart';

class AdminPage extends StatelessWidget {
  final UserRole userRole;

  const AdminPage({Key? key, required this.userRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page d\'administration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue sur la page du super administrateur',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
             Get.to(() => CheckList());
              },
              child: Text('Aller dans checklist'),
            ),
            if (userRole == UserRole.superadmin)
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                    Get.to(() => UserManagementPage());
                },
                child: Text('Gestion des utilisateurs'),
              ),
            //SizedBox(height: 20),
            //ElevatedButton(
              //onPressed: () {
                //Navigator.pop(context);
              //},
              //child: Text('Retour'),
           // ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AuthController.instance.logOut();
              },
              child: Text('Déconnexion'),
            ),
          ],
        ),
      ),
    );
  }
}
