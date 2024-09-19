// ignore_for_file: use_super_parameters, prefer_const_constructors, unused_import, library_private_types_in_public_api, avoid_print
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/pages/user/login_page.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/locale_provider.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool firebaseInitialized = false;
  bool firebaseError = false;

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/truck.jpg'), 
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop), // Opacité réduite
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Ajout du logo
              Image.asset(
                'assets/images/keybas_logo.png', // Assurez-vous que le chemin est correct
                height: 100, // Ajustez la taille du logo selon vos besoins
                
              ),
              SizedBox(height: 20),
              
              // Ajout du texte
              Text(
                AppLocalizations.of(context)!.welcomeToMC,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(1.0),
                      offset: Offset(2, 2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                textAlign: TextAlign.center, 
              ), 
              SizedBox(height: 20),
              DropdownButton<String>(
                value: localeProvider.locale.languageCode,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    localeProvider.setLocale(newValue);
                    Get.updateLocale(Locale(newValue));
                  }
                },
                items: <String>['en', 'fr', 'pl']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(_getLanguageName(value)),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
               if (firebaseError)
                Text(
                  'Error initializing Firebase',
                  style: TextStyle(color: Colors.red),
                )
              else if (!firebaseInitialized)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      try {
                        await Firebase.initializeApp();
                        Get.put(AuthController());
                        setState(() {
                          firebaseInitialized = true;
                        });
                        Get.to(() => LoginPage());
                      } catch (e) {
                        print('Error initializing Firebase: $e');
                        setState(() {
                          firebaseError = true;
                        });
                      }
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5), // Couleur personnalisée avec transparence
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.0,
                         
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Text(
                          AppLocalizations.of(context)!.logIn,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold, 
                            color: Color.fromARGB(255, 254, 254, 254),
                           shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(1.0), // Couleur de l'ombre avec opacité
                              offset: Offset(2, 2), // Décalage de l'ombre par rapport au texte
                              blurRadius: 5, // Rayon du flou de l'ombre
                            ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (firebaseInitialized)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Get.to(() => LoginPage());
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3), // Couleur personnalisée avec transparence
                        
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Text(
                          AppLocalizations.of(context)!.logIn,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
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
  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'pl':
        return 'Polski';
      case 'wo':
        return 'Wolof';
      default:
        return '';
    }
  }
}
