import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/pdf/pdf_show_template.dart';
import 'package:flutter_application_1/services/pdf/database_pdf_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PDFShowList extends StatefulWidget {
  const PDFShowList({super.key});

  @override
  State<PDFShowList> createState() => _PDFShowListState();
}

class _PDFShowListState extends State<PDFShowList> {

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: AppLocalizations.of(context)!.pdfMyFiles,
      body: body(context),
    );
  }

  Widget body(BuildContext context) {
    DatabasePDFService databasePDFService = DatabasePDFService();
    return FutureBuilder<MyUser>(
        future: UserService().getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final MyUser userData = snapshot.data!;
            return FutureBuilder<Map<String, String>>(
                future: databasePDFService.getUserListOfPDF(userData.company),
                builder: (context, pdfSnapshot) {
                  if (pdfSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (pdfSnapshot.hasError) {
                    return Center(child: Text("Error: ${pdfSnapshot.error}"));
                  } else if (pdfSnapshot.hasData) {
                    final Map<String, String> pdfList = pdfSnapshot.data!;
                    Map<String,String> sortedPdf = HashMap();
                    sortedPdf = Map.fromEntries(pdfList.entries.toList()..sort(
                            (e1, e2) => (e2.value).compareTo(e1.value))
                    );
                    return ListView.builder(
                      itemCount: sortedPdf.length,
                      padding: const EdgeInsets.all(16.0),
                      itemBuilder: (BuildContext context, int index){
                        final entry = sortedPdf.entries.toList()[index];
                        final fileName = entry.key;
                        final url = entry.value;
                        return PDFShowTemplate(fileName: fileName, url: url, userData: userData,);
                      },
                    );
                  } else {
                    return Center(child: Text("No data available"));
                  }
                }
            );
          } else {
            return Center(child: Text("No data available"));
          }
        }
    );
  }
}
