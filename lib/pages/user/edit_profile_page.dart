// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_controller.dart';

class ModifyProfilePage extends StatefulWidget {
  @override
  _ModifyProfilePageState createState() => _ModifyProfilePageState();
}

class _ModifyProfilePageState extends State<ModifyProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  //DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le profil'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Nouveau nom d\'utilisateur',
              ),
            ),
            /*SizedBox(height: 20),
            TextFormField(
              controller: dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Nouvelle date de naissance',
              ),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                    dobController.text = picked.toString();
                  });
                }
              },
            ),*/
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Nouvelle adresse e-mail',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Appeler une fonction dans AuthController pour mettre à jour le profil
                AuthController.instance.updateProfile(
                  usernameController.text.trim(),
                  dobController.text.trim(),
                  emailController.text.trim(),
                );
              },
              child: Text('Enregistrer les modifications'),
            ),
          ],
        ),
      ),
    );
  }
}
