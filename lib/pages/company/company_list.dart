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
        appBar: appBar(),
        body: body(context),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "addCompanyHero",
        onPressed: () {
          showCompanyModal();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.lightGreenAccent,
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
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
        return ListView(
          children: companies.values.map((company) {
            return ListTile(
              title: Text(company.name),
            );
          }).toList(),
        );
      },
    );
  }

  appBar() {
    return AppBar(
      title: const Text('List of all Companies',
        style: TextStyle(
          color: Colors.amber,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.blue[900],
    );
  }
}
