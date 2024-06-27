import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_user_tile.dart';

class CompanyTile extends StatelessWidget {
  final Reference companyRef;

  CompanyTile({required this.companyRef});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ListResult>(
      future: companyRef.listAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text(companyRef.name),
            subtitle: Text("Loading users..."),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text(companyRef.name),
            subtitle: Text("Error: ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          final userList = snapshot.data!.prefixes;
          return ExpansionTile(
            title: Text(companyRef.name),
            children: userList.map((userRef) {
              return UserTile(userRef: userRef);
            }).toList(),
          );
        } else {
          return ListTile(
            title: Text(companyRef.name),
            subtitle: Text("No users available"),
          );
        }
      },
    );
  }
}