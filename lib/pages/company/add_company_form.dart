import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/services/database_company_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  String pageTile = "";

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      name = widget.company!.name;
      description = widget.company!.description;
      sirene = widget.company!.sirene;
      siret = widget.company!.siret;
      address = widget.company!.address;
      responsible = widget.company!.responsible;
      admin = widget.company!.admin;
      tel = widget.company!.tel;
      email = widget.company!.email;
      logo = widget.company!.logo;
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.company != null){
      pageTile = AppLocalizations.of(context)!.companyEdit;
    }else{
      pageTile = AppLocalizations.of(context)!.companyAdd;
    }
    return Form(
      key: _formKey,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget> [
          Text(
            pageTile,
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
            initialValue: name,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyName,
              labelText: AppLocalizations.of(context)!.companyName,
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 15),
              border: OutlineInputBorder(gapPadding: 5),
            ),
            validator: (val) {return (val == null || val.isEmpty || val == "") ? AppLocalizations.of(context)!.required : null;},
            onChanged: (val) => setState(() {name = val;}),
          ),

          const SizedBox(height: 20),
          TextFormField(
            initialValue: description,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyDescription,
              labelText: AppLocalizations.of(context)!.companyDescription,
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 15),
              border: OutlineInputBorder(gapPadding: 5),
            ),
            onChanged: (val) => setState(() {
              description = val;
            }),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: sirene,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companySirene,
              labelText: AppLocalizations.of(context)!.companySirene,
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 15),
              border: OutlineInputBorder(gapPadding: 5),
            ),
            validator: (val) =>
            (val == null || val.isEmpty || val == "") ? AppLocalizations.of(context)!.required : null,
            onChanged: (val) => setState(() {
              sirene = val;
            }),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: siret,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companySiret,
              labelText: AppLocalizations.of(context)!.companySiret,
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 15),
              border: OutlineInputBorder(gapPadding: 5),
            ),
            validator: (val) =>
            (val == null || val.isEmpty || val == "") ? AppLocalizations.of(context)!.required : null,
            onChanged: (val) => setState(() {
              siret = val;
            }),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: address,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyAddress,
              labelText: AppLocalizations.of(context)!.companyAddress,
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 15),
              border: OutlineInputBorder(gapPadding: 5),
            ),
            onChanged: (val) => setState(() {
              address = val;
            }),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: responsible,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyResponsible,
              labelText: AppLocalizations.of(context)!.companyResponsible,
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 15),
              border: OutlineInputBorder(gapPadding: 5),
            ),
            onChanged: (val) => setState(() {
              responsible = val;
            }),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: admin,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyAdmin,
              labelText: AppLocalizations.of(context)!.companyAdmin,
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 15),
              border: OutlineInputBorder(gapPadding: 5),
            ),
            onChanged: (val) => setState(() {
              admin = val;
            }),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: tel,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyPhone,
              labelText: AppLocalizations.of(context)!.companyPhone,
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 15),
              border: OutlineInputBorder(gapPadding: 5),
            ),
            onChanged: (val) => setState(() {
              tel = val;
            }),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: email,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyEMail,
              labelText: AppLocalizations.of(context)!.companyEMail,
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 15),
              border: OutlineInputBorder(gapPadding: 5),
            ),
            onChanged: (val) => setState(() {
              email = val;
            }),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: logo,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyLogo,
              labelText: AppLocalizations.of(context)!.companyLogo,
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 15),
              border: OutlineInputBorder(gapPadding: 5),
            ),
            onChanged: (val) => setState(() {
              logo = val;
            }),
          ),
          const SizedBox(height: 50),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(250, 60),
            ),
            child: Text(
              AppLocalizations.of(context)!.confirm,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Company newCompany = Company(
                    name: name,
                    description: description,
                    sirene: sirene,
                    siret: siret,
                    address: address,
                    responsible: responsible,
                    admin: admin,
                    tel: tel,
                    email: email,
                    logo: logo);
                if (widget.company == null) {
                  databaseCompanyService.addCompany(newCompany);
                } else {
                  databaseCompanyService.updateCompany(widget.companyID!, newCompany);
                }
                if (widget.onCompanyAdded != null) {
                  widget.onCompanyAdded!();
                }
              }
            }),
        ],
      )
    );
  }
}
