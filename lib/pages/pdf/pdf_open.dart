// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter_application_1/pages/pdf/pdf_download.dart';
import 'package:open_document/open_document.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PDFOpen {
  final String url;
  PDFOpen({required this.url});

  // Download and open PDF from URL path
  Future<void> openPDF() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String filePath = path.join(tempDir.path, "temp.pdf");

    // Download PDF to temporary directory
    PdfDownload pdfDownload = PdfDownload(name: "temp", url: url);
    await pdfDownload.downloadFile();

    // Open PDF in temporary directory
    await OpenDocument.openDocument(filePath: filePath);
  }
}