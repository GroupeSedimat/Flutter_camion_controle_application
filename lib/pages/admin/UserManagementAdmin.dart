import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/UserDetailsPage.dart';
import 'package:flutter_application_1/pages/admin/UserEditPage.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserManagementAdmin extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final UserService userService = UserService();

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
              title: Text(AppLocalizations.of(context)!.manageUsers),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        var currentUserData = snapshot.data!.data() as Map<String, Object?>;
        var currentUserCompany = currentUserData['company'];
  
        return BasePage(
          title: AppLocalizations.of(context)!.manageUsers,
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('company', isEqualTo: currentUserCompany)
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
                              Get.to(() => UserDetailsPage(user: user));
                              break;
                            case 'edit':
                              Get.to(() => UserEditPage(user: user));
                              break;
                            case 'reset_password':
                              _resetPassword(user.email);
                              break;
                            case 'delete':
                              userService.confirmDeleteUser(context, user.username);
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
                                  Text(AppLocalizations.of(context)!.details),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text(AppLocalizations.of(context)!.edit),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'reset_password',
                              child: Row(
                                children: [
                                  Icon(Icons.lock),
                                  SizedBox(width: 8),
                                  Text(AppLocalizations.of(context)!.passReset),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete),
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
                },
              );
            },
          ),
        );
      },
    );
  }

  void _resetPassword(String email) async {
    try {
      await authController.resetPassword(email);
      Get.snackbar(
        "Password reset",
        "A reset email has been sent.",
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );
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
