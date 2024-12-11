import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:flutter_application_1/services/database_validation_files_service.dart';
import 'package:flutter_application_1/services/pick_image_service.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserEditPage extends StatefulWidget {
  final MyUser user;

  UserEditPage({required this.user});

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late String _selectedRole;
  late bool _isValidate;
  late String _isValidateDoc;
  final TextEditingController _uploadedImageUrl = TextEditingController();
  File? _selectedImage;

  final PickImageService _pickImageService = PickImageService();
  final DatabaseValidationService _databaseValidationService = DatabaseValidationService();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
    _nameController.text = widget.user.username;
    _firstnameController.text = widget.user.username;
    _emailController.text = widget.user.email;
    _selectedRole = widget.user.role.isNotEmpty ? widget.user.role : UserRole.user.toString().split('.').last; // Default role
    _isValidate = widget.user.apresFormation ?? false;
    _isValidateDoc = widget.user.apresFormationDoc ?? "";
    _uploadedImageUrl.text = widget.user.apresFormationDoc ?? "";
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _firstnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> roles = UserRole.values.map((role) => role.toString().split('.').last).toList();

    Future<void> pickAndUploadFromGallery() async {
      final File? image = await _pickImageService.pickImageFromGallery();

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });

        String imageUrl = await _databaseValidationService.addValidationToFirebase(
            image.path,
            "${widget.user.username}_validation_doc"
        );

        setState(() {
          _uploadedImageUrl.text = imageUrl;
          _isValidateDoc = imageUrl;
        });
      }
    }

    Future<void> pickAndUploadFromCamera() async {
      final File? image = await _pickImageService.pickImageFromCamera();

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });

        String imageUrl = await _databaseValidationService.addValidationToFirebase(
            image.path,
            "${widget.user.username}_validation_doc"
        );

        setState(() {
          _uploadedImageUrl.text = imageUrl;
          _isValidateDoc = imageUrl;
        });
      }
    }

    Future<void> deleteImage() async {
      if (_uploadedImageUrl.text.isNotEmpty) {
        try {
          await _databaseValidationService.deleteValidationFromFirebase(_uploadedImageUrl.text);

          setState(() {
            _uploadedImageUrl.text = '';
            _isValidateDoc = '';
          });

          Get.snackbar(
            "Image deleted",
            "The image has been successfully deleted.",
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (e) {
          Get.snackbar(
            "Error",
            "Failed to delete image: $e",
            backgroundColor: Colors.red,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userProfileEdit),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _confirmDeleteUser,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.userName),
              ),
              SizedBox(height: 16),
               TextField(
                controller: _firstnameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.userFirstName),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.userLastName),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.eMail),
              ),
              SizedBox(height: 16),
              Wrap(
                children: [
                  Text(
                    "User after Formation",
                  ),
                  Checkbox(value: _isValidate, onChanged: (value) {
                    setState(() {
                      _isValidate = value!;
                    });
                  }),
                ]
              ),
              SizedBox(height: 16),
              Text(
                'Apres Formation Doc:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_uploadedImageUrl.text.isNotEmpty)
                Column(
                  children: [
                    Image.network(_uploadedImageUrl.text, width: 250),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: deleteImage,
                      child: Text("Delete Image"),
                    ),
                  ],
                )
              else
                Text("No image uploaded yet."),
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: pickAndUploadFromCamera,
                    child: Text("Make Photo"),
                  ),
                  ElevatedButton(
                    onPressed: pickAndUploadFromGallery,
                    child: Text("Upload/Change Image"),
                  ),
                ],
              ),

              DropdownButton<String>(
                value: _selectedRole,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
                items: roles.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text(AppLocalizations.of(context)!.confirm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateUser() async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.user.username)
          .get();

      if (userDoc.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.docs[0].id)
            .update({
          'username': _usernameController.text,
          'name': _nameController.text,
          'firstname': _firstnameController.text,
          'email': _emailController.text,
          'role': _selectedRole,
          'apresFormation': _isValidate,
          'apresFormationDoc': _isValidateDoc,
        });

        Get.snackbar(
          "User updated",
          "User information has been updated successfully.",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.back();
      } else {
        Get.snackbar(
          "Error",
          "User not found.",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error while updating",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _confirmDeleteUser() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDelete),
          content: Text(AppLocalizations.of(context)!.confirmDeleteText),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.no),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: _deleteUser,
              child: Text(AppLocalizations.of(context)!.yes),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser() async {
    Navigator.of(context).pop();
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.user.username)
          .get();

      if (userDoc.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.docs[0].id)
            .delete();

        Get.snackbar(
          "User deleted",
          "User has been deleted successfully.",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.back();
      } else {
        Get.snackbar(
          "Error",
          "User not found.",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error while deleting",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
