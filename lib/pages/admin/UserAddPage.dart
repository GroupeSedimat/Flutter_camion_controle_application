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

class UserAddPage extends StatefulWidget {
  @override
  _UserAddPageState createState() => _UserAddPageState();
}

class _UserAddPageState extends State<UserAddPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late String _selectedRole;
  late bool _isValidate;
  late String _isValidateDoc;
  late String _selectedCompany;
  late String _selectedCamion;
  late bool _isApproved;
  final TextEditingController _uploadedImageUrl = TextEditingController();
  File? _selectedImage;

  final List<String> companies = ["Company1", "Company2", "Company3"]; 
  final List<String> camions = ["Camion1", "Camion2", "Camion3"]; 
  final List<String> roles = ["admin", "user", "manager"]; 

  @override
  void initState() {
    super.initState();
    _selectedRole = roles.first; 
    _isValidate = false; 
    _isValidateDoc = ''; 
    _selectedCompany = companies.first; 
    _selectedCamion = camions.first; 
    _isApproved = false; 
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _firstnameController.dispose();
    _emailController.dispose();
    _uploadedImageUrl.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    if (_usernameController.text.isEmpty || 
        _nameController.text.isEmpty || 
        _firstnameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _selectedCompany.isEmpty || 
        _selectedCamion.isEmpty) {
      Get.snackbar(
        "Erreur",
        "Tous les champs sont obligatoires.",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    String finalValidateDoc = _isValidateDoc.isEmpty ? 'Aucun document téléchargé' : _isValidateDoc;

    try {
      await FirebaseFirestore.instance.collection('users').add({
        'username': _usernameController.text,
        'name': _nameController.text,
        'firstname': _firstnameController.text,
        'email': _emailController.text,
        'role': _selectedRole,
        'apresFormation': _isValidate,
        'apresFormationDoc': finalValidateDoc,
        'company': _selectedCompany,
        'camion': _selectedCamion,
        'isApproved': _isApproved,
      });

      Get.snackbar(
        "Utilisateur ajouté",
        "L'utilisateur a été ajouté avec succès.",
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );

      Navigator.of(context).pop();
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Erreur lors de l'ajout : ${e.toString()}",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un utilisateur"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "Nom d'utilisateur"),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _firstnameController,
                decoration: InputDecoration(labelText: "Prénom"),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nom"),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              SizedBox(height: 16),
              Wrap(
                children: [
                  Text("Utilisateur validé après formation"),
                  Checkbox(
                    value: _isValidate,
                    onChanged: (value) {
                      setState(() {
                        _isValidate = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                "Document après formation",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_uploadedImageUrl.text.isNotEmpty)
                Column(
                  children: [
                    Image.network(_uploadedImageUrl.text, width: 250),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _uploadedImageUrl.clear();
                          _isValidateDoc = '';
                        });
                      },
                      child: Text("Supprimer l'image"),
                    ),
                  ],
                )
              else
                Text("Aucune image téléchargée"),
              SizedBox(height: 16),
              DropdownButton<String>(
                value: _selectedCompany,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCompany = newValue!;
                  });
                },
                items: companies.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              DropdownButton<String>(
                value: _selectedCamion,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCamion = newValue!;
                  });
                },
                items: camions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text("Approuvé"),
                  Switch(
                    value: _isApproved,
                    onChanged: (bool value) {
                      setState(() {
                        _isApproved = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
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
                onPressed: _addUser,
                child: Text("Confirmer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 