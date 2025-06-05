import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ModifyProfilePage extends StatefulWidget {
  final MyUser user;

  const ModifyProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _ModifyProfilePageState createState() => _ModifyProfilePageState();
}

class _ModifyProfilePageState extends State<ModifyProfilePage> {
  final AuthController authController = AuthController.instance;

  late TextEditingController usernameController;
  late TextEditingController firstnameController;
  late TextEditingController nameController;

  @override
  void initState() {
    usernameController = TextEditingController(text: widget.user.username);
    firstnameController = TextEditingController(text: widget.user.firstname);
    nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    usernameController.dispose();
    firstnameController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (usernameController.text.trim().isEmpty ||
        firstnameController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Erreur",
        "Tous les champs sont obligatoires.",
        backgroundColor: Colors.orange,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await authController.updateProfile(
        usernameController.text.trim(),
        firstnameController.text.trim(),
        nameController.text.trim(),
      );

      Get.snackbar(
        "Succès",
        "Profil mis à jour avec succès.",
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        "Erreur",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userProfileEdit),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernTextField(
              controller: usernameController,
              label: AppLocalizations.of(context)!.userName,
              icon: Icons.person,
            ),
            const SizedBox(height: 20),
            _buildModernTextField(
              controller: firstnameController,
              label: AppLocalizations.of(context)!.userFirstName,
              icon: Icons.badge,
            ),
            const SizedBox(height: 20),
            _buildModernTextField(
              controller: nameController,
              label: AppLocalizations.of(context)!.userLastName,
              icon: Icons.family_restroom,
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  elevation: 5,
                  shadowColor: Colors.black54,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.save, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.edit,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
