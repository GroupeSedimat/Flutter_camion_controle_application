// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, duplicate_ignore

import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ignore: prefer_const_constructors
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
                // Ajoutez ici les actions que les administrateurs peuvent effectuer
                // Par exemple, vous pouvez implémenter des fonctionnalités pour gérer les utilisateurs, afficher des statistiques, etc.
              },
              child: Text('Effectuer une action'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Retournez à l'écran précédent (peut-être l'écran d'accueil)
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
