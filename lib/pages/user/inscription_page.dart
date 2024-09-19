import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/services/database_company_service.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({Key? key}) : super(key: key);

  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
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
    emailController = TextEditingController();
    passwordController = TextEditingController();
    usernameController = TextEditingController();
    nameController = TextEditingController();
    firstnameController = TextEditingController();
    confirmPasswordController = TextEditingController();
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
  final DatabaseCompanyService databaseCompanyService = DatabaseCompanyService();
  Future<Map<String, Company>> allCompanies = databaseCompanyService.getAllCompanies();

  double w = MediaQuery.of(context).size.width;
  double h = MediaQuery.of(context).size.height;

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
                Navigator.of(context).pop();
              },
              child: Container(
                margin: EdgeInsets.only(left: 10, top: 40),
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8), 
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 25),
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
                    color: Colors.blue,
                  ),
                  SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.signIn,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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
                  buildTextField(AppLocalizations.of(context)!.eMailEnter, Icons.email, emailController),
                  const SizedBox(height: 20),
                  buildTextField(AppLocalizations.of(context)!.userName, Icons.person, usernameController),
                  const SizedBox(height: 20),
                  buildTextField(AppLocalizations.of(context)!.userFirstName, Icons.person, firstnameController),
                  const SizedBox(height: 20),
                  buildTextField(AppLocalizations.of(context)!.userLastName, Icons.person, nameController),
                  const SizedBox(height: 20),
                  buildPasswordTextField(AppLocalizations.of(context)!.passEnter, passwordController, obscurePassword),
                  const SizedBox(height: 20),
                  buildPasswordTextField(AppLocalizations.of(context)!.passRepeat, confirmPasswordController, obscureConfirmPassword),
                  const SizedBox(height: 20),
                  FutureBuilder<Map<String, Company>>(
                    future: databaseCompanyService.getAllCompanies(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No companies found.');
                      } else {
                        Map<String, Company> companies = snapshot.data!;
                        List<DropdownMenuItem<String>> companyItems = companies.entries
                            .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value.name),
                        ))
                            .toList();
                        return DropdownButtonFormField<String>(
                          value: selectedCompany,
                          hint: Text(AppLocalizations.of(context)!.companySelect),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.white, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.white, width: 1.0),
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
                        );
                      }
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
                    errorMessage = AppLocalizations.of(context)!.companySelect;
                  });
                } else {
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
              },
              child: Container(
                width: w * 0.6,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.blue,
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


  Widget buildTextField(String hintText, IconData icon, TextEditingController controller) {
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
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.blue),
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.blue, width: 1.0),
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

  Widget buildPasswordTextField(String hintText, TextEditingController controller, bool obscureText) {
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
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.lock, color: Colors.blue),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.blue,
            ),
            onPressed: () {
              setState(() {
                if (hintText == AppLocalizations.of(context)!.passEnter) {
                  obscurePassword = !obscurePassword;
                } else {
                  obscureConfirmPassword = !obscureConfirmPassword;
                }
              });
            },
          ),
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.blue, width: 1.0),
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
