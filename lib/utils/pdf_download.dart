import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Une classe conçue pour télécharger un fichier PDF et le coller à l'endroit approprié
class PdfDownload {
  final String url;
  final String name;

  PdfDownload( {required this.name, required this.url});

  Future<void> downloadFile() async {
    String savePath;
    try {
      if(name == "temp"){
        /// Enregistrer dans le répertoire de l'application s'il s'agit d'un document temporaire.
        /// Chaque fichier temporaire suivant écrasera le fichier existant.
        print("name == temp");
        Directory appDocDir = await getApplicationSupportDirectory();
        print("name == temp ${appDocDir.path}");
        savePath = "${appDocDir.path}/$name.pdf";
        deleteFile(File(savePath));
      }else{
        print("name != temp");
        String downloadDirPath = await getDocumentsPath();
        savePath = "$downloadDirPath/$name.pdf";
        print(savePath);
        File file = File(savePath);
        if (await file.exists()) {
          return; 
        }
      }
      print("savePath $savePath");
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

  /// une fonction qui spécifie le chemin pour enregistrer le fichier sur l'appareil, en fonction du type (Android, iOS)
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
      }
    } else if (Platform.isIOS) {
      Directory? appDocDir = await getApplicationSupportDirectory();
      if (appDocDir == null) {
        throw Exception("Failed to get external directory");
      }
      documentsPath = appDocDir.path;
    } else {
      throw Exception("Unsupported platform");
    }
    return documentsPath;
  }

  ///
  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Write permissions granted.");
    } else {
      throw Exception("No write permissions!");
    }
  }
}