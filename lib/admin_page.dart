// ignore_for_file: use_super_parameters, prefer_const_constructors

/*import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth_controller.dart';
import 'user_role.dart';

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
              'Bienvenue sur la page d\'administration !',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action
              },
              child: Text('Effectuer une action'),
            ),
            if (userRole == UserRole.admin)
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Admin specific action
                },
                child: Text('Action spécifique aux administrateurs'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Retour'),
            ),
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
}*/
