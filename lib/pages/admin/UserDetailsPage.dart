// ignore_for_file: file_names, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_constructors_in_immutables, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';

class UserDetailsPage extends StatelessWidget {
  final MyUser user;

  UserDetailsPage({required this.user});

  @override
  Widget build(BuildContext context) {
    print('Détails de l\'utilisateur: ${user.toJson()}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'utilisateur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nom d\'utilisateur:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(user.username),
            SizedBox(height: 16),
            Text(
              'Email:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(user.email), 
            SizedBox(height: 16),
            Text(
              'Nom:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(user.name),
            SizedBox(height: 16),
            Text(
              'Prenom:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(user.firstname),
            SizedBox(height: 16),
            Text(
              'Role:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(user.role),
           
          ],
        ),
      ),
    );
  }
}
