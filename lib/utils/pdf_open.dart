import 'dart:io';

import 'package:flutter_application_1/utils/pdf_download.dart';
import 'package:open_document/open_document.dart';
import 'package:path_provider/path_provider.dart';

class PDFOpen {
  final String url;
  PDFOpen({required this.url});

  /// Télécharger et ouvrir le PDF à partir du URL
  Future<void> openPDF() async {
    Directory tempDir = await getApplicationSupportDirectory();
    print("openPDF ${tempDir.path}");
    String filePath = "${tempDir.path}/temp.pdf";

    /// Télécharger le PDF dans le répertoire temporaire
    PdfDownload pdfDownload = PdfDownload(name: "temp", url: url);
    await pdfDownload.downloadFile();

    /// Ouvrez le fichier PDF enregistré dans le répertoire temporaire
    await OpenDocument.openDocument(filePath: filePath);
  }
}