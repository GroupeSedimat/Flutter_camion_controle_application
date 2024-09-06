// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_super_parameters, unnecessary_import, prefer_const_literals_to_create_immutables

//import 'dart:js';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/user_service.dart';

import 'package:flutter_application_1/pages/base_page.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Page d'accueil",
      body: _buildBody(context),
    );
  }

Widget _buildBody(BuildContext context) {
  double w = MediaQuery.of(context).size.width;
  double h = MediaQuery.of(context).size.height;
  
  return FutureBuilder<MyUser>(
    future: UserService().getCurrentUserData(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      } else if (snapshot.hasData) {
        final MyUser userData = snapshot.data!;
        String welcomeMessage = userData.role == 'admin'
            ? 'Bienvenue sur la page admin, ${userData.username}!'
            : 'Bienvenue sur votre profil, ${userData.username}!';
        
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: w,
                height: h * 0.3,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 200, 225, 244),
                  image: DecorationImage(
                    image: AssetImage("assets/images/truck.jpg"), 
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.7), 
                      BlendMode.dstATop,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    welcomeMessage,
                    style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    // Couleur du texte
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(1.0), // Couleur de l'ombre avec opacité
                        offset: Offset(2, 2), // Décalage de l'ombre par rapport au texte
                        blurRadius: 5, // Rayon du flou de l'ombre
                      ),
                    ],
                  ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // _buildButton(
              //   context,
              //   'Voir maps',
              //   Icons.map,
              //   '/map',
              // ),
              // const SizedBox(height: 20),
            ],
          ),
        );
      } else {
        return const Center(child: Text("No data available"));
      }
    },
  );
}

  Widget _buildButton(BuildContext context, String text, IconData icon, String? route, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.blue,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
        onPressed: onTap ?? () {
          if (route != null) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}
