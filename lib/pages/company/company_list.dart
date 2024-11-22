import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/company/add_company_form.dart';
import 'package:flutter_application_1/services/database_company_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompanyList extends StatefulWidget {
  const CompanyList({super.key});

  @override
  State<CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {
  final DatabaseCompanyService databaseCompanyService = DatabaseCompanyService();
  Future<MyUser>? _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = getUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MyUser>(
      future: _futureUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          MyUser user = snapshot.data!;
          return Scaffold(
              body: FutureBuilder(
                future: getCompanyPdfData(user),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    Map<String, Company> companyMap = snapshot.data!;
                    return DefaultTabController(
                      initialIndex: 0,
                      length: companyMap.length,
                      child: BasePage(
                        title: title(user),
                        body: _buildBody(companyMap, user),
                      ),
                    );
                  }
                },
              ),
              floatingActionButton: Visibility(
                visible: user.role == 'superadmin',
                child: FloatingActionButton(
                  heroTag: "addCompanyHero",
                  onPressed: () {
                    showCompanyModal();
                  },
                  // backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.add_home_work,
                    color: Colors.white,
                  ),
                ),
              )
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<MyUser> getUser() async {
    UserService userService = UserService();
    return await userService.getCurrentUserData();
  }

  Future<Map<String, Company>> getCompanyPdfData(MyUser user) async {
    if (user.role == 'superadmin') {
      return databaseCompanyService.getAllCompanies();
    } else if (user.role == 'admin') {
      Map<String, Company> companies = HashMap();
      String companyId = user.company;
      Company company = await databaseCompanyService.getCompanyByID(companyId);
      companies.addAll({companyId: company});
      return companies;
    } else {
      Map<String, Company> companies = HashMap();
      return companies;
    }
  }

 Widget _buildBody(Map<String, Company> companyMap, MyUser user) {
  return ListView.builder(
    padding: const EdgeInsets.fromLTRB(8, 8, 8, 50),
    itemCount: companyMap.length,
    itemBuilder: (_, index) {
      // Image ou icône pour l'en-tête
      Widget leading;
      if (companyMap.values.elementAt(index).logo == "") {
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
            companyMap.values.elementAt(index).logo,
            height: 60,
            width: 60,
            fit: BoxFit.cover,
          ),
        );
      }

      // Affichage de l'élément principal
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(12.0),
          child: ExpansionTile(
            leading: leading,
            title: Text(
              companyMap.values.elementAt(index).name,
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
                    company: companyMap.values.elementAt(index),
                    companyID: companyMap.keys.elementAt(index),
                  );
                } else if (value == 'delete') {
                  _showDeleteConfirmation(companyMap.keys.elementAt(index));
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
                if (user.role == "superadmin")
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.delete),
                      ],
                    ),
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
                      "${AppLocalizations.of(context)!.companySiret}: ${companyMap.values.elementAt(index).siret}",
                    ),
                    _buildInfoCard(
                      context,
                      "${AppLocalizations.of(context)!.companySirene}: ${companyMap.values.elementAt(index).sirene}",
                    ),
                    if (companyMap.values.elementAt(index).description.isNotEmpty)
                      _buildInfoCard(
                        context,
                        "${AppLocalizations.of(context)!.companyDescription}: ${companyMap.values.elementAt(index).description}",
                      ),
                    if (companyMap.values.elementAt(index).tel.isNotEmpty)
                      _buildInfoCard(
                        context,
                        "${AppLocalizations.of(context)!.companyPhone}: ${companyMap.values.elementAt(index).tel}",
                      ),
                    if (companyMap.values.elementAt(index).email.isNotEmpty)
                      _buildInfoCard(
                        context,
                        "${AppLocalizations.of(context)!.companyEMail}: ${companyMap.values.elementAt(index).email}",
                      ),
                    if (companyMap.values.elementAt(index).address.isNotEmpty)
                      _buildInfoCard(
                        context,
                        "${AppLocalizations.of(context)!.companyAddress}: ${companyMap.values.elementAt(index).address}",
                      ),
                    if (companyMap.values.elementAt(index).responsible.isNotEmpty)
                      _buildInfoCard(
                        context,
                        "${AppLocalizations.of(context)!.companyResponsible}: ${companyMap.values.elementAt(index).responsible}",
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

String title(MyUser user) {
    if(user.role == "superadmin"){
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
              databaseCompanyService.deleteCompany(companyID);
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
