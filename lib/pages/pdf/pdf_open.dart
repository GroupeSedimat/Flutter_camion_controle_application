import 'package:flutter_application_1/pages/pdf/pdf_download.dart';
import 'package:open_document/open_document.dart';

class PDFOpen {
  final String url;
  String filePath = "/storage/emulated/0/Documents/temp.pdf";
  PDFOpen({required this.url});

  //download and open PDF from url path
  Future<void> openPDF() async {
    //download PDF to "/storage/emulated/0/Documents/temp.pdf"
    PdfDownload pdfDownload = PdfDownload(name: "temp", url: url);
    await pdfDownload.downloadFile();
    //Open PDF in "/storage/emulated/0/Documents/temp.pdf"
    await OpenDocument.openDocument(filePath: filePath);
  }
}