import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/company/add_company_form.dart';
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

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CompanyList extends StatefulWidget {
  const CompanyList({Key? key}) : super(key: key);

  @override
  State<CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {
  late Database db;
  late MyUser _user;
  late String _userId;
  bool _isLoading = true;
  Map<String, Company> _companyList = HashMap();
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
    } else {
      await _loadUserToConnection();
    }
    await _loadUser();
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible");
    }
    {
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
    if (users != null) {
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
      _userId = userId;
      _user = user;
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _syncData() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Users...");
      await syncService.fullSyncTable("users", user: _user, userId: _userId);
      print("💽 Synchronizing Companies...");
      await syncService.fullSyncTable("companies",
          user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }

  Future<void> _loadDataFromDatabase() async {
    await _loadCompanyList();
  }

  Future<void> _loadCompanyList() async {
    Map<String, Company>? companyList = await getAllCompanies(db, _user.role);
    if (companyList != null) {
      _companyList = companyList;
    }
  }

  bool _isSuperAdmin() {
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

    return Scaffold(
      body: BasePage(
        title: title(),
        body: _buildBody(),
      ),
      floatingActionButton: Visibility(
        visible: _isSuperAdmin(),
        child: FloatingActionButton(
          heroTag: "addCompanyHero",
          onPressed: () {
            showCompanyModal();
          },
          child: const Icon(Icons.fire_truck, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 50),
      itemCount: _companyList.length,
      itemBuilder: (_, index) {
        Widget leading;
        if (_companyList.values.elementAt(index).logo == "" ||
            _companyList.values.elementAt(index).logo == null) {
          leading = Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.home_work, color: Colors.black, size: 50),
          );
        } else {
          leading = ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              _companyList.values.elementAt(index).logo!,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          );
        }
        String isDeleted = "";
        if (_companyList.values.elementAt(index).deletedAt != null) {
          isDeleted = " (deleted)";
        }
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12.0),
            child: ExpansionTile(
              leading: leading,
              title: Text(
                "${_companyList.values.elementAt(index).name}$isDeleted",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              trailing: PopupMenuButton(
                onSelected: (value) async {
                  if (value == 'edit') {
                    showCompanyModal(
                      company: _companyList.values.elementAt(index),
                      companyID: _companyList.keys.elementAt(index),
                    );
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(_companyList.keys.elementAt(index));
                  } else if (value == 'restore') {
                    await restoreCompany(
                        db, _companyList.keys.elementAt(index));
                    if (networkService.isOnline) {
                      await _syncCompanies();
                    }
                    await _loadDataFromDatabase();
                    setState(() {});
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.edit),
                      ],
                    ),
                  ),
                  if (_isSuperAdmin())
                    _companyList.values.elementAt(index).deletedAt == null
                        ? PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.delete),
                              ],
                            ),
                          )
                        : PopupMenuItem(
                            value: 'restore',
                            child: Text(AppLocalizations.of(context)!.restore),
                          ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      // Informations principales affichées sous forme de cartes
                      _buildInfoCard(
                        context,
                        "${AppLocalizations.of(context)!.companySiret}: ${_companyList.values.elementAt(index).siret}",
                      ),
                      _buildInfoCard(
                        context,
                        "${AppLocalizations.of(context)!.companySirene}: ${_companyList.values.elementAt(index).sirene}",
                      ),
                      if (_companyList.values.elementAt(index).description !=
                          "")
                        _buildInfoCard(
                          context,
                          "${AppLocalizations.of(context)!.companyDescription}: ${_companyList.values.elementAt(index).description}",
                        ),
                      if (_companyList.values.elementAt(index).tel != "")
                        _buildInfoCard(
                          context,
                          "${AppLocalizations.of(context)!.companyPhone}: ${_companyList.values.elementAt(index).tel}",
                        ),
                      if (_companyList.values.elementAt(index).email != "")
                        _buildInfoCard(
                          context,
                          "${AppLocalizations.of(context)!.companyEMail}: ${_companyList.values.elementAt(index).email}",
                        ),
                      if (_companyList.values.elementAt(index).address != "")
                        _buildInfoCard(
                          context,
                          "${AppLocalizations.of(context)!.companyAddress}: ${_companyList.values.elementAt(index).address}",
                        ),
                      if (_companyList.values.elementAt(index).responsible !=
                          "")
                        _buildInfoCard(
                          context,
                          "${AppLocalizations.of(context)!.companyResponsible}: ${_companyList.values.elementAt(index).responsible}",
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
    );
  }

  String title() {
    if (_isSuperAdmin()) {
      return AppLocalizations.of(context)!.companyList;
    } else {
      return AppLocalizations.of(context)!.details;
    }
  }

  void showCompanyModal({
    Company? company,
    String? companyID,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.fromLTRB(
              10, 50, 10, MediaQuery.of(context).viewInsets.bottom),
          child: AddCompany(
            company: company,
            companyID: companyID,
            onCompanyAdded: () async {
              if (networkService.isOnline) {
                await _syncCompanies();
              }
              await _loadDataFromDatabase();
              setState(() {});
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(String companyID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDelete),
        content: Text(AppLocalizations.of(context)!.confirmDeleteText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.no),
          ),
          TextButton(
            onPressed: () async {
              await softDeleteCompany(db, companyID);
              if (networkService.isOnline) {
                await _syncCompanies();
              }
              await _loadDataFromDatabase();
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.yes,
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _syncCompanies() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Companies...");
      await syncService.fullSyncTable("companies",
          user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }
}
