import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class UserDetailsPage extends StatefulWidget {

  UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {

  late Database db;
  Map<String, Company> _company = {};
  late MyUser _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    await _initDatabase();
    await _syncData();
    Map<String, Company> companyWithId = {};
    Company? company = await getOneCompanyWithID(db, _user.company);
    companyWithId[_user.company] = company!;

    setState(() {
      _company = companyWithId;
    });
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _loadUser() async {
    try {
      AuthController authController = AuthController();
      UserService userService = UserService();
      String userId = authController.getCurrentUserUID();
      MyUser user = await userService.getCurrentUserData();
      setState(() {
        _user = user;
      });
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _syncData() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Companies...");
      await syncService.fullSyncTable("companies");
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Text(_user.username),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.eMail,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_user.email),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.userFirstName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_user.firstname ?? ""),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.userLastName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_user.name ?? ""),
              SizedBox(height: 16),
              Text(
                'Role:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_user.role),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(value: _user.apresFormation, onChanged: null),
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
              if(_user.apresFormationDoc != "" && _user.apresFormationDoc != null)
              Image.network(_user.apresFormationDoc!, width: 600),
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
