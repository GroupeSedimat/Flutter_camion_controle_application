import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_company_tile.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_user_tile.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/services/pdf/database_pdf_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class AdminPdfListView extends StatefulWidget {
  @override
  State<AdminPdfListView> createState() => _AdminPdfListViewState();
}

class _AdminPdfListViewState extends State<AdminPdfListView> {
  final Reference _firePdfReference = DatabasePDFService().firePdfReference();

  late Database db;
  Map<String, Company> _companyList = HashMap();
  late MyUser _user;
  late String _userId;
  bool _isLoading = true;

  late AuthController authController;
  late UserService userService;
  late NetworkService networkService;

  /// todo repair loading view and showing files
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

  Future<void> _syncData() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing users...");
      await syncService.fullSyncTable("users", user: _user, userId: _userId);
      print("💽 Synchronizing Companies...");
      await syncService.fullSyncTable("companies", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during global data synchronization: $e");
      rethrow;
    }
  }

  Future<void> _loadDataFromDatabase() async {
    await _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    try {
      Map<String, Company>? companyList = await getAllCompanies(db);
      if(companyList != null){
        _companyList = companyList;
      }
    } catch (e) {
      print("Error loading Companies Names: $e");
    }
  }

  bool _isSuperAdmin() {
    return _user.role == 'superadmin';
  }

  @override
  Widget build(BuildContext context) {
    if (!networkService.isOnline){
      return BasePage(
        title: AppLocalizations.of(context)!.pdfListAdmin,
        body: Text(
          AppLocalizations.of(context)!.dataNoDataOffLine,
          style: TextStyle(color: Colors.red, fontSize: 30),
        ),
      );
    }
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

    return BasePage(
      title: AppLocalizations.of(context)!.pdfListAdmin,
      body: _buildBody(),
    );
  }

  _buildBody() {
    return Scaffold(
      body: FutureBuilder<ListResult>(
        future: getCompanyPdfData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final companyPdfList = snapshot.data!.prefixes;
            if (_isSuperAdmin()) {
              return ListView(
                // padding: EdgeInsets.all(25),
                children: companyPdfList.map((companyRef) {
                  return CompanyTile(
                    companyRef: companyRef,
                    companyName: _companyList[companyRef.name]?.name ?? companyRef.name,
                  );
                }).toList(),
              );
            } else {
              return
                ListView(
                  children: companyPdfList.map((userRef) {
                    return UserTile(userRef: userRef);
                  }).toList(),
                );
            }
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
    );
  }

  Future<ListResult> getCompanyPdfData() async {
    if (_isSuperAdmin()) {
      return _firePdfReference.listAll();
    } else {
      return _firePdfReference.child(_user.company).listAll();
    }
  }
}