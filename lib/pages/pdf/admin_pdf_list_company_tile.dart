import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_user_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompanyTile extends StatelessWidget {
  final Reference companyRef;
  final String companyName;

  CompanyTile({required this.companyRef, required this.companyName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ListResult>(
      future: companyRef.listAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text(companyName),
            subtitle: Text(AppLocalizations.of(context)!.userLoading),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text(companyName),
            subtitle: Text("Error: ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          final userList = snapshot.data!.prefixes;
          return ExpansionTile(
            // childrenPadding: EdgeInsets.all(15),
            title: Text(companyName, textAlign: TextAlign.center),
            backgroundColor: Colors.lightGreen,
            collapsedBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
            children: userList.map((userRef) {
              return UserTile(userRef: userRef);
            }).toList(),
          );
        } else {
          return ListTile(
            title: Text(companyName),
            subtitle: Text(AppLocalizations.of(context)!.userDataNotFound),
          );
        }
      },
    );
  }
}