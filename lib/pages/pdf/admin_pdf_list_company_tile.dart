import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_user_tile.dart';

/// une classe qui affiche une liste d'utilisateurs d'une entreprise donnée
class CompanyTile extends StatefulWidget {
  final String companyName;
  final Map<MyUser, Map<String, String>> companyUsersAndPdf;

  CompanyTile({required this.companyName, required this.companyUsersAndPdf});

  @override
  State<CompanyTile> createState() => _CompanyTileState();
}

class _CompanyTileState extends State<CompanyTile> {

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      // childrenPadding: EdgeInsets.all(15),
      title: Text(widget.companyName, textAlign: TextAlign.center),
      backgroundColor: Colors.lightGreen,
      collapsedBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
      children: widget.companyUsersAndPdf.entries.map((userData) {
        /// affichage d'une liste d'utilisateurs à l'aide de la classe UserTile
        return UserTile(user: userData.key ,userData: userData.value);
      }).toList(),
    );
  }
}