import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/services/database_company_service.dart';

class AddCompany extends StatefulWidget {

  Company? company;
  String? companyID;
  final VoidCallback? onCompanyAdded;

  AddCompany({super.key, this.company, this.companyID, this.onCompanyAdded});

  @override
  State<AddCompany> createState() => _AddCompanyState();
}

class _AddCompanyState extends State<AddCompany> {

  final _formKey = GlobalKey<FormState>();
  DatabaseCompanyService databaseCompanyService = DatabaseCompanyService();
  String name = "";
  String description = "";
  String sirene = "";
  String siret = "";
  String address = "";
  String responsible = "";
  String admin = "";
  String tel = "";
  String email = "";
  String logo = "";

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget> [
            const Text(
              "Add new company!",
              style: TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 30,
                  color: Colors.green,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Give me name!",
                labelText: "Company name:",
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                ),
                focusedBorder: OutlineInputBorder(gapPadding: 15),
                border: OutlineInputBorder(gapPadding: 5),
              ),
              validator: (val) {return (val == null || val.isEmpty || val == "") ? 'Enter company name:' : null;},
              onChanged: (val) => setState(() {name = val;}),
            ),

            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Give me description!",
                labelText: "Company description:",
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                ),
                focusedBorder: OutlineInputBorder(gapPadding: 15),
                border: OutlineInputBorder(gapPadding: 5),
              ),
              // validator: (val) {return (val == null || val.isEmpty || val == "") ? 'Enter company description:' : null;},
              onChanged: (val) => setState(() {description = val;}),
            ),

            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Give me sirene!",
                labelText: "Company sirene:",
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                ),
                focusedBorder: OutlineInputBorder(gapPadding: 15),
                border: OutlineInputBorder(gapPadding: 5),
              ),
              validator: (val) {return (val == null || val.isEmpty || val == "") ? 'Enter company sirene:' : null;},
              onChanged: (val) => setState(() {sirene = val;}),
            ),

            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Give me siret!",
                labelText: "Company siret:",
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                ),
                focusedBorder: OutlineInputBorder(gapPadding: 15),
                border: OutlineInputBorder(gapPadding: 5),
              ),
              validator: (val) {return (val == null || val.isEmpty || val == "") ? 'Enter company siret:' : null;},
              onChanged: (val) => setState(() {siret = val;}),
            ),

            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Give me address!",
                labelText: "Company address:",
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                ),
                focusedBorder: OutlineInputBorder(gapPadding: 15),
                border: OutlineInputBorder(gapPadding: 5),
              ),
              // validator: (val) {return (val == null || val.isEmpty || val == "") ? 'Enter company address:' : null;},
              onChanged: (val) => setState(() {address = val;}),
            ),

            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Give me responsible!",
                labelText: "Company responsible:",
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                ),
                focusedBorder: OutlineInputBorder(gapPadding: 15),
                border: OutlineInputBorder(gapPadding: 5),
              ),
              // validator: (val) {return (val == null || val.isEmpty || val == "") ? 'Enter company responsible:' : null;},
              onChanged: (val) => setState(() {responsible = val;}),
            ),

            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Give me admin!",
                labelText: "Company admin:",
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                ),
                focusedBorder: OutlineInputBorder(gapPadding: 15),
                border: OutlineInputBorder(gapPadding: 5),
              ),
              // validator: (val) {return (val == null || val.isEmpty || val == "") ? 'Enter company admin:' : null;},
              onChanged: (val) => setState(() {admin = val;}),
            ),

            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Give me tel!",
                labelText: "Company tel:",
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                ),
                focusedBorder: OutlineInputBorder(gapPadding: 15),
                border: OutlineInputBorder(gapPadding: 5),
              ),
              // validator: (val) {return (val == null || val.isEmpty || val == "") ? 'Enter company tel:' : null;},
              onChanged: (val) => setState(() {tel = val;}),
            ),

            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Give me email!",
                labelText: "Company email:",
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                ),
                focusedBorder: OutlineInputBorder(gapPadding: 15),
                border: OutlineInputBorder(gapPadding: 5),
              ),
              // validator: (val) {return (val == null || val.isEmpty || val == "") ? 'Enter company email:' : null;},
              onChanged: (val) => setState(() {email = val;}),
            ),

            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Give me logo!",
                labelText: "Company logo:",
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                ),
                focusedBorder: OutlineInputBorder(gapPadding: 15),
                border: OutlineInputBorder(gapPadding: 5),
              ),
              // validator: (val) {return (val == null || val.isEmpty || val == "") ? 'Enter company logo address:' : null;},
              onChanged: (val) => setState(() {logo = val;}),
            ),

            const SizedBox(height: 50),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(250, 60),
              ),
              child: const Text(
                'Add company',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Company newCompany = Company(name: name, description: description, sirene: sirene, siret: siret, address: address, responsible: responsible, admin: admin, tel: tel, email: email, logo: logo);
                  databaseCompanyService.addCompany(newCompany);
                  if (widget.onCompanyAdded != null) {
                    widget.onCompanyAdded!();
                  }
                }
              }
            ),
          ],
        )
    );
  }
}
