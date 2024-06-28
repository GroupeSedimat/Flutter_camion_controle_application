import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/pdf/pdf_download.dart';
import 'package:flutter_application_1/pages/pdf/pdf_view.dart';
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
  late Future<Company> companyFuture; // zmieniono

  @override
  void initState() {
    super.initState();
    companyFuture = DatabaseCompanyService().getCompanyByID(widget.userData.company); // zmieniono
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

        return Card(
          margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          color: Colors.grey[800],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "User ${widget.userData.username}",
                  style: const TextStyle(
                    fontSize: 22.0,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "Company ${company.name}", // zmieniono
                  style: const TextStyle(
                    fontSize: 22.0,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "Creation date: $formattedDate",
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFViewerPage(url: widget.url),
                          ),
                        );
                      },
                      label: const Text('Open PDF'),
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        PdfDownload(
                            name: "${widget.userData.username}.${widget.fileName}",
                            url: widget.url)
                            .downloadFile(); // zmieniono
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
                      label: const Text('Download PDF'),
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
