// ignore_for_file: use_super_parameters, prefer_const_constructors, unused_import, library_private_types_in_public_api, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/user/login_page.dart';
import 'package:firebase_core/firebase_core.dart'; // Importez Firebase Core

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool firebaseInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  void initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        firebaseInitialized = true;
      });
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/image9.jpg'), 
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop), // Opacité réduite
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Texte d'indication
              Text(
                'Bienvenue sur Mobility corner  application',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple, // Couleur du texte
                ),
              ),
              SizedBox(height: 20), // Espacement entre le texte et le bouton

              // Bouton de redirection vers la page de connexion
              ElevatedButton(
                onPressed: () {
                  if (firebaseInitialized) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()), // Redirige vers la page de connexion
                    );
                  }
                },
                child: Text('Connectez-vous'), // Texte du bouton
              ),
            ],
          ),
        ),
      ),
    );
  }
}
