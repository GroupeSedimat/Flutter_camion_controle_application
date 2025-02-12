import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

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
  late Database db;
  bool _isLoading = true;
  String pageTile = "";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _sireneController = TextEditingController();
  final TextEditingController _siretController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _responsibleController = TextEditingController();
  final TextEditingController _adminController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _logoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _initDatabase();
    if (widget.company != null) {
      _populateFieldsWithEquipmentData();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  void _populateFieldsWithEquipmentData() {
    _nameController.text = widget.company!.name;
    _descriptionController.text = widget.company!.description ?? '';
    _sireneController.text = widget.company!.sirene ?? '';
    _siretController.text = widget.company!.siret ?? '';
    _addressController.text = widget.company!.address ?? '';
    _responsibleController.text = widget.company!.responsible ?? '';
    _adminController.text = widget.company!.admin ?? '';
    _telController.text = widget.company!.tel ?? '';
    _emailController.text = widget.company!.email ?? '';
    /// todo repair logo!
    _logoController.text = widget.company!.logo ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sireneController.dispose();
    _siretController.dispose();
    _addressController.dispose();
    _responsibleController.dispose();
    _adminController.dispose();
    _telController.dispose();
    _emailController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Drawer(
          child: Container(
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
        ),
      );
    }

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
            controller: _nameController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyName,
              labelText: AppLocalizations.of(context)!.companyName,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
          ),const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyDescription,
              labelText: AppLocalizations.of(context)!.companyDescription,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
          ),const SizedBox(height: 20),
          TextFormField(
            controller: _sireneController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companySirene,
              labelText: AppLocalizations.of(context)!.companySirene,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
          ),const SizedBox(height: 20),
          TextFormField(
            controller: _siretController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companySiret,
              labelText: AppLocalizations.of(context)!.companySiret,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
          ),const SizedBox(height: 20),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyAddress,
              labelText: AppLocalizations.of(context)!.companyAddress,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
          ),const SizedBox(height: 20),
          TextFormField(
            controller: _responsibleController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyResponsible,
              labelText: AppLocalizations.of(context)!.companyResponsible,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
          ),const SizedBox(height: 20),
          TextFormField(
            controller: _adminController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyAdmin,
              labelText: AppLocalizations.of(context)!.companyAdmin,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
          ),const SizedBox(height: 20),
          TextFormField(
            controller: _telController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyPhone,
              labelText: AppLocalizations.of(context)!.companyPhone,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
          ),const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyEMail,
              labelText: AppLocalizations.of(context)!.companyEMail,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
          ),const SizedBox(height: 20),
          TextFormField(
            controller: _logoController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.companyLogo,
              labelText: AppLocalizations.of(context)!.companyLogo,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
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
              try{
                if (_formKey.currentState!.validate()) {
                  DateTime dateCreation = widget.company?.createdAt ?? DateTime.now();
                  Company newCompany = Company(
                    name: _nameController.text,
                    description: _descriptionController.text,
                    sirene: _sireneController.text,
                    siret: _siretController.text,
                    address: _addressController.text,
                    responsible: _responsibleController.text,
                    admin: _adminController.text,
                    tel: _telController.text,
                    email: _emailController.text,
                    logo: _logoController.text,
                    createdAt: dateCreation,
                    updatedAt: DateTime.now(),
                  );
                  if (widget.company == null) {
                    insertCompany(db, newCompany, "");
                  } else {
                    updateCompany(db, newCompany, widget.companyID!);
                  }
                  if (widget.onCompanyAdded != null) {
                    widget.onCompanyAdded!();
                  }
                }
              }
              catch(e){
                print("Error: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.errorSavingData)),
                );
              }
            }),
        ],
      )
    );
  }
}
