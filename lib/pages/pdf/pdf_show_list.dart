import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/widgets/base_page.dart';
import 'package:flutter_application_1/pages/pdf/pdf_show_template.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/services/pdf/database_pdf_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

/// page affichant les fichiers PDF pour user
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
    /// vérifier si l'application est en ligne
    if (!networkService.isOnline) {
      print("Offline mode, no user update possible");
    }else{
      await _loadUserToConnection();
    }
    await _loadUser();
    /// vérifier si l'application est en ligne avant d'essayer de synchroniser
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible");
    }{
      await _syncData();
    }
    await _loadDataFromDatabase();
    if (mounted) {
      /// une fois l'initialisation terminée, modifiez la valeur de _isDataLoaded en true pour afficher le contenu de la page chargée
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
    if (networkService.isOnline){
      await _loadPdfs();
    }
  }

  /// prend une map de fichiers PDF et l'enregistre dans une variable
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
        /// afficher une liste de fichiers PDF en utilisant la classe PDFShowTemplate
        /// (vous pouvez ajouter une pagination pour un plus grand nombre de fichiers)
        return PDFShowTemplate(fileName: fileName, url: url, user: _user);
      },
    );
  }
}
