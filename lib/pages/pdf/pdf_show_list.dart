import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/pdf/pdf_show_template.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/services/pdf/database_pdf_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class PDFShowList extends StatefulWidget {
  const PDFShowList({super.key});

  @override
  State<PDFShowList> createState() => _PDFShowListState();
}

class _PDFShowListState extends State<PDFShowList> {

  late Database db;
  late MyUser _user;
  late String _userId;
  bool _isLoading = true;
  Map<String, String>? pdfList;

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
      print("💽 Synchronizing PDFs...");
      await syncService.fullSyncTable("pdf", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during global data synchronization: $e");
      rethrow;
    }
  }

  Future<void> _loadDataFromDatabase() async {
    if (networkService.isOnline){
      await _loadPdfs();
    }
  }

  Future<void> _loadPdfs() async {
    DatabasePDFService databasePDFService = DatabasePDFService();
    pdfList =  await databasePDFService.getUserListOfPDF(_user.company, _userId);
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

    if (!networkService.isOnline){
      return BasePage(
        title: AppLocalizations.of(context)!.pdfListAdmin,
        body: Text(
          AppLocalizations.of(context)!.dataNoDataOffLine,
          style: TextStyle(color: Colors.red, fontSize: 30),
        ),
      );
    }

    return BasePage(
      title: AppLocalizations.of(context)!.pdfMyFiles,
      body: body(context),
    );
  }

  Widget body(BuildContext context) {
    if(pdfList == null){
      return Text(AppLocalizations.of(context)!.dataNoData);
    }
    Map<String,String> sortedPdf = HashMap();
    sortedPdf = Map.fromEntries(pdfList!.entries.toList()..sort(
            (e1, e2) => (e2.value).compareTo(e1.value))
    );
    return ListView.builder(
      itemCount: sortedPdf.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (BuildContext context, int index){
        final entry = sortedPdf.entries.toList()[index];
        final fileName = entry.key;
        final url = entry.value;
        return PDFShowTemplate(fileName: fileName, url: url, user: _user);
      },
    );
  }
}
