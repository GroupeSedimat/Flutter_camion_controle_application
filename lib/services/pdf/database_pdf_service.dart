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

      var sortedKeys = pdfList.keys.toList()
        ..sort((k1, k2) => pdfList[k2]!.compareTo(pdfList[k1]!));

      return LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => pdfList[k]!,
      );

      // return pdfList;
    } catch (error) {
      print("Error retrieving $companyID pdf list: $error");
      return pdfList;
    }
  }

  Future<Map<String, String>> getUserListOfPDF(String companyID, String userId) async {
    Map<String, String> pdfList = HashMap();
    try {
      final userRef = _referencePdf.child(companyID).child(userId);
      final userSnapshot = await userRef.listAll();
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

  Future<Map<String, String>> getUserPDF(String companyID, String userID) async {
    Map<String, String> pdfList = HashMap();
    try {
      final userRef = _referencePdf.child(companyID).child(userID);
      final userSnapshot = await userRef.listAll();
      for (var pdfRef in userSnapshot.items) {
        String downloadURL = await pdfRef.getDownloadURL();
        pdfList[pdfRef.name] = downloadURL;
      }

      var sortedKeys = pdfList.keys.toList()
        ..sort((k1, k2) => pdfList[k2]!.compareTo(pdfList[k1]!));

      return LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => pdfList[k]!,
      );
      // return pdfList;
    } catch (error) {
      print("Error retrieving User $userID pdf list: $error");
      return pdfList;
    }
  }
}