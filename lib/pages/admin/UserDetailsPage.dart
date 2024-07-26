// ignore_for_file: file_names, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_constructors_in_immutables, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/services/database_company_service.dart';

class UserDetailsPage extends StatelessWidget {
  final MyUser user;
  final DatabaseCompanyService companyService = DatabaseCompanyService();

  UserDetailsPage({required this.user});

  Future<String> getCompanyName(String companyId) async {
    var company = await companyService.getCompanyByID(companyId);
    return company.name;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Détails de l\'utilisateur',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nom d\'utilisateur:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(user.username),
            SizedBox(height: 16),
            Text(
              'Email:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(user.email),
            SizedBox(height: 16),
            Text(
              'Nom:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(user.name),
            SizedBox(height: 16),
            Text(
              'Prenom:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(user.firstname),
            SizedBox(height: 16),
            Text(
              'Role:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(user.role),
            SizedBox(height: 16),
            Text(
              'Compagnie:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            FutureBuilder<String>(
              future: getCompanyName(user.company),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Nom de compagnie non trouvé');
                } else {
                  return Text(snapshot.data!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
