import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/pdf/pdf_show_template.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
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
  MyUser? _user;
  String? _userID;
  Map<String, String>? pdfList;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _initDatabase();
    await _loadUser();
    await _loadPdfs();
  }

  Future<void> _loadUser() async {
    try {
      AuthController authController = AuthController();
      UserService userService = UserService();
      String userId = authController.getCurrentUserUID();
      MyUser user = await userService.getCurrentUserData();
      _user = user;
      _userID = userId;
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _loadPdfs() async {
    if(_user == null){
      return;
    }
    DatabasePDFService databasePDFService = DatabasePDFService();
    pdfList =  await databasePDFService.getUserListOfPDF(_user!.company);
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  @override
  Widget build(BuildContext context) {
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
        return PDFShowTemplate(fileName: fileName, url: url);
      },
    );
  }
}
