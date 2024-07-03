import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';


class PdfDownload {
  final String url;
  final String name;

  PdfDownload( {required this.name, required this.url});

  Future<void> downloadFile() async {
    String savePath;
    try {
      if(name == "temp"){
        //save in app directory if its temp docs
        Directory appDocDir = await getTemporaryDirectory();
        savePath = "${appDocDir.path}/$name.pdf";
        deleteFile(File(savePath));
      }else{
        savePath = "/storage/emulated/0/Documents/camion_appli/$name.pdf";
        File file = File(savePath);
        if (await file.exists()) {
          return; // Exit the method if the file already exists
        }
      }
      await Dio().download(url, savePath);
    } catch (e) {
      print("Error downloading file: $e");
    }
  }



  void deleteFile(File file) {
    // check if file exists
    if (file.existsSync()) {
      // delete file
      file.deleteSync();
      print('File $name deleted.');
    } else {
      print('File does not exist.');
    }
  }

  // Future<void> downloadFile() async {
  //   try {
  //     String savePath = "/storage/emulated/0/Documents/camion_appli/$name.pdf";
  //     print("Saving PDF to $savePath");
  //     await Dio().download(url, savePath);
  //   } catch (e) {
  //     print("Error downloading file: $e");
  //   }
  // }
}