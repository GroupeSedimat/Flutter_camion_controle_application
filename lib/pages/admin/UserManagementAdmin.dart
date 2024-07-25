// ignore_for_file: use_key_in_widget_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/UserDetailsPage.dart';
import 'package:flutter_application_1/pages/admin/UserEditPage.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/models/user/my_user.dart';

class UserManagementAdmin extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(authController.getCurrentUserUID())
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Gestion des utilisateurs'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        var currentUserData = snapshot.data!.data() as Map<String, Object?>;
        var currentUserCompany = currentUserData['company'];

        return Scaffold(
          appBar: AppBar(
            title: Text('Gestion des utilisateurs'),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('company', isEqualTo: currentUserCompany)
                .where('role', isNotEqualTo: 'superadmin')
                .snapshots(),
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
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 3,
                    child: ListTile(
                      title: Text(user.username),
                      subtitle: Text(user.email),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert),
                        onSelected: (String value) {
                          switch (value) {
                            case 'view':
                              Get.to(() => UserDetailsPage(user: user, ));
                              break;
                            case 'edit':
                              Get.to(() => UserEditPage(user: user));
                              break;
                            case 'reset_password':
                              _resetPassword(user.email);
                              break;
                            case 'delete':
                              _deleteUser(context, user.username);
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility),
                                  SizedBox(width: 8),
                                  Text('Voir les détails'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Modifier'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'reset_password',
                              child: Row(
                                children: [
                                  Icon(Icons.lock),
                                  SizedBox(width: 8),
                                  Text('Réinitialiser le mot de passe'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete),
                                  SizedBox(width: 8),
                                  Text('Supprimer'),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _deleteUser(BuildContext context, String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer la suppression"),
          content: Text("Êtes-vous sûr de vouloir supprimer cet utilisateur ?"),
          actions: [
            TextButton(
              child: Text("Non"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Oui"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUserConfirmed(username);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteUserConfirmed(String username) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (userDoc.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.docs[0].id)
            .delete();
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
      Get.snackbar(
        "Réinitialisation du mot de passe",
        "Un email de réinitialisation a été envoyé.",
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );
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
