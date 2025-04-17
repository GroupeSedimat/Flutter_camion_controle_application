import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfDownload {
  final String url;
  final String name;

  PdfDownload({required this.name, required this.url}) {
    // Vérifie que l'URL n'est pas vide
    if (url.trim().isEmpty) {
      throw ArgumentError("L'URL ne peut pas être vide.");
    }
    // Essaye de parser l'URL et vérifie qu'elle contient bien un schéma et un hôte
    final parsedUri = Uri.tryParse(url);
    if (parsedUri == null ||
        parsedUri.scheme.isEmpty ||
        parsedUri.host.isEmpty) {
      throw ArgumentError("L'URL n'est pas complète ou invalide: $url");
    }
  }

  Future<void> downloadFile() async {
    String savePath;
    try {
      if (name == "temp") {
        // Enregistre dans le répertoire de l'application si c'est un document temporaire
        print("name == temp");
        Directory appDocDir = await getApplicationSupportDirectory();
        print("Répertoire de l'app: ${appDocDir.path}");
        savePath = "${appDocDir.path}/$name.pdf";
        deleteFile(File(savePath));
      } else {
        print("name != temp");
        String downloadDirPath = await getDocumentsPath();
        savePath = "$downloadDirPath/$name.pdf";
        print("Chemin complet: $savePath");
        File file = File(savePath);
        if (await file.exists()) {
          // Le fichier existe déjà, inutile de le télécharger à nouveau.
          return;
        }
      }
      print("savePath: $savePath");

      // Vérifie à nouveau que l'URL est correctement formée
      Uri? pdfUri = Uri.tryParse(url);
      if (pdfUri == null || pdfUri.scheme.isEmpty || pdfUri.host.isEmpty) {
        throw ArgumentError("L'URL est invalide ou incomplète: $url");
      }
      print("URL valide: $pdfUri");

      // Lance le téléchargement avec Dio.
      await Dio().download(url, savePath);
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  void deleteFile(File file) {
    if (file.existsSync()) {
      file.deleteSync();
      print('Fichier $name supprimé.');
    } else {
      print('Le fichier n\'existe pas.');
    }
  }

  Future<String> getDocumentsPath() async {
    String documentsPath;
    if (Platform.isAndroid) {
      documentsPath = "/storage/emulated/0/Documents/camion_appli";
      if (await Permission.storage.request().isGranted) {
        Directory downloadDir = Directory(documentsPath);
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
      } else {
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

  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Write permissions granted.");
    } else {
      throw Exception("No write permissions!");
    }
  }
}
