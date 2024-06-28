import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/pdf/pdf_download.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerPage extends StatefulWidget {
  final String url;

  PDFViewerPage({required this.url});

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String localPath = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    downloadFile();
  }

  Future<void> downloadFile() async {

    try {
      PdfDownload pdfDownload = PdfDownload(name: "temp", url: widget.url);
      await pdfDownload.downloadFile();
      setState(() {
        localPath = pdfDownload.localPath;
        isLoading = false;
      });
    } catch (e) {
      print("Error downloading file: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF Viewer")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : localPath.isNotEmpty
          ? PDFView(
        filePath: localPath,
      )
          : Center(child: Text("Error loading PDF")),
    );
  }
}