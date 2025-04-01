import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class PickImageService{

  /// La fonction déclenche la sélection d'une photo de la galerie et la renvoie sous forme de fichier
  Future<File?> pickImageFromGallery() async{
    try {
      final image =  await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return null;
      return File(image.path);

    } on PlatformException catch (e) {
      print('Failed to pick image from gallery: $e');
      return null;
    }
  }

  /// La fonction déclenche la prise d'une photo avec l'appareil photo de l'appareil et la renvoie sous forme de fichier
  Future<File?> pickImageFromCamera() async{
    try {
      final image =  await ImagePicker().pickImage(source: ImageSource.camera);
      if(image == null) return null;
      return File(image.path);
    } on PlatformException catch (e) {
      print('Failed to pick image from camera: $e');
      return null;
    }
  }
}