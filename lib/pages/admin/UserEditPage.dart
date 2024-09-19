import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
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

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
    _nameController.text = widget.user.username;
    _firstnameController.text = widget.user.username;
    _emailController.text = widget.user.email;
    _selectedRole = widget.user.role.isNotEmpty ? widget.user.role : UserRole.user.toString().split('.').last; // Default role

    // Debugging: Print the initial values
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
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.userName),
            ),
             TextField(
              controller: _firstnameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.userFirstName),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.userLastName),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.eMail),
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
          'role': _selectedRole, // Update the role
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
              child: Text(AppLocalizations.of(context)!.yes),
              onPressed: _deleteUser,
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
