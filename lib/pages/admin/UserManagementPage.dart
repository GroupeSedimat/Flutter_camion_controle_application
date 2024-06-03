// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unused_element, file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/pages/admin/UserEditPage.dart';
import 'package:flutter_application_1/models/user/my_user.dart';

class UserManagementPage extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des utilisateurs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var users = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, Object?>;
            return MyUser.fromJson(data);
          }).toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                title: Text(user.username),
                //subtitle: Text(user.email),
                trailing: PopupMenuButton<String>(
                  onSelected: (String value) {
                    switch (value) {
                      case 'edit':
                        Get.to(() => UserEditPage(user: user));
                        break;
                      case 'reset_password':
                        //_resetPassword(user.email);
                        break;
                      case 'delete':
                        //_deleteUser(user.email);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Modifier'),
                      ),
                      PopupMenuItem(
                        value: 'reset_password',
                        child: Text('Réinitialiser le mot de passe'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Supprimer'),
                      ),
                    ];
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteUser(String email) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(userDoc.docs[0].id).delete();
        Get.snackbar(
          "Utilisateur supprimé",
          "L'utilisateur a été supprimé avec succès.",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Erreur",
          "Utilisateur non trouvé.",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Erreur lors de la suppression",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _resetPassword(String email) async {
    try {
      await authController.resetPassword(email);
    } catch (e) {
      Get.snackbar(
        "Erreur lors de la réinitialisation",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}