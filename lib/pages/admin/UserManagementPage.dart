// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors, avoid_print, prefer_const_literals_to_create_immutables
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/admin/UserEditPage.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/pages/admin/UserDetailsPage.dart';
import 'package:flutter_application_1/services/database_company_service.dart';
import 'package:get/get.dart';

class UserManagementPage extends StatelessWidget {
  final AuthController authController = Get.find();
  final DatabaseCompanyService companyService = DatabaseCompanyService();

  Future<Map<String, String>> getCompanyNames() async {
    return await companyService.getAllCompaniesNames();
  }

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

         
          return FutureBuilder<Map<String, String>>(
            future: getCompanyNames(),
            builder: (context, companySnapshot) {
              if (!companySnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var companyNames = companySnapshot.data!;

              var usersByCompany = <String, List<MyUser>>{};
              for (var user in users) {
                var companyName = companyNames[user.company] ?? 'Unknown';
                if (usersByCompany[companyName] == null) {
                  usersByCompany[companyName] = [];
                }
                usersByCompany[companyName]!.add(user);
              }

              return ListView.builder(
                itemCount: usersByCompany.length,
                itemBuilder: (context, index) {
                  var company = usersByCompany.keys.elementAt(index);
                  var companyUsers = usersByCompany[company]!;

                  return ExpansionTile(
                    title: Text(company),
                    children: companyUsers.map((user) {
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
                                  Get.to(() => UserDetailsPage(user: user));
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
                    }).toList(),
                  );
                },
              );
            },
          );
        },
      ),
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
