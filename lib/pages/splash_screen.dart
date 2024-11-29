// ignore_for_file: use_super_parameters, prefer_const_constructors, unused_import, library_private_types_in_public_api, avoid_print
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/pages/user/login_page.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/camion/database_camion_service.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/update_tables.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local_service/sync_service.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sqflite/sqflite.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool firebaseInitialized = false;
  bool firebaseError = false;
  Map<String, Camion> allCamions = {};
  DatabaseHelper databaseHelper = DatabaseHelper();
  DatabaseCamionService databaseCamionService = DatabaseCamionService();
  late Database db;
  late SyncService syncService;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _initializeFirebase();
      await _initializeDatabase();
      await _syncGlobalData();
      // _navigateToNextScreen();
    } catch (e) {
      print("Error during app initialization: $e");
      // Możesz tutaj obsłużyć błędy, np. wyświetlić komunikat.
    }
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      Map<String, Camion> camions = await databaseCamionService.getAllCamions();
      setState(() {
        allCamions = camions;
        firebaseInitialized = true;
      });
      print("Firebase initialized successfully.");
    } catch (e) {
      setState(() {
        firebaseError = true;
      });
      print("Error initializing Firebase: $e");
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      Database database = await databaseHelper.database;
      setState(() {
        db = database;
      });
      print("SQLite database initialized successfully.");
    } catch (e) {
      print("Error initializing SQLite database: $e");
      throw e;
    }
  }

  Future<void> _syncGlobalData() async {
    try {
      print("Synchronizing global data...");
      setState(() {
        syncService = SyncService(db);
        syncService.fullSyncTable("camions");
      });
      // insertMultipleCamions(db, allCamions);
    } catch (e) {
      print("Error during global data synchronization: $e");
      throw e;
    }
  }

  void _navigateToNextScreen() {
    if (firebaseInitialized && !firebaseError) {
      Get.off(() => LoginPage()); // Przejście do strony logowania
    } else {
      // Możesz dodać ekran błędu, jeśli Firebase nie zainicjalizował się poprawnie
      print("Error detected. Staying on SplashScreen.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/truck.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/keybas_logo.png',
                height: 100,
              ),
              SizedBox(height: 20),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: localeProvider.locale.languageCode,
                  icon: Icon(Icons.language, color: Colors.blueAccent),
                  underline: SizedBox(),
                  dropdownColor: Colors.white,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      localeProvider.setLocale(newValue);
                      Get.updateLocale(Locale(newValue));
                    }
                  },
                  items: <String>['en', 'fr', 'pl', 'ar']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        _getLanguageName(value),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 20),
              if (firebaseError)
                Text(
                  'Error initializing Firebase',
                  style: TextStyle(color: Colors.red),
                )
              else if (!firebaseInitialized)
                CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: () {
                    Get.put(AuthController());
                    Get.to(() => LoginPage());
                  },
                  icon: Icon(Icons.login),
                  label: Text(AppLocalizations.of(context)!.logIn),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                )
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
      case 'ar':
        return 'Arabic';
      default:
        return '';
    }
  }
}