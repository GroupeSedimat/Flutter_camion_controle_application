import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ModifyProfilePage extends StatefulWidget {
  @override
  _ModifyProfilePageState createState() => _ModifyProfilePageState();
}

class _ModifyProfilePageState extends State<ModifyProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  //DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userProfileEdit),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
       color: Color.fromARGB(108, 255, 255, 255),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.userNewName,
              ),
            ),
             /*SizedBox(height: 20),
            TextFormField(
              controller: dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Nouvelle date de naissance',
              ),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {s
                    selectedDate = picked;
                    dobController.text = picked.toString();
                  });
                }
              },
            ),*/
            SizedBox(height: 20),
            // TextField(
            //   controller: emailController,
            //   decoration: InputDecoration(
            //     labelText: 'Nouvelle adresse e-mail',
            //   ),
            // ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Appeler une fonction dans AuthController pour mettre à jour le profil
                AuthController.instance.updateProfile(
                  usernameController.text.trim(),
                  dobController.text.trim(),
                  emailController.text.trim(),
                );
              },
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
        ),
      ),
    );
  }
}
