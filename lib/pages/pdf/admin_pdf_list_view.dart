import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_company_tile.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_user_tile.dart';
import 'package:flutter_application_1/services/database_company_service.dart';
import 'package:flutter_application_1/services/pdf/database_pdf_service.dart';
import 'package:flutter_application_1/services/user_service.dart';

class AdminPdfListView extends StatelessWidget {
  final Reference _firePdfReference = DatabasePDFService().firePdfReference();
  final DatabaseCompanyService _databaseCompanyService = DatabaseCompanyService();
  late MyUser user;
  late Company company;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des fichiers PDF", textAlign: TextAlign.center),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<ListResult>(
        future: getCompanyPdfData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final companyList = snapshot.data!.prefixes;
            if (user.role == "superadmin") {
              return FutureBuilder<Map<String, Company>>(
                future: _databaseCompanyService.getAllCompanies(),
                builder: (context, companySnapshot) {
                  if (companySnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (companySnapshot.hasError) {
                    return Center(child: Text("Error: ${companySnapshot.error}"));
                  } else if (companySnapshot.hasData) {
                    final companies = companySnapshot.data!;
                    return ListView(
                      children: companyList.map((companyRef) {
                        return CompanyTile(
                          companyRef: companyRef,
                          companyName: companies[companyRef.name]?.name ?? companyRef.name,
                        );
                      }).toList(),
                    );
                  } else {
                    return Center(child: Text("No companies available"));
                  }
                },
              );
            } else {
              return
                ListView(
                  children: companyList.map((userRef) {
                    return UserTile(userRef: userRef);
                  }).toList(),
                );
            }
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
    );
  }

  Future<ListResult> getCompanyPdfData() async {
    UserService userService = UserService();
    user = await userService.getCurrentUserData();
    company = await _databaseCompanyService.getCompanyByID(user.company);
    if (user.role == 'superadmin') {
      return _firePdfReference.listAll();
    } else if (user.role == 'admin') {
      String company = user.company;
      return _firePdfReference.child(company).listAll();
    } else {
      return _firePdfReference.list();
    }
  }
}
