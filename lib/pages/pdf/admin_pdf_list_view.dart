import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/widgets/base_page.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_company_tile.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/services/pdf/database_pdf_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

/// page affichant les fichiers PDF pour l'admin et le superadmin
class AdminPdfListView extends StatefulWidget {
  @override
  State<AdminPdfListView> createState() => _AdminPdfListViewState();
}

class _AdminPdfListViewState extends State<AdminPdfListView> {

  late Database db;
  Map<String, Company> _companyList = HashMap();
  late MyUser _user;
  late String _userId;
  bool _isLoading = true;
  late Map<String, Map<MyUser, Map<String, String>>> _pdfList;

  late AuthController authController;
  late UserService userService;
  late NetworkService networkService;
  late DatabasePDFService databasePDFService;

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
    /// initialisation de la base de données locale
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _initServices() async {
    try {
      /// initialisation des services
      authController = AuthController();
      userService = UserService();
      networkService = Provider.of<NetworkService>(context, listen: false);
      databasePDFService = DatabasePDFService();
    } catch (e) {
      print("Error loading services: $e");
    }
  }

  Future<void> _loadUserToConnection() async {
    /// téléchargement des données utilisateur actuelles
    Map<String, MyUser>? users = await getThisUser(db);
    if(users != null ){
      /// si l'utilisateur actuel est dans la base de données, quittez la fonction et continuez
      return;
    }
    try {
      /// si l'utilisateur actuel n'est pas encore dans la base de données, synchroniser les données utilisateur
      MyUser user = await userService.getCurrentUserData();
      String? userId = await userService.userID;
      final syncService = Provider.of<SyncService>(context, listen: false);
      await syncService.fullSyncTable("users", user: user, userId: userId);
    } catch (e) {
      print("💽 Error loading user: $e");
    }
  }

  /// enregistrer l'ID utilisateur actuel et les données dans des variables
  Future<void> _loadUser() async {
    try {
      Map<String, MyUser>? users = await getThisUser(db);
      MyUser user = users!.values.first;
      String? userId = users.keys.first;
      _userId = userId;
      _user = user;
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  /// synchroniser chaque table séparément,
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

  /// charge les données et les stocke dans des variables locales
  Future<void> _loadDataFromDatabase() async {
    await _loadCompanies();
    await _loadPdf();
  }

  /// charge l'ID et les données sur la ou les entreprises
  Future<void> _loadCompanies() async {
    try {
      Map<String, Company>? companyList = await getAllCompanies(db, _user.role);
      if(companyList != null){
        _companyList = companyList;
      }
    } catch (e) {
      print("Error loading Companies Names: $e");
    }
  }

  /// si l'application est en ligne, la fonction enregistre les données attribuées
  /// de manière appropriée des entreprises, des utilisateurs et des fichiers PDF
  Future<void> _loadPdf() async {
    try {
      /// créer une Map avec des données attribuées pour un transfert ultérieur
      /// Map<String, Map<MyUser, Map<String, String>>> = (companyName, (user, (pdfName, pdfDownloadUrl)))
      Map<String, Map<MyUser, Map<String, String>>> pdf = {};
      if(networkService.isOnline){
        Map<String, MyUser>? users = await getAllUsers(db, _user.role);
        for(String company in _companyList.keys){
          for(var user in users!.entries){
            Map<MyUser, Map<String, String>> mapUserPdf = {};
            if(company == user.value.company){
              Map<String, String> docList = await databasePDFService.getUserPDF(company, user.key);
              Map<String, String> entry = {};
              for(var doc in docList.entries){
                entry[doc.key] = doc.value;
                mapUserPdf[user.value] = entry;
              }
              pdf[company] = mapUserPdf;
            }
          }
        }
        _pdfList = pdf;
      }
    } catch (e) {
      print("Error loading user's PDF: $e");
    }
  }

  bool _isSuperAdmin() {
    //no need 4 now
    return _user.role == 'superadmin';
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
      title: AppLocalizations.of(context)!.pdfListAdmin,
      body: _buildBody(),
    );
  }

  _buildBody() {
    return ListView(
      padding: EdgeInsets.all(25),
      /// sur la base de la map précédemment créée, crée une vue de liste affichant
      /// les données de chaque entreprise séparément à l'aide de la classe CompanyTile
      children: _pdfList.entries.map((companyData) {
        return CompanyTile(
          companyName: _companyList[companyData.key]?.name ?? companyData.key,
          companyUsersAndPdf: companyData.value,
        );
      }).toList(),
    );
  }
}