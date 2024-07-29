// ignore_for_file: prefer_const_constructors, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/company/add_company_form.dart';
import 'package:flutter_application_1/services/database_company_service.dart';

class CompanyList extends StatefulWidget {
  const CompanyList({super.key});

  @override
  State<CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {
  final DatabaseCompanyService databaseCompanyService = DatabaseCompanyService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FutureBuilder(
        future: databaseCompanyService.getAllCompanies(),
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
                title: "Companies list",
                body: _buildBody(companyMap),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "addCompanyHero",
        onPressed: () {
          showCompanyModal();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add_home_work,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody(Map<String, Company> companyMap) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 50),
      itemCount: companyMap.length,
      itemBuilder: (_, index) {
        Widget leading;
        if (companyMap.values.elementAt(index).logo == "") {
          leading = Icon(Icons.home_work, color: Colors.deepPurple, size: 50);
        } else {
          leading = Image.network(
            companyMap.values.elementAt(index).logo,
            width: 50,
            height: 50,
          );
        }
        return Padding(
          padding: EdgeInsets.all(8),
          child: ExpansionTile(
            leading: leading,
            title: Text(companyMap.values.elementAt(index).name),
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
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
            children: [
              Wrap(
                spacing: 15,
                children: [
                  SizedBox(
                    child: Text(
                        "Siret: ${companyMap.values.elementAt(index).siret}"),
                  ),
                  SizedBox(
                    child: Text(
                        "Sirene: ${companyMap.values.elementAt(index).sirene}"),
                  ),
                  if (companyMap.values.elementAt(index).description != "")
                    SizedBox(
                      child: Text(
                          "Description: ${companyMap.values.elementAt(index).description}"),
                    ),
                  if (companyMap.values.elementAt(index).tel != "")
                    SizedBox(
                      child: Text(
                          "Tel number: ${companyMap.values.elementAt(index).tel}"),
                    ),
                  if (companyMap.values.elementAt(index).email != "")
                    SizedBox(
                      child: Text(
                          "E-mail: ${companyMap.values.elementAt(index).email}"),
                    ),
                  if (companyMap.values.elementAt(index).address != "")
                    SizedBox(
                      child: Text(
                          "Address: ${companyMap.values.elementAt(index).address}"),
                    ),
                  if (companyMap.values.elementAt(index).responsible != "")
                    SizedBox(
                      child: Text(
                          "Responsible person: ${companyMap.values.elementAt(index).responsible}"),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
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
          color: Colors.white,
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
        title: Text('Delete Company'),
        content: Text('Are you sure you want to delete this company?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              databaseCompanyService.deleteCompany(companyID);
              setState(() {});
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
