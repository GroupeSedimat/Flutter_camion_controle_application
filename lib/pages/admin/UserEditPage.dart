import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/database_validation_files_service.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/services/pick_image_service.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class UserEditPage extends StatefulWidget {
  final String userId;

  UserEditPage({required this.userId});

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  late Database db;
  bool _isLoading = true;
  late MyUser _user;
  late String _userId;
  late MyUser _editedUser;
  late String _editedUserId;
  Map<String, String>? availableCamionsMap;
  late AuthController authController;
  late UserService userService;
  late NetworkService networkService;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<TextEditingController> _camionsControllers = [];
  List<String> _camions = [];
  late String _selectedRole;
  late bool _isValidate;
  late String _isValidateDoc;
  final TextEditingController _uploadedImageUrl = TextEditingController();
  File? _selectedImage;

  /// todo make offline
  /// todo photos and files validations (DatabaseValidationService)
  /// todo repair refresh after delete/restore
  final PickImageService _pickImageService = PickImageService();
  final DatabaseValidationService _databaseValidationService = DatabaseValidationService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _initDatabase();
    await _initService();
    if (!networkService.isOnline) {
      print("Offline mode, no user update possible");
    }else{
      await _loadUserToConnection();
    }
    await _loadUser();
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible");
    }{
      await _syncData();
    }
    await _loadDataFromDatabase();
    _populateFieldsWithCamionTypeData();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _initService() async {
    try {
      authController = AuthController();
      userService = UserService();
      networkService = Provider.of<NetworkService>(context, listen: false);
    } catch (e) {
      print("Error loading services: $e");
    }
  }

  Future<void> _loadUserToConnection() async {
    print("LoL control page user to connection firebase ☢☢☢☢☢☢☢");
    Map<String, MyUser>? users = await getThisUser(db);
    print("users: $users");
    if(users != null ){
      return;
    }
    try {
      MyUser user = await userService.getCurrentUserData();
      print("user ☢☢☢☢☢☢☢ $user");
      String? userId = await userService.userID;
      print("userId ☢☢☢☢☢☢☢ $userId");
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Users...");
      await syncService.fullSyncTable("users", user: user, userId: userId);
    } catch (e) {
      print("💽 Error loading user: $e");
    }
  }

  Future<void> _loadUser() async {
    print("LoL control page local ☢☢☢☢☢☢☢");
    try {
      Map<String, MyUser>? users = await getThisUser(db);
      print("connected as  $users");
      MyUser user = users!.values.first;
      print("local user ☢☢☢☢☢☢☢ $user");
      String? userId = users.keys.first;
      print("local userId ☢☢☢☢☢☢☢ $userId");
      _userId = userId;
      _user = user;
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _syncData() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Users...");
      await syncService.fullSyncTable("users", user: _user, userId: _userId);
      print("💽 Synchronizing users Camions...");
      await syncService.fullSyncTable("camions", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }

  Future<void> _loadDataFromDatabase() async {
    await _loadCamionsLists();
    await _loadEditedUser();
  }

  Future<void> _loadCamionsLists() async {
    Map<String, String>? availableCamionsLists = {};
    if(isSuperAdmin()){
      availableCamionsLists = await getAllCamionsNames(db, _user.role);
    }else{
      availableCamionsLists = await getCompanyCamionsNames(db, _user.company, _user.role);
    }
    if(availableCamionsLists != null){
      availableCamionsMap = availableCamionsLists;
    }else {
      availableCamionsMap = {};
    }
  }
  Future<void> _loadEditedUser() async {
    // get edited user
    MyUser? editUser = await getOneUserWithID(db, widget.userId);
    if(editUser != null){
      _editedUser = editUser;
    }
    _editedUserId = widget.userId;
  }

  void _populateFieldsWithCamionTypeData() {
    String username = _editedUser.username;
    String name = _editedUser.name ?? "";
    String firstname = _editedUser.firstname ?? "";
    String email = _editedUser.email;
    String role = _editedUser.role.isNotEmpty ? _editedUser.role : UserRole.user.toString().split('.').last; // Default role
    bool isValidate = _editedUser.apresFormation ?? false;
    String isValidateDoc = _editedUser.apresFormationDoc ?? "";
    String uploadedImageUrl = _editedUser.apresFormationDoc ?? "";
    List<String> camions = _editedUser.camion ?? [];

    setState(() {
      _usernameController.text = username;
      _nameController.text = name;
      _firstnameController.text = firstname;
      _emailController.text = email;
      _selectedRole = role;
      _isValidate = isValidate;
      _isValidateDoc = isValidateDoc;
      _uploadedImageUrl.text = uploadedImageUrl;
      _camions = camions;
      _camionsControllers = camions.map((item) => TextEditingController(text: item)).toList();
    });
  }

  isSuperAdmin(){
    return _user.role=="superadmin";
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _firstnameController.dispose();
    _emailController.dispose();
    for (var controller in _camionsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCamionField() {
    setState(() {
      _camionsControllers.add(TextEditingController());
      _camions.add('');
    });
  }

  void _removeCamionField(int index) {
    setState(() {
      _camionsControllers[index].dispose();
      _camionsControllers.removeAt(index);
      _camions.removeAt(index);
    });
  }

  Future<void> pickAndUploadFromGallery() async {
    final File? image = await _pickImageService.pickImageFromGallery();

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });

      String imageUrl = await _databaseValidationService.addValidationToFirebase(
          image.path,
          "${_editedUser.username}_validation_doc"
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
          "${_editedUser.username}_validation_doc"
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor.withOpacity(0.4),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    List<String> roles = UserRole.values.map((role) => role.toString().split('.').last).toList();

    String deleted = _editedUser.deletedAt == null ? "" : " user deleted";
    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context)!.userProfileEdit}$deleted"),
        actions: [
          _editedUser.deletedAt == null ?
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _confirmDeleteUser,
          )
              :
          IconButton(
            icon: Icon(Icons.restore),
            onPressed: _restoreUser,
          )
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
              if(isSuperAdmin())
              const Text("Add Camions:"),
              ..._camionsControllers.asMap().entries.map((entry) {
                int index = entry.key;
                return ListTile(
                  title: DropdownButtonFormField<String>(
                    value: availableCamionsMap!.containsKey(_camions[index]) ? _camions[index] : null,
                    decoration: InputDecoration(labelText: "Camion ${index + 1}"),
                    items: availableCamionsMap!.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _camions[index] = val!;
                      });
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () => _removeCamionField(index),
                  ),
                );
              }),
              if(isSuperAdmin())
              TextButton(
                onPressed: _addCamionField,
                child: const Text("Add Camion"),
              ),
              if(isSuperAdmin())
              SizedBox(height: 16),
              if(isSuperAdmin())
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
              if(isSuperAdmin())
              SizedBox(height: 16),
              if(isSuperAdmin())
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

              if(isSuperAdmin())
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
    MyUser update = MyUser(
      username: _usernameController.text,
      name: _nameController.text,
      firstname: _firstnameController.text,
      role: _selectedRole,
      email: _emailController.text,
      company: _editedUser.company,
      camion: _camions,
      apresFormation: _isValidate,
      apresFormationDoc: _isValidateDoc,
      createdAt: _editedUser.createdAt,
      updatedAt: DateTime.now(),
    );
    await updateUser(db, update, _editedUserId);
    if (networkService.isOnline) {
      await _syncData();
    }
    await _loadDataFromDatabase();
    Navigator.of(context).pop();
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
    await softDeleteUser(db, _editedUserId);
    if (networkService.isOnline) {
      await _syncData();
    }
    await _loadDataFromDatabase();
    setState(() {});
    Navigator.of(context).pop();
  }

  void _restoreUser() async {
    await restoreUser(db, _editedUserId);
    if (networkService.isOnline) {
      await _syncData();
    }
    await _loadDataFromDatabase();
    setState(() {});
  }
}
