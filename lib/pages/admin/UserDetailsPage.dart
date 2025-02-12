import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class UserDetailsPage extends StatefulWidget {

  MyUser? userToShow;
  UserDetailsPage({super.key, this.userToShow});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {

  /// todo - show other user if other user provide
  /// todo - manage "after formation" photo
  /// todo - add camions to user

  late Database db;
  late MyUser _thisUser;
  late String _thisUserId;
  bool _isLoading = true;
  Map<String, Company> _company = HashMap();
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
    await _initService();
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
    await _loadDataFromDatabase();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _initService() async {
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
    print("equipment list page local ☢☢☢☢☢☢☢");
    try {
      Map<String, MyUser>? users = await getThisUser(db);
      print("connected as  $users");
      MyUser user = users!.values.first;
      print("local user ☢☢☢☢☢☢☢ $user");
      String? userId = users.keys.first;
      print("local userId ☢☢☢☢☢☢☢ $userId");
      _thisUserId = userId;
      _thisUser = user;
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _syncData() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Users...");
      await syncService.fullSyncTable("users", user: _thisUser, userId: _thisUserId);
      print("💽 Synchronizing Companies...");
      await syncService.fullSyncTable("companies", user: _thisUser, userId: _thisUserId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }

  Future<void> _loadDataFromDatabase() async {
    await _loadCompany();
  }

  Future<void> _loadCompany() async {
    Map<String, Company> companyWithId = {};
    Company? company = await getOneCompanyWithID(db, _thisUser.company);
    companyWithId[_thisUser.company] = company!;
    if(companyWithId != {}){
      _company = companyWithId;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.8),
                  Theme.of(context).primaryColor.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.details),
        actions: const [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.userName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_thisUser.username),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.eMail,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_thisUser.email),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.userFirstName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_thisUser.firstname ?? ""),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.userLastName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_thisUser.name ?? ""),
              SizedBox(height: 16),
              Text(
                'Role:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_thisUser.role),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(value: _thisUser.apresFormation, onChanged: null),
                  Text(
                    'User after Formation:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Apres Formation Doc:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if(_thisUser.apresFormationDoc != "" && _thisUser.apresFormationDoc != null)
              Image.network(_thisUser.apresFormationDoc!, width: 600),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.company,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_company.values.first.name),
            ],
          ),
        ),
      ),
    );
  }
}
