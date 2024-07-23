// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_super_parameters, unnecessary_import, prefer_const_literals_to_create_immutables

//import 'dart:js';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/user_service.dart';

import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/settings_page.dart';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Welcome Page'),
      backgroundColor: Colors.purple,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Get.to(() => SettingsPage());
          
          },
        ),
      ],
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
                   
                      color: Color.fromARGB(255, 214, 189, 239),
                   
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 80,
                        backgroundImage: AssetImage("assets/images/836.jpg"),
                      ),
                      const SizedBox(height: 10),
                      /*Text(
                        userData.username,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),*/
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  welcomeMessage,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildButton(
                  context,
                  'Go to maps',
                  Icons.map,
                  '/map',
                ),
                const SizedBox(height: 200),
                _buildButton(
                  context,
                  "Se déconnecter",
                  Icons.logout,
                  null,
                  onTap: () {
                    AuthController.instance.logOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vous avez été déconnecté'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
                /*if (userData.role == 'admin')
                  const SizedBox(height: 20),c
                if (userData.role == 'admin')
                  _buildButton(
                    context,
                    "Admin Page",
                    Icons.admin_panel_settings,
                    '/adminpage',
                  ),*/
                const SizedBox(height: 20),


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
          foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
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
