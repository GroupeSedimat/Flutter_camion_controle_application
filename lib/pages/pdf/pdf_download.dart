import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
        String downloadDirPath = await getDocumentsPath();
        savePath = "$downloadDirPath/$name.pdf";
        print(savePath);
        File file = File(savePath);
        if (await file.exists()) {
          return; 
        }
      }
      await Dio().download(url, savePath);
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  void deleteFile(File file) {
    if (file.existsSync()) {
      file.deleteSync();
      print('File $name deleted.');
    } else {
      print('File does not exist.');
    }
  }

  Future<String> getDocumentsPath() async {
    String documentsPath;
    if (Platform.isAndroid) {
      documentsPath = "/storage/emulated/0/Documents/camion_appli";
      if (await Permission.storage.request().isGranted){
        Directory downloadDir = Directory(documentsPath);
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
      }else {
        print("No write permissions!");
        openAppSettings();
      }
    } else if (Platform.isIOS) {
      Directory? appDocDir = await getApplicationDocumentsDirectory();
      if (appDocDir == null) {
        throw Exception("Failed to get external directory");
      }
      documentsPath = appDocDir.path;
    } else {
      throw Exception("Unsupported platform");
    }
    return documentsPath;
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

  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Write permissions granted.");
    } else {
      throw Exception("No write permissions!");
    }
  }
}