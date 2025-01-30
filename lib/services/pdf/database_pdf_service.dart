// ignore_for_file: constant_identifier_names, avoid_print

import 'dart:collection';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/services/auth_controller.dart';

const String PDF_STORAGE_REF = "pdf";

class DatabasePDFService{
  late final Reference _referencePdf;
  final Reference _fireReference = FirebaseStorage.instance.ref();

  DatabasePDFService(){
    _referencePdf = _fireReference.child(PDF_STORAGE_REF);
  }

  Reference firePdfReference(){
    return _referencePdf;
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

  Future<Map<String, String>> getCompanyListOfPDF(String companyID) async {
    Map<String, String> pdfList = HashMap();
    try {
      final companyRef = _referencePdf.child(companyID);
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
      return pdfList;

    } catch (error) {
      print("Error retrieving $companyID pdf list: $error");
      return pdfList;
    }
  }

  Future<Map<String, String>> getUserListOfPDF(String companyID) async {
    Map<String, String> pdfList = HashMap();
    AuthController authController = AuthController();
    String userId = authController.getCurrentUserUID();
    try {
      final userRef = _referencePdf.child(companyID).child(userId);
      final userSnapshot = await userRef.listAll();

      // Iterate through the files (items) in each subfolder
      for (var pdfRef in userSnapshot.items) {
        String downloadURL = await pdfRef.getDownloadURL();
        pdfList[pdfRef.name] = downloadURL;
      }
      return pdfList;

    } catch (error) {
      print("Error retrieving User $userId pdf list: $error");
      return pdfList;
    }
  }

}