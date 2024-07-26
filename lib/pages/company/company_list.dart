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

    return Scaffold(
      body: BasePage(
        title: "Companies list",
        body: _buildBody(context),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "addCompanyHero",
        onPressed: () {
          showCompanyModal();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<Map<String, Company>>(
      future: databaseCompanyService.getAllCompanies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No companies found.'));
        }

        Map<String, Company> companies = snapshot.data!;
        return ListView.builder(
          itemCount: companies.length,
          itemBuilder: (context, index) {
            String companyID = companies.keys.elementAt(index);
            Company company = companies[companyID]!;

            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    company.name[0],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  company.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                subtitle: Text(
                  'ID: $companyID',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing: Wrap(
                  spacing: 12, // space between two icons
                 
                ),
              ),
            );
          },
        );
      },
    );
  }

  /*void _showDeleteConfirmation(BuildContext context, String companyID) {
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
              databaseCompanyService.deleteCompant(companyID);
              setState(() {});
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  } */
  
  void showCompanyModal({required Company company, required String companyID}) {}
}
