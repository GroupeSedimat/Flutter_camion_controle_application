// ignore_for_file: constant_identifier_names, avoid_print

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

const String IMAGES_STORAGE_REF = "images";

class DatabaseImageService{
  late final Reference _referenceImages;
  final Reference _fireReference = FirebaseStorage.instance.ref();

  DatabaseImageService(){
    _referenceImages = _fireReference.child(IMAGES_STORAGE_REF);
  }

  Future<String> addImageToFirebase(String path) async {
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImageToUpload = _referenceImages.child(imageName);
    try{
      await referenceImageToUpload.putFile(File(path));
      return await referenceImageToUpload.getDownloadURL();
    }catch(e){
      print(e);
      return '';
    }
  }
}