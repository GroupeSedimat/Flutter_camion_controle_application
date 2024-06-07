import 'dart:collection';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

const String PDF_STORAGE_REF = "pdf";

class DatabasePDFService{
  late final Reference _referencePdf;
  final Reference _fireReference = FirebaseStorage.instance.ref();

  DatabasePDFService(){
    _referencePdf = _fireReference.child(PDF_STORAGE_REF);
  }

  Future<String> addPdfToFirebase(String path, String fileName) async {
    Reference referencePdfToUpload = _referencePdf.child(fileName);
    try{
      await referencePdfToUpload.putFile(File(path));
      return await referencePdfToUpload.getDownloadURL();
    }catch(e){
      print(e);
      return '';
    }
  }

  Future<Map<String, String>> getCompanyListOfPDF(String company) async {
    Map<String, String> pdfList = HashMap();
    try {
      final companyRef = _referencePdf.child(company);
      final companySnapshot = await companyRef.listAll();

      // Iterate through the subfolders (prefixes)
      for (var subfolderRef in companySnapshot.prefixes) {
        final subfolderSnapshot = await subfolderRef.listAll();

        // Iterate through the files (items) in each subfolder
        for (var pdfRef in subfolderSnapshot.items) {
          String downloadURL = await pdfRef.getDownloadURL();
          pdfList[pdfRef.name] = downloadURL;
        }
      }
      print(pdfList);
      return pdfList;

    } catch (error) {
      // Gérez l’erreur
      print("Error retrieving $company pdf list: $error");
      return pdfList;
    }
  }

}