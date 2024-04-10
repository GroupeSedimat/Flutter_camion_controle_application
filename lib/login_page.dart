// ignore_for_file: use_super_parameters, unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/inscription_page.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'auth_controller.dart';
import 'reset_password_page.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginPagestate createState()  => _LoginPagestate();

}

class _LoginPagestate  extends State<LoginPage> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  
  @override


  Widget build(BuildContext context){
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.purple [99],
      body: SingleChildScrollView(
        child: Column(
        children: [
          Container(
            width: w,
            height: h*0.3,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/image2.webp"
                ),
                fit: BoxFit.cover
              )
            )
          ),

          Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            width: w,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                   "Bonjour!",
                   style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold
                   ),
                   ),
                Text(
                   "Connectez-vous à votre compte",
                   style: TextStyle(
                    fontSize: 20,
                    color:Colors.grey[500]
                   ),
                   ),
                   const SizedBox(height: 50,),

                   Container(
                    decoration: BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 7,
                          offset: const Offset(1, 1),
                          color:Colors.grey.withOpacity(0.3)
                           )
                      ]
                    ),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Entrez votre email ', // Ajoutez votre texte ici
                        prefixIcon: const Icon(Icons.email, color:Colors.purpleAccent),
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)), // Définissez l'opacité souhaitée
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color:Colors.white,
                            width: 1.0
                        )
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color:Colors.white,
                          width: 1.0
                        )
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30))
                    ),
                    
                   )
                   ),
         
                   const SizedBox(height: 50,),

                   Container(
                    decoration: BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 7,
                          offset: const Offset(1, 1),
                          color:Colors.grey.withOpacity(0.3)
                           )
                      ]
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Entrez votre mot de passe', 
                        prefixIcon: const Icon(Icons.password, color:Colors.purpleAccent),
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)), 
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color:Colors.white,
                            width: 1.0
                        )
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color:Colors.white,
                          width: 1.0
                        )
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30))
                    ),
                   )
                   ),

                    const SizedBox(height: 50,),
                    Row(
  children: [
    Expanded(
      child: Container(),
    ),
    GestureDetector(
      onTap: () {
        Get.to(() => ResetPasswordPage()); // Naviguer vers la page de réinitialisation du mot de passe
      },
      child: Text(
        "Mot de passe oublié?",
        style: TextStyle(
          decoration: TextDecoration.underline,
          decorationColor: Colors.purple,
          decorationStyle: TextDecorationStyle.solid,
          fontSize: 20,
          color: Colors.purple[400],
        ),
      ),
    ),
  ],
)
,
                    
              ],
            ),
          ),

          const SizedBox(height: 65,),

           GestureDetector(
            onTap: (){
               AuthController.instance.login(emailController.text.trim(), passwordController.text.trim());
            },
             child: Container(
              width: w*0.3,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: const DecorationImage(
                  image: AssetImage(
                    "assets/images/purple-wallpaper.jpg"
                  ),
                  fit: BoxFit.cover
                )
              ),
             
              
              child: const Center(
                child: Text(
                       "Se connecter",
                       style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color:Colors.white,
                       ),
                       ),
              ),
                       ),
           ),

         SizedBox(height: w * 0.2),
            GestureDetector(
              onTap: () {
                // Navigation vers la page d'inscription lorsque le texte est cliqué
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InscriptionPage()),
                );
              },
              child: RichText(
                text: TextSpan(
                  text: "Vous n'avez pas encore un compte? ",
                  style: TextStyle(color: Colors.grey[500], fontSize: 20),
                  children: const [
                    TextSpan(
                      text: "Inscrivez-vous",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.purple,
                        decorationStyle: TextDecorationStyle.solid,
                        color: Colors.purple,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      )
      )
     );
  }
}