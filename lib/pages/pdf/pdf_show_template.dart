// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/pdf/pdf_download.dart';
import 'package:flutter_application_1/pages/pdf/pdf_open.dart';
import 'package:flutter_application_1/services/database_company_service.dart';
import 'package:intl/intl.dart';

class PDFShowTemplate extends StatefulWidget {
  final String fileName;
  final String url;
  final MyUser userData;

  PDFShowTemplate({super.key, required this.fileName, required this.url, required this.userData});

  @override
  State<PDFShowTemplate> createState() => _PDFShowTemplateState();
}

class _PDFShowTemplateState extends State<PDFShowTemplate> {
  late Future<Company> companyFuture;

  @override
  void initState() {
    super.initState();
    companyFuture = DatabaseCompanyService().getCompanyByID(widget.userData.company);
  }
  @override
  Widget build(BuildContext context) {
    int timestamp = int.parse(widget.fileName);
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(date);

    return FutureBuilder<Company>(
      future: companyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('Company not found'));
        }

        Company company = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.deepPurple, size: 50),
                    title: Text(
                      "User: ${widget.userData.username}",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    subtitle: Text(
                      "Company: ${company.name}",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    "Creation date: $formattedDate",
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            PDFOpen open = PDFOpen(url: widget.url);
                            open.openPDF();
                          },
                          icon: Icon(Icons.picture_as_pdf),
                          label: Text('Open PDF'),
                        ),
                      ),
                      SizedBox(width: 10), 
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            PdfDownload(
                                name: "${widget.userData.username}.${widget.fileName}",
                                url: widget.url)
                                .downloadFile();
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('PDF downloaded'),
                                  content: Text(
                                      'Your PDF file has been saved under the name: ${widget.userData.username}.${widget.fileName}.pdf'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Ok'))
                                  ],
                                ));
                          },
                          icon: Icon(Icons.download),
                          label: Text('Download PDF'),
                        ),
                      ),
                    ],
                  )


                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
