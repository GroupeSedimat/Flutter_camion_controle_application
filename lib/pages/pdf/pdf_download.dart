import 'package:dio/dio.dart';


class PdfDownload {
  String localPath = '';
  final String url;
  final String name;

  PdfDownload( {required this.name, required this.url});


  Future<void> downloadFile() async {
    try {
      String savePath = "/storage/emulated/0/Documents/$name.pdf";
      print("Saving PDF to $savePath");
      await Dio().download(url, savePath);
      localPath = savePath;
    } catch (e) {
      print("Error downloading file: $e");
    }
  }
}