// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';
import 'user_role.dart';
//admin page pour le test
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
                
              },
              child: Text('Effectuer une action'),
            ),
            if (userRole == UserRole.admin) 
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  
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
          ],
        ),
      ),
    );
  }
}
