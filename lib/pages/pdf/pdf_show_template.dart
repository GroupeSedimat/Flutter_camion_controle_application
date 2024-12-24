import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/pdf/pdf_download.dart';
import 'package:flutter_application_1/pages/pdf/pdf_open.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class PDFShowTemplate extends StatefulWidget {
  final String fileName;
  final String url;

  PDFShowTemplate({super.key, required this.fileName, required this.url});

  @override
  State<PDFShowTemplate> createState() => _PDFShowTemplateState();
}

class _PDFShowTemplateState extends State<PDFShowTemplate> {
  late Company _company;
  late Database db;
  MyUser? _user;

  @override
  void initState() async {
    super.initState();
    _loadUser();
    _loadDataFromDatabase();
  }


  Future<void> _loadDataFromDatabase() async {
    await _initDatabase();
    await _syncData();
    await _loadCompanies();
  }

  Future<MyUser> getUser() async {
    UserService userService = UserService();
    return await userService.getCurrentUserData();
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _loadUser() async {
    try {
      MyUser user = await getUser();
      setState(() {
        _user = user;
      });
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _loadCompanies() async {
    try {
      Company? company = await getOneCompanyWithID(db, _user!.company);
      setState(() {
        _company = company!;
      });

    } catch (e) {
      print("Error loading Companies Names: $e");
    }
  }

  Future<void> _syncData() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("++++ Synchronizing Companies...");
      await syncService.fullSyncTable("companies");
      print("++++ Synchronization with SQLite completed.");
    } catch (e) {
      print("++++ Error during synchronization with SQLite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    int timestamp = int.parse(widget.fileName);
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(date);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.person, color: Colors.deepPurple, size: 50),
                title: Text(
                  "User: ${_user?.username}",
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.companyWithName(_company.name),
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                AppLocalizations.of(context)!.dateCreation(formattedDate),
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        PDFOpen open = PDFOpen(url: widget.url);
                        open.openPDF();
                      },
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text(AppLocalizations.of(context)!.open),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        PdfDownload(
                            name: "${_user?.username}.${widget.fileName}",
                            url: widget.url)
                            .downloadFile();
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(AppLocalizations.of(context)!.download),
                              content: Text(AppLocalizations.of(context)!.pdfDownloaded(_user!.username, widget.fileName)),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(AppLocalizations.of(context)!.ok))
                              ],
                            ));
                      },
                      icon: Icon(Icons.download),
                      label: Text(AppLocalizations.of(context)!.download),
                    ),
                  ),
                ],
              )


            ],
          ),
        ),
      ),
    );
  }
}
