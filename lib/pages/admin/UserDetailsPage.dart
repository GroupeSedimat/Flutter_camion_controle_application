import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
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

  MapEntry<String, MyUser>? userToShow;
  UserDetailsPage({super.key, this.userToShow});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {

  /// todo - show other user if other user provide
  /// todo - manage "after formation" photo
  /// todo - test added camions to user

  late Database db;
  late MyUser _thisUser;
  late String _thisUserId;
  bool _isLoading = true;
  late Map<String, String> _availableCamions;
  Map<String, Company> _company = HashMap();
  late MyUser showUser;
  late String showUserId;

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
    Map<String, MyUser>? users = await getThisUser(db);
    if(users != null ){
      return;
    }
    try {
      MyUser user = await userService.getCurrentUserData();
      String? userId = await userService.userID;
      final syncService = Provider.of<SyncService>(context, listen: false);
      await syncService.fullSyncTable("users", user: user, userId: userId);
    } catch (e) {
      print("💽 Error loading user: $e");
    }
  }

  Future<void> _loadUser() async {
    try {
      Map<String, MyUser>? users = await getThisUser(db);
      MyUser user = users!.values.first;
      String? userId = users.keys.first;
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
    await _loadAvailableCamions();
    await _showThisUser();
  }

  Future<void> _loadCompany() async {
    Map<String, Company> companyWithId = {};
    Company? company = await getOneCompanyWithID(db, _thisUser.company);
    companyWithId[_thisUser.company] = company!;
    if(companyWithId != {}){
      _company = companyWithId;
    }
  }

  Future<void> _loadAvailableCamions() async {
    Map<String, Camion>? camions = await getAllCamions(db, _thisUser.role);
    var temp = camions?.map((key, camion) => MapEntry(key, camion.name));
    if(temp != null){
      _availableCamions = temp;
    }else {
      _availableCamions = {};
    }
  }

  Future<void> _showThisUser() async {
    if(widget.userToShow == null){
      showUser = _thisUser;
      showUserId = _thisUserId;
    }else{
      showUser = widget.userToShow!.value;
      showUserId = widget.userToShow!.key;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
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
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.details),
        actions: [
          if(showUser.deletedAt == null)
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _confirmDeleteUser,
          ),
          if(showUser.deletedAt != null)
          IconButton(
            icon: Icon(Icons.restore),
            onPressed: _restoreUser,
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
              Text(showUser.username),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.eMail,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(showUser.email),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.userFirstName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(showUser.firstname ?? ""),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.userLastName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(showUser.name ?? ""),
              SizedBox(height: 16),
              Text(
                'Role:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(showUser.role),
              SizedBox(height: 16),
              Text("Camions:", style: textStyleBold()),
              ...showUser.camion!.map((item) => Container(
                margin: EdgeInsets.only(top: 8.0),
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(_availableCamions[item] ?? "Unknown list!", style: textStyle()),
              )),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(value: showUser.apresFormation, onChanged: null),
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
              if(showUser.apresFormationDoc != "" && showUser.apresFormationDoc != null)
              Image.network(showUser.apresFormationDoc!, width: 600),
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

  TextStyle textStyle(){
    return TextStyle(fontSize: 20);
  }
  TextStyle textStyleBold(){
    return TextStyle(fontSize: 25, fontWeight: FontWeight.bold);
  }

  void _confirmDeleteUser() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDelete),
          content: Text(AppLocalizations.of(context)!.confirmDeleteText),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.no),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: _deleteUser,
              child: Text(AppLocalizations.of(context)!.yes),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser() async {
    await softDeleteUser(db, showUserId);
    if (networkService.isOnline) {
      await _syncData();
    }
    await _loadDataFromDatabase();
    Navigator.of(context).pop();
  }

  void _restoreUser() async {
    await restoreUser(db, showUserId);
    if (networkService.isOnline) {
      await _syncData();
    }
    await _loadDataFromDatabase();
    Navigator.of(context).pop();
  }

}
