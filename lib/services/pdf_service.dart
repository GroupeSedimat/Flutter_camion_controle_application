import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_pdf_service.dart';
import 'package:open_document/open_document.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  DatabasePDFService databasePDFService = DatabasePDFService();
  AuthController authController = AuthController.instance;

  Future<pw.Font> loadFont() async {
    final fontData = await rootBundle.load("assets/fonts/roboto/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    return ttf;
  }

  // Future<Uint8List> createInvoice(Future<Map<String, TaskChecklist>> validatedTask) {
  Future<Uint8List> createInvoice() async {
    final pdf = pw.Document();
    final font = await loadFont();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context){
          return pw.Center (
            child: pw.Text("Hello", style: pw.TextStyle(font: font)),
          );
        }
      )
    );
    return pdf.save();
  }

  Future<void> savePdfFile(String company, Uint8List data) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    String? userID = authController.getCurrentUserUID();
    String fileName = "$company/$userID/${time.toString()}";
    String documentsPath = "/storage/emulated/0/Documents";
    String filePath = "$documentsPath/$fileName.pdf";

    final directory = Directory("$documentsPath/$company/$userID");
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
    // Map<String, String> list1 = await databasePDFService.getCompanyListOfPDF(company);

    final file = File(filePath);
    await file.writeAsBytes(data);

    await databasePDFService.addPdfToFirebase(filePath, fileName);
    // Map<String, String> pdfList = await databasePDFService.getCompanyListOfPDF(company);
    // pdfList.forEach((fileName, url) {
    //   print("File Name: $fileName, Download URL: $url");
    // });
    await OpenDocument.openDocument(filePath: filePath);
  }


}