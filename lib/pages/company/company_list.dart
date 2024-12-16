import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/company/add_company_form.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class CompanyList extends StatefulWidget {
  const CompanyList({super.key});

  @override
  State<CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {
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
    Map<String, Company>? companyList = {};
    if(_isSuperAdmin()){
      companyList = await getAllCompanies(db);
    }else{
      Company? company = await getOneCompanyWithID(db, _user!.company);
      companyList[_user!.company] = company!;
    }
    setState(() {
      _companyList = companyList!;
    });
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

  bool _isSuperAdmin() {
    return _user?.role == 'superadmin';
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null || _companyList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
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

  Future<MyUser> getUser() async {
    UserService userService = UserService();
    return await userService.getCurrentUserData();
  }

  Widget _buildBody() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 50),
      itemCount: _companyList.length,
      itemBuilder: (_, index) {
        Widget leading;
        if (_companyList.values.elementAt(index).logo == "" || _companyList.values.elementAt(index).logo == null) {
          leading = Icon(Icons.home_work, color: Colors.deepPurple, size: 60);
        } else {
          leading = Image.network(
            _companyList.values.elementAt(index).logo!,
            height: 60,
          );
        }
        return Padding(
          padding: EdgeInsets.all(8),
          child: ExpansionTile(
            leading: leading,
            title: Text(_companyList.values.elementAt(index).name, style: TextStyle(fontSize: 24, color:Theme.of(context).primaryColor, ),),
            trailing: PopupMenuButton(
              onSelected: (value) async {
                if (value == 'edit') {
                  showCompanyModal(
                    company: _companyList.values.elementAt(index),
                    companyID: _companyList.keys.elementAt(index),
                  );
                } else if (value == 'delete') {
                  _showDeleteConfirmation(_companyList.keys.elementAt(index));
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(AppLocalizations.of(context)!.edit),
                ),
                if(_isSuperAdmin())
                PopupMenuItem(
                  value: 'delete',
                  child: Text(AppLocalizations.of(context)!.delete),
                ),
              ],
            ),
            children: [
              Wrap(
                spacing: 15,
                children: [
                  SizedBox(
                    child: Text(
                      "${AppLocalizations.of(context)!.companySiret}: ${_companyList.values.elementAt(index).siret}",
                      style: textStyle(),
                    ),
                  ),
                  SizedBox(
                    child: Text(
                      "${AppLocalizations.of(context)!.companySirene}: ${_companyList.values.elementAt(index).sirene}",
                      style: textStyle(),
                    ),
                  ),
                  if (_companyList.values.elementAt(index).description != "")
                  SizedBox(
                    child: Text(
                      "${AppLocalizations.of(context)!.companyDescription}: ${_companyList.values.elementAt(index).description}",
                      style: textStyle(),
                    ),
                  ),
                  if (_companyList.values.elementAt(index).tel != "")
                  SizedBox(
                    child: Text(
                      "${AppLocalizations.of(context)!.companyPhone}: ${_companyList.values.elementAt(index).tel}",
                      style: textStyle(),
                    ),
                  ),
                  if (_companyList.values.elementAt(index).email != "")
                  SizedBox(
                    child: Text(
                      "${AppLocalizations.of(context)!.companyEMail}: ${_companyList.values.elementAt(index).email}",
                      style: textStyle(),
                    ),
                  ),
                  if (_companyList.values.elementAt(index).address != "")
                  SizedBox(
                    child: Text(
                      "${AppLocalizations.of(context)!.companyAddress}: ${_companyList.values.elementAt(index).address}",
                      style: textStyle(),
                    ),
                  ),
                  if (_companyList.values.elementAt(index).responsible != "")
                  SizedBox(
                    child: Text(
                      "${AppLocalizations.of(context)!.companyResponsible}: ${_companyList.values.elementAt(index).responsible}",
                      style: textStyle(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  TextStyle textStyle(){
    return TextStyle(fontSize: 20);
  }

  String title() {
    if(_isSuperAdmin()){
      return AppLocalizations.of(context)!.companyList;
    }else{
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
              10, 50, 10, MediaQuery.of(context).viewInsets.bottom
          ),
          child: AddCompany(
            company: company,
            companyID: companyID,
            onCompanyAdded: () {
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
            onPressed: () {
              softDeleteCompany(db, companyID);
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.yes, style: TextStyle(color: Colors.red)),
              // AppLocalizations.of(context)!
          ),
        ],
      ),
    );
  }
}
