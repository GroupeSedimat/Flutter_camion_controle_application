import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({Key? key}) : super(key: key);

  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  late Database db;
  Map<String, String> _companyListNames = HashMap();

  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController firstnameController;
  late TextEditingController passwordController;
  late TextEditingController usernameController;
  late TextEditingController confirmPasswordController;
  String selectedRole = 'user';
  String? selectedCompany;
  String? errorMessage;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    usernameController = TextEditingController();
    nameController = TextEditingController();
    firstnameController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  Future<void> _loadDataFromDatabase() async {
    await _initDatabase();
    await _syncData();
    await _loadCompanies();
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _loadCompanies() async {
    try {
      Map<String, String>? companyNames = await getAllCompaniesNames(db, "");
      if (companyNames != null) {
        setState(() {
          _companyListNames = companyNames;
        });
      }
    } catch (e) {
      print("Error loading Companies Names: $e");
    }
  }

  Future<void> _syncData() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Companies...");
      String timeSync = DateTime.now().toIso8601String();
      await syncService.syncFromFirebase(
          "companies", userId: "123456789", timeSync);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    nameController.dispose();
    firstnameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    List<DropdownMenuItem<String>> companyItems = _companyListNames.entries
        .map((entry) => DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            ))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/truck.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  DatabaseHelper().clearTables([
                    "users",
                    "updates",
                    "camions",
                    "camionTypes",
                    "equipments",
                    "companies",
                    "listOfLists",
                    "blueprints",
                    "validateTasks"
                  ]);
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: EdgeInsets.only(left: 10, top: 40),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child:
                        Icon(Icons.arrow_back, color: Colors.white, size: 25),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    Icon(
                      Icons.app_registration,
                      size: 70,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.signIn,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
                width: w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTextField(AppLocalizations.of(context)!.eMailEnter,
                        Icons.email, emailController),
                    const SizedBox(height: 20),
                    buildTextField(AppLocalizations.of(context)!.userName,
                        Icons.person, usernameController),
                    const SizedBox(height: 20),
                    buildTextField(AppLocalizations.of(context)!.userFirstName,
                        Icons.person, firstnameController),
                    const SizedBox(height: 20),
                    buildTextField(AppLocalizations.of(context)!.userLastName,
                        Icons.person, nameController),
                    const SizedBox(height: 20),
                    buildPasswordTextField(
                        AppLocalizations.of(context)!.passEnter,
                        passwordController,
                        obscurePassword),
                    const SizedBox(height: 20),
                    buildPasswordTextField(
                        AppLocalizations.of(context)!.passRepeat,
                        confirmPasswordController,
                        obscureConfirmPassword),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedCompany,
                      hint: Text(AppLocalizations.of(context)!.companySelect),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: companyItems,
                      onChanged: (value) {
                        setState(() {
                          selectedCompany = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 65),
              GestureDetector(
                onTap: () {
                  if (selectedCompany == null) {
                    setState(() {
                      errorMessage =
                          AppLocalizations.of(context)!.companySelect;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(AppLocalizations.of(context)!.companySelect),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                  } else {
                    if (isUsernameAlreadyTaken(
                        usernameController.text.trim())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(AppLocalizations.of(context)!.usernameTaken),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      // Si tout va bien, procéder à l'inscription
                      AuthController.instance.register(
                        emailController.text.trim(),
                        usernameController.text.trim(),
                        nameController.text.trim(),
                        firstnameController.text.trim(),
                        passwordController.text.trim(),
                        confirmPasswordController.text.trim(),
                        selectedRole,
                        selectedCompany!,
                      );
                    }
                  }
                },
                child: Container(
                  width: w * 0.6,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Theme.of(context).primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.signIn,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 3.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fonction pour vérifier si le nom d'utilisateur est déjà pris
  bool isUsernameAlreadyTaken(String username) {
    // Cette fonction doit vérifier dans la base de données si le nom d'utilisateur est déjà pris
    // Retourne `true` si le nom est pris, sinon `false`
    return false; // Remplacer par la vraie logique
  }

  Widget buildTextField(
      String hintText, IconData icon, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 7,
            offset: const Offset(1, 1),
            color: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildPasswordTextField(
      String hintText, TextEditingController controller, bool obscureText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 7,
            offset: const Offset(1, 1),
            color: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText, // Utilisation correcte du booléen obscureText
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              setState(() {
                if (hintText == AppLocalizations.of(context)!.passEnter) {
                  obscurePassword =
                      !obscurePassword; // Basculer la visibilité du mot de passe principal
                } else {
                  obscureConfirmPassword =
                      !obscureConfirmPassword; // Basculer la visibilité du mot de passe de confirmation
                }
              });
            },
          ),
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
