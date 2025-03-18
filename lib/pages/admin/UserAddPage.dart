// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAddPage extends StatefulWidget {
  const UserAddPage({super.key});

  @override
  _UserAddPageState createState() => _UserAddPageState();
}

class _UserAddPageState extends State<UserAddPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedRole;
  String? _selectedCompany;
  bool _isApproved = false;
  final UserService _userService = UserService();

  List<String> companies = [];
  List<String> roles = [];

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
    _fetchRoles();
  }

  Future<void> _fetchCompanies() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('companies').get();
      setState(() {
        companies = snapshot.docs.map((doc) => doc['name'] as String).toList();
        _selectedCompany = companies.isNotEmpty ? companies.first : null;
      });
    } catch (e) {
      print("Erreur lors du chargement des entreprises : $e");
    }
  }

  Future<void> _fetchRoles() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('roles').get();
      setState(() {
        roles = snapshot.docs.map((doc) => doc['name'] as String).toList();
        _selectedRole = roles.isNotEmpty ? roles.first : null;
      });
    } catch (e) {
      print("Erreur lors du chargement des rôles : $e");
    }
  }

  Future<void> _addUser() async {
    if (_usernameController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _firstnameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedCompany == null ||
        _selectedRole == null) {
      Get.snackbar(
        "Erreur",
        "Veuillez remplir tous les champs obligatoires.",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _userService.addUser({
        'username': _usernameController.text,
        'name': _nameController.text,
        'firstname': _firstnameController.text,
        'email': _emailController.text,
        'role': _selectedRole,
        'company': _selectedCompany,
        'isApproved': _isApproved,
      });

      Get.snackbar(
        "Succès",
        "Utilisateur ajouté avec succès.",
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );

      Navigator.of(context).pop();
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Erreur lors de l'ajout de l'utilisateur : ${e.toString()}",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un utilisateur"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_usernameController, "Nom d'utilisateur"),
              _buildTextField(_firstnameController, "Prénom"),
              _buildTextField(_nameController, "Nom"),
              _buildTextField(_emailController, "Email"),
              const SizedBox(height: 16),
              _buildDropdown(
                "Entreprise",
                _selectedCompany,
                companies,
                (value) => setState(() => _selectedCompany = value),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                "Rôle",
                _selectedRole,
                roles,
                (value) => setState(() => _selectedRole = value),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Approuvé"),
                  Switch(
                    value: _isApproved,
                    onChanged: (value) => setState(() => _isApproved = value),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addUser,
                child: const Text("Confirmer"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
    );
  }
}
