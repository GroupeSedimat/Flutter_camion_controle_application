import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
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
  String? _userId;
  bool _isDataLoaded = false;
  late AuthController authController;
  late UserService userService;
  late NetworkService networkService;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _initDatabase();
    await _initServices();
    if (!networkService.isOnline) {
      print("Offline mode, no user update possible");
    }else{
      await _loadUserToConnection();
    }
    await _loadUser();
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible");
    }{
      await _syncData();
    }
    if (mounted) {
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  Future<void> _initServices() async {
    try {
      authController = AuthController();
      userService = UserService();
      networkService = Provider.of<NetworkService>(context, listen: false);
    } catch (e) {
      print("Error loading services: $e");
    }
  }

  Future<void> _loadUserToConnection() async {
    print("welcome user to connection firebase ☢☢☢☢☢☢☢");
    Map<String, MyUser>? users = await getThisUser(db);
    print("users: $users");
    if(users != null ){
      return;
    }
    try {
      MyUser user = await userService.getCurrentUserData();
      print("user ☢☢☢☢☢☢☢ $user");
      String? userId = await userService.userID;
      print("userId ☢☢☢☢☢☢☢ $userId");
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Users...");
      await syncService.fullSyncTable("users", user: user, userId: userId);
    } catch (e) {
      print("💽 Error loading user: $e");
    }
  }

  Future<void> _loadUser() async {
    print("welcome page local ☢☢☢☢☢☢☢");
    try {
      Map<String, MyUser>? users = await getThisUser(db);
      print("connected as  $users");
      MyUser user = users!.values.first;
      print("local user ☢☢☢☢☢☢☢ $user");
      String? userId = users.keys.first;
      print("local userId ☢☢☢☢☢☢☢ $userId");
      _userId = userId;
      _user = user;
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _syncData() async {

    if (_user == null || _userId == null) {
      print("Cannot sync data: user or userID is not loaded");
      return;
    }else{
      print("Can sync data: user: ${_user!.name} is loaded");
    }
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Users...");
      await syncService.fullSyncTable("users", user: _user, userId: _userId);
      print("💽 Synchronizing users Camions...");
      await syncService.fullSyncTable("camions", user: _user, userId: _userId);
      List<String> camionsTypeIdList = [];
      await getAllCamions(db).then((camionsMap) {
        if(camionsMap != null){
          for(var camion in camionsMap.entries){
            if(!camionsTypeIdList.contains(camion.value.camionType)){
              camionsTypeIdList.add(camion.value.camionType);
            }
          }
        }
      });
      print("Camion types Ids in list: $camionsTypeIdList");
      print("💽 Synchronizing CamionTypess...");
      await syncService.fullSyncTable("camionTypes",  user: _user, userId: _userId, dataPlus: camionsTypeIdList);
      List<String> camionListOfListId = [];
      Map<String, CamionType>? camionTypesMap = await getAllCamionTypes(db);
      if(camionTypesMap != null){
        for(var camionType in camionTypesMap.entries){
          if(camionType.value.lol != null){
            for(var list in camionType.value.lol!){
              if(!camionListOfListId.contains(list)){
                camionListOfListId.add(list);
              }
            }
          }
        }
      }
      print("💽 Synchronizing Companies...");
      await syncService.fullSyncTable("companies", user: _user, userId: _userId);
      print("💽 Synchronizing Equipments...");
      await syncService.fullSyncTable("equipments");
      print("Camion List of Lists Ids: $camionListOfListId");
      print("💽 Synchronizing LOL...");
      await syncService.fullSyncTable("listOfLists",  user: _user, userId: _userId, dataPlus: camionListOfListId);
      print("💽 Synchronizing Blueprints...");
      await syncService.fullSyncTable("blueprints", user: _user, userId: _userId);
      print("💽 Synchronizing Validate Tasks...");
      await syncService.fullSyncTable("validateTasks", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
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
