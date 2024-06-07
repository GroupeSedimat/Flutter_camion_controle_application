// ignore_for_file: use_super_parameters, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/UserApprovalPage.dart';
import 'package:flutter_application_1/pages/admin/UserManagementPage.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:flutter_application_1/pages/welcome_page.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue sur la page du super administrateur',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Get.to(() => WelcomePage());
              },
              child: Text('Aller dans la welcome page'),
            ),
            SizedBox(height: 20),
            if (userRole == UserRole.superadmin) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CardButton(
                      title: 'Gestion des utilisateurs',
                      onPressed: () {
                        Get.to(() => UserManagementPage());
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: CardButton(
                      title: 'Approuver un compte',
                      onPressed: () {
                        Get.to(() => UserApprovalPage());
                      },
                    ),
                  ),
                ],
              ),
            ],
            Spacer(),
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

class CardButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const CardButton({
    Key? key,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              title,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
