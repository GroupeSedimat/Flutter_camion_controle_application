import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_application_1/pages/base_page.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  late Database db;
  MyUser? _user;
  String? _userID;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _initDatabase();
    await _loadUser();
    await _syncData();
    if (mounted) {
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  Future<void> _loadUser() async {
    try {
      UserService userService = UserService();
      MyUser user = await userService.getCurrentUserData();
      String? userId = await userService.userID;
      _user = user;
      _userID = userId;
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _syncData() async {

    if (_user == null || _userID == null) {
      print("Cannot sync data: user or userID is not loaded");
      return;
    }else{
      print("Can sync data: user: ${_user!.name} is loaded");
    }
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("++++ Synchronizing Users...");
      await syncService.fullSyncTable("users", user: _user, userId: _userID);
      print("++++ Synchronizing Camions...");
      await syncService.fullSyncTable("camions");
      print("++++ Synchronizing CamionTypess...");
      await syncService.fullSyncTable("camionTypes");
      print("++++ Synchronizing Companies...");
      await syncService.fullSyncTable("companies");
      print("++++ Synchronizing Equipments...");
      await syncService.fullSyncTable("equipments");
      print("++++ Synchronizing LOL...");
      await syncService.fullSyncTable("listOfLists");
      print("++++ Synchronizing Blueprints...");
      await syncService.fullSyncTable("blueprints");
      print("++++ Synchronization with SQLite completed.");
    } catch (e) {
      print("++++ Error during synchronization with SQLite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: AppLocalizations.of(context)!.homePage,
      body: _isDataLoaded ? _buildBody(context) : CircularProgressIndicator(),
    );
  }

  Widget _buildBody(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    // Vérification si le mode sombre est activé
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String welcomeMessage = _user!.role == 'admin'
        ? AppLocalizations.of(context)!.adminHello(_user!.username)
        : AppLocalizations.of(context)!.userHello(_user!.username);
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
