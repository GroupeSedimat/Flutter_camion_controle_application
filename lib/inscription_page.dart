// ignore_for_file: use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print, unused_local_variable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'auth_controller.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({Key? key}) : super(key: key);

  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController usernameController;
  late TextEditingController confirmPasswordController;
  late TextEditingController dobController;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    usernameController = TextEditingController();
    confirmPasswordController = TextEditingController();
    dobController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    confirmPasswordController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = ["google.png", "facebook.png", "twitter.png"];

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.purple[99],
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.only(left: 10.0, top: 30.0),
                child: Icon(Icons.arrow_back),
              ),
            ),
            Container(
              width: w,
              height: h * 0.3,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/image2.webp"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: h * 0.12),
                  const CircleAvatar(
                    radius: 100,
                    backgroundImage: AssetImage(
                      "assets/images/836.jpg",
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              width: w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 7,
                          offset: const Offset(1, 1),
                          color: Colors.grey.withOpacity(0.3),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                          hintText: 'Entrez votre email',
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.purpleAccent),
                          hintStyle:
                              TextStyle(color: Colors.grey.withOpacity(0.5)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1.0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1.0)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30))),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 7,
                          offset: const Offset(1, 1),
                          color: Colors.grey.withOpacity(0.3),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                          hintText: 'Nom d\'utilisateur',
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.purpleAccent),
                          hintStyle:
                              TextStyle(color: Colors.grey.withOpacity(0.5)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1.0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1.0)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30))),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 7,
                          offset: const Offset(1, 1),
                          color: Colors.grey.withOpacity(0.3),
                        )
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );

                        if (selectedDate != null) {
                          print(selectedDate);
                          dobController.text =
                              DateFormat('yyyy-MM-dd').format(selectedDate);
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: dobController,
                          decoration: InputDecoration(
                            hintText: 'Date de naissance',
                            prefixIcon: const Icon(Icons.calendar_today,
                                color: Colors.purpleAccent),
                            hintStyle:
                                TextStyle(color: Colors.grey.withOpacity(0.5)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buildPasswordTextField('Entrez votre mot de passe', passwordController, obscurePassword),
                  const SizedBox(
                    height: 20,
                  ),
                  buildPasswordTextField('Confirmer le mot de passe', confirmPasswordController, obscureConfirmPassword),
                ],
              ),
            ),
            const SizedBox(
              height: 65,
            ),
            GestureDetector(
              onTap: () {
                AuthController.instance.register(
                  emailController.text.trim(),
                  usernameController.text.trim(),
                  dobController.text.trim(),
                  passwordController.text.trim(),
                  confirmPasswordController.text.trim(),
                );
              },
              child: Container(
                width: w * 0.3,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: const DecorationImage(
                        image: AssetImage("assets/images/purple-wallpaper.jpg"),
                        fit: BoxFit.cover)),
                child: const Center(
                  child: Text(
                    "S'inscrire",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            
            
            //je commente pour le moment l'inscription via d'autres méthodes on verra après
            
            /* SizedBox(height: w * 0.2),
            RichText(
              text: TextSpan(
                text: "Inscrivez-vous en utilisant ces méthodes suivantes:",
                style: TextStyle(color: Colors.grey[500], fontSize: 20),
              ),
            ),
            Wrap(
              children: List<Widget>.generate(
                3,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            AssetImage("assets/images/" + images[index]),
                      ),
                    ),
                  );
                },
              ),
            ), */
          ],
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
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.password, color: Colors.purpleAccent),
          suffixIcon: IconButton(
            icon: Icon(
         obscureText ? Icons.visibility_off : Icons.visibility, 
              color: Colors.purple,
            ),
            onPressed: () {
              setState(() {
                if (hintText == 'Entrez votre mot de passe') {
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
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
