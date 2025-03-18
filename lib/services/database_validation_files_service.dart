import 'dart:collection';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

const String VALIDATION_STORAGE_REF = "validation_files";

/// classe responsable du transfert des documents attribués aux "MyUser.apresFormationDoc" entre Firebase et l'appareil.
class DatabaseValidationService{
  late final Reference _referenceValidation;
  final Reference _fireReference = FirebaseStorage.instance.ref();

  DatabaseValidationService(){
    _referenceValidation = _fireReference.child(VALIDATION_STORAGE_REF);
  }

  Reference fireValidationReference(){
    return _referenceValidation;
  }

  Future<String> addValidationToFirebase(String path, String fileName) async {
    Reference referenceValidationToUpload = _referenceValidation.child(fileName);
    try{
      await referenceValidationToUpload.putFile(File(path));
      return await referenceValidationToUpload.getDownloadURL();
    }catch(e){
      print(e);
      return '';
    }
  }

  Future<void> deleteValidationFromFirebase(String fileUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(fileUrl).delete();
    } catch (e) {
      print("Error deleting file from Firebase: $e");
      throw e;
    }
  }

  Future<Map<String, String>> getCompanyListOfValidation(String companyID) async {
    Map<String, String> validationList = HashMap();
    try {
      final companyRef = _referenceValidation.child(companyID);
      final companySnapshot = await companyRef.listAll();

      // Iterate through the subfolders (prefixes)
      for (var subfolderRef in companySnapshot.prefixes) {
        final subfolderSnapshot = await subfolderRef.listAll();

        // Iterate through the files (items) in each subfolder
        for (var validationRef in subfolderSnapshot.items) {
          String downloadURL = await validationRef.getDownloadURL();
          validationList[validationRef.name] = downloadURL;
        }
      }
      return validationList;

    } catch (error) {
      print("Error retrieving $companyID Validation list: $error");
      return validationList;
    }
  }
}