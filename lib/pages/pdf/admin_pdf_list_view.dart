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
  MyUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    await _initDatabase();
    await _syncData();
    await _loadCompanies();
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

  Future<void> _loadCompanies() async {
    try {
      Map<String, Company>? companyList = await getAllCompanies(db);
      setState(() {
        _companyList = companyList!;
      });

    } catch (e) {
      print("Error loading Companies Names: $e");
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

  bool _isSuperAdmin() {
    return _user?.role == 'superadmin';
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: AppLocalizations.of(context)!.pdfListAdmin,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ListResult>(
        future: getCompanyPdfData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final companyList = snapshot.data!.prefixes;
            if (_isSuperAdmin()) {
              return ListView(
                // padding: EdgeInsets.all(25),
                children: companyList.map((companyRef) {
                  return CompanyTile(
                    companyRef: companyRef,
                    companyName: _companyList[companyRef.name]?.name ?? companyRef.name,
                  );
                }).toList(),
              );
            } else {
              return
                ListView(
                  children: companyList.map((userRef) {
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
      String company = _user!.company;
      return _firePdfReference.child(company).listAll();
    }
  }
}