import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/company/add_company_form.dart';
import 'package:flutter_application_1/services/database_company_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CompanyList extends StatefulWidget {
  const CompanyList({Key? key}) : super(key: key);

  @override
  State<CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {
  final DatabaseCompanyService databaseCompanyService =
      DatabaseCompanyService();
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
                  return BasePage(
                    title: title(user),
                    body: AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 50),
                        itemCount: companyMap.length,
                        itemBuilder: (BuildContext context, int index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            child: SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildCompanyItem(
                                    context, companyMap, user, index),
                              ),
                            ),
                          );
                        },
                      ),
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
                child: const Icon(
                  Icons.add_home_work,
                  color: Colors.white,
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildCompanyItem(BuildContext context,
      Map<String, Company> companyMap, MyUser user, int index) {
    Company company = companyMap.values.elementAt(index);
    String companyID = companyMap.keys.elementAt(index);

    Widget leading;
    if (company.logo.isEmpty) {
      leading = Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        width: 60,
        height: 60,
        child: Icon(Icons.home_work,
            color: Theme.of(context).primaryColor, size: 30),
      );
    } else {
      leading = CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(company.logo),
      );
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: leading,
        title: Text(
          company.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
        trailing: PopupMenuButton(
          onSelected: (value) async {
            if (value == 'edit') {
              showCompanyModal(company: company, companyID: companyID);
            } else if (value == 'delete') {
              _showDeleteConfirmation(companyID);
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
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                _buildInfoCard(context,
                    "${AppLocalizations.of(context)!.companySiret}: ${company.siret}"),
                _buildInfoCard(context,
                    "${AppLocalizations.of(context)!.companySirene}: ${company.sirene}"),
                if (company.description.isNotEmpty)
                  _buildInfoCard(context,
                      "${AppLocalizations.of(context)!.companyDescription}: ${company.description}"),
                if (company.tel.isNotEmpty)
                  _buildInfoCard(context,
                      "${AppLocalizations.of(context)!.companyPhone}: ${company.tel}"),
                if (company.email.isNotEmpty)
                  _buildInfoCard(context,
                      "${AppLocalizations.of(context)!.companyEMail}: ${company.email}"),
                if (company.address.isNotEmpty)
                  _buildInfoCard(context,
                      "${AppLocalizations.of(context)!.companyAddress}: ${company.address}"),
                if (company.responsible.isNotEmpty)
                  _buildInfoCard(context,
                      "${AppLocalizations.of(context)!.companyResponsible}: ${company.responsible}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String content) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        content,
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
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

  String title(MyUser user) {
    if (user.role == "superadmin") {
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
            child: Text(AppLocalizations.of(context)!.yes,
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
