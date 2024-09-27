
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/admin/UserEditPage.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/pages/admin/UserDetailsPage.dart';
import 'package:flutter_application_1/services/database_company_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

class UserManagementPage extends StatelessWidget {
  final AuthController authController = Get.find();
  final DatabaseCompanyService companyService = DatabaseCompanyService();

  Future<Map<String, String>> getCompanyNames() async {
    return await companyService.getAllCompaniesNames();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: AppLocalizations.of(context)!.manageUsers,
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

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        company,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      children: companyUsers.map((user) {
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor:  Theme.of(context).primaryColor,
                              child: Text(
                                user.username[0],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              user.username,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                                        Icon(Icons.visibility, color: Colors.blueAccent),
                                        SizedBox(width: 8),
                                        Text(AppLocalizations.of(context)!.details),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text(AppLocalizations.of(context)!.edit),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'reset_password',
                                    child: Row(
                                      children: [
                                        Icon(Icons.lock, color: Colors.purple),
                                        SizedBox(width: 8),
                                        Text(AppLocalizations.of(context)!.passReset),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text(AppLocalizations.of(context)!.delete),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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
          title: Text(AppLocalizations.of(context)!.confirmDelete),
          content: Text(AppLocalizations.of(context)!.confirmDeleteText),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.no),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yes),
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
          "User deleted",
          "User has been deleted successfully.",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Error!",
          "User not found.",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error while deleting",
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
        "Error while resetting",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}