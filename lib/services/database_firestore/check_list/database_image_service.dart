// ignore_for_file: constant_identifier_names, avoid_print

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

const String IMAGES_STORAGE_REF = "images";

/// une classe fonctionnant sur la collection "images" dans Firebase storage
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

  Future<Uint8List?> downloadImageFromFirebase(String url) async {
    try {
      final Reference imageRef = FirebaseStorage.instance.refFromURL(url);
      final Uint8List? data = await imageRef.getData();
      return data;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  Future<Null> addBlueprintImageToFirebase(String path, String imageName) async {
    int listNr = int.parse(imageName.substring(0, imageName.length - 24));
    int posNr = int.parse(imageName.substring(4, imageName.length - 20));
    Reference referenceImageToUpload = _referenceImages.child("blueprints_images").child("list_$listNr").child(imageName);
    try{
      await referenceImageToUpload.putFile(File("$path/$imageName"));
    }catch(e){
      print('Error sending image to Firebase: $e');
    }
  }

  Future<Uint8List?> downloadBlueprintImageFromFirebase(String imageName) async {
    try {
      int listNr = int.parse(imageName.substring(0, imageName.length - 24));
      Reference imageRef = _referenceImages.child("blueprints_images").child("list_$listNr").child(imageName);
      Uint8List? data = await imageRef.getData();
      return data;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }
}