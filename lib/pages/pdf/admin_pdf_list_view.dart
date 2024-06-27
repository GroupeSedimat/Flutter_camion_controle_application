import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_company_tile.dart';
import 'package:flutter_application_1/services/pdf/database_pdf_service.dart';

class AdminPdfListView extends StatelessWidget {
  final Reference _fireReference = DatabasePDFService().firePdfReference();

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
            return ListView(
              children: companyList.map((companyRef) {
                return CompanyTile(companyRef: companyRef);
              }).toList(),
            );
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
    );
  }
}