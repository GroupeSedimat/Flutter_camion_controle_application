import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/pdf/pdf_download.dart';
import 'package:flutter_application_1/pages/pdf/pdf_view.dart';
import 'package:intl/intl.dart';

class PDFShowTemplate extends StatelessWidget {
  final String fileName;
  final String url;
  final MyUser userData;
  const PDFShowTemplate({super.key, required this.fileName, required this.url, required this.userData});

  @override
  Widget build(BuildContext context) {
    int timestamp = int.parse(fileName);
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
    return Card(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "User ${userData.username}",
              style: const TextStyle(
                fontSize: 22.0,
                color: Colors.amber ,
              ),
            ),
            const SizedBox(height: 8.0,),
            Text(
              "Company ${userData.company}",
              style: const TextStyle(
                fontSize: 22.0,
                color: Colors.amber ,
              ),
            ),
            const SizedBox(height: 8.0,),
            Text(
              "Creation date: $formattedDate",
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8.0,),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFViewerPage(url: url),
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
                    PdfDownload(name: "${userData.username}.$fileName", url: url).downloadFile();
                    showDialog(context: context, builder: (context)=>AlertDialog(
                      title: const Text('PDF downloaded'),
                      content: Text('Your PDF file has been saved under the name: ${userData.username}.$fileName.pdf'),
                      actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Ok'))],
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
  }
}
