import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_user_tile.dart';
import 'package:flutter_application_1/services/user_service.dart';

class CompanyTile extends StatelessWidget {
  final Reference companyRef;
  final String companyName;

  CompanyTile({required this.companyRef, required this.companyName});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _testShow(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text(companyName),
            subtitle: Text("Checking permissions..."),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text(companyName),
            subtitle: Text("Error: ${snapshot.error}"),
          );
        } else if (snapshot.hasData && snapshot.data!) {
          return FutureBuilder<ListResult>(
            future: companyRef.listAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  title: Text(companyName),
                  subtitle: Text("Loading users..."),
                );
              } else if (snapshot.hasError) {
                return ListTile(
                  title: Text(companyName),
                  subtitle: Text("Error: ${snapshot.error}"),
                );
              } else if (snapshot.hasData) {
                final userList = snapshot.data!.prefixes;
                return ExpansionTile(
                  title: Text(companyName),
                  children: userList.map((userRef) {
                    return UserTile(userRef: userRef);
                  }).toList(),
                );
              } else {
                return ListTile(
                  title: Text(companyName),
                  subtitle: Text("No users available"),
                );
              }
            },
          );
        } else {
          // Return an empty Container to hide the widget
          return Container();
        }
      },
    );
  }

  Future<bool> _testShow() async {
    UserService userService = UserService();
    MyUser user = await userService.getCurrentUserData();
    if (user.role == 'superadmin' || (user.role == 'admin' && user.company == companyRef.name)) {
      return true;
    } else {
      return false;
    }
  }
}