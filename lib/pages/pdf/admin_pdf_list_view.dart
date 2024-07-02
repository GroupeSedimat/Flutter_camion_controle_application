// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_company_tile.dart';
import 'package:flutter_application_1/services/database_company_service.dart';
import 'package:flutter_application_1/services/pdf/database_pdf_service.dart';

class AdminPdfListView extends StatelessWidget {
  final Reference _fireReference = DatabasePDFService().firePdfReference();
  final DatabaseCompanyService _databaseCompanyService = DatabaseCompanyService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Documents")),
      body: FutureBuilder<ListResult>(
        future: _fireReference.listAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final companyList = snapshot.data!.prefixes;
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
            return Center(child: Text("No data available"));
          }
        },
      ),
    );
  }
}