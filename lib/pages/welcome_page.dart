import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_application_1/pages/base_page.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: AppLocalizations.of(context)!.homePage,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    // Vérification si le mode sombre est activé
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              ? AppLocalizations.of(context)!.adminHello(userData.username)
              : AppLocalizations.of(context)!.userHello(userData.username);

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: w,
                  height: h * 0.3,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color.fromARGB(255, 50, 50, 50) // Couleur pour mode sombre
                        : const Color.fromARGB(255, 200, 225, 244), // Couleur pour mode clair
                    image: DecorationImage(
                      image: const AssetImage("assets/images/truck.jpg"),
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
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildButton(
                  context,
                  'Voir maps',
                  Icons.map,
                  '/map',
                ),
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
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor, // S'adapte au thème actif
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
