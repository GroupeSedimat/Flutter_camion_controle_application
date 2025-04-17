import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/pdf/pdf_download.dart';
import 'package:flutter_application_1/pages/pdf/pdf_open.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class PDFShowTemplate extends StatefulWidget {
  final String fileName;
  final String url;
  final MyUser user;

  PDFShowTemplate(
      {super.key,
      required this.fileName,
      required this.url,
      required this.user});

  @override
  State<PDFShowTemplate> createState() => _PDFShowTemplateState();
}

class _PDFShowTemplateState extends State<PDFShowTemplate> {
  @override
  Widget build(BuildContext context) {
    int timestamp = int.parse(widget.fileName);
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(date);

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
                leading: Icon(Icons.person,
                    color: Theme.of(context).primaryColor, size: 50),
                title: Text(
                  "User: ${widget.user.username}",
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                // subtitle: Text(
                //   AppLocalizations.of(context)!.companyWithName(_company.name),
                //   style: TextStyle(
                //     fontSize: 18.0,
                //     color: Colors.grey[700],
                //   ),
                // ),
              ),
              const SizedBox(height: 16.0),
              Text(
                AppLocalizations.of(context)!.dateCreation(formattedDate),
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
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        PDFOpen open = PDFOpen(url: widget.url);
                        open.openPDF();
                      },
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text(AppLocalizations.of(context)!.open),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        await PdfDownload(
                                name:
                                    "${widget.user.username}.${widget.fileName}",
                                url: widget.url)
                            .downloadFile();
                        await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text(
                                      AppLocalizations.of(context)!.download),
                                  content: Text(AppLocalizations.of(context)!
                                      .pdfDownloaded(widget.user.username,
                                          widget.fileName)),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                            AppLocalizations.of(context)!.ok))
                                  ],
                                ));
                      },
                      icon: Icon(Icons.download),
                      label: Text(AppLocalizations.of(context)!.download),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
