import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class AddCamion extends StatefulWidget {

  Camion? camion;
  String? camionID;
  String? role;
  final VoidCallback? onCamionAdded;

  AddCamion({super.key, this.camion, this.camionID, this.onCamionAdded, this.role});

  @override
  State<AddCamion> createState() => _AddCamionState();
}

class _AddCamionState extends State<AddCamion> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _responsibleController = TextEditingController();
  final TextEditingController _lastInterventionController = TextEditingController();

  late Database db;

  String camionType = "";
  String status = "";
  String location = "";
  String company = "";
  String pageTile = "";
  String role = "";

  List<DateTime> checks = [];
  Map<String, CamionType>? _camionTypesMap;
  Map<String, String>? _companyNamesMap;
  bool _isLoadingCamionTypes = true;
  bool _isLoadingCompanies = true;
  final List<String> statusOptions = ["sur la route", "arrêt", "réparation", "pour réparation", "inactif"];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _initDatabase();
    await Future.wait([_loadCamionTypes(), _loadCompanyNames()]);
    if (widget.camion != null) {
      _populateFieldsWithCamionData();
    }
  }

  void _populateFieldsWithCamionData() {
    role = widget.role ?? "";
    _nameController.text = widget.camion!.name;
    _responsibleController.text = widget.camion!.responsible!;
    _lastInterventionController.text = widget.camion!.lastIntervention!;
    checks = widget.camion!.checks ?? [];
    camionType = widget.camion!.camionType;
    status = widget.camion!.status!;
    location = widget.camion!.location!;
    company = widget.camion!.company;
  }

  Future<void> _loadCamionTypes() async {
    try {
      Map<String, CamionType>? camionTypes = await getAllCamionTypes(db, role);
      setState(() {
        _camionTypesMap = camionTypes;
        _isLoadingCamionTypes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCamionTypes = false;
      });
      print('Error loading camion types: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.camionTypeErrorLoading)),
      );
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _loadCompanyNames() async {
    try {
      Map<String, String>? companies = await getAllCompaniesNames(db, role);
      setState(() {
        _companyNamesMap = companies;
        _isLoadingCompanies = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCompanies = false;
      });
      print('Error loading companies: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.companyErrorLoading)),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _responsibleController.dispose();
    _lastInterventionController.dispose();
    super.dispose();
  }

  Future<DateTime?> _selectDateTime([DateTime? initialDate]) async {
    DateTime selectedDate = initialDate ?? DateTime.now();

    // Pick a date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2222),
    );

    if (pickedDate != null) {
      // Pick a time
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );

      if (pickedTime != null) {
        // Combine picked date and time
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
    return null;
  }

  Widget buildDropdownField({
    required String labelText,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    String? value,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          fontSize: 20,
          color: Colors.lightBlue,
          backgroundColor: Colors.white,
        ),
        focusedBorder: const OutlineInputBorder(gapPadding: 15),
        border: const OutlineInputBorder(gapPadding: 5),
      ),
      items: items,
      onChanged: onChanged,
      validator: (value) {
        return (value == null || value.isEmpty)
            ? AppLocalizations.of(context)!.required
            : null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.camion != null) {
      pageTile = AppLocalizations.of(context)!.edit;
    } else {
      pageTile = AppLocalizations.of(context)!.add;
    }

    return Form(
      key: _formKey,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Text(
            pageTile,
            style: const TextStyle(
              backgroundColor: Colors.white,
              fontSize: 30,
              color: Colors.green,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Name field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.camionName,
              labelText: AppLocalizations.of(context)!.camionName,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
            validator: (val) {
              return (val == null || val.isEmpty || val == "")
                  ? AppLocalizations.of(context)!.required
                  : null;
            },
          ),

          const SizedBox(height: 20),

          // Camion Type Dropdown
          _isLoadingCamionTypes
            ? const CircularProgressIndicator()
            : _camionTypesMap == null || _camionTypesMap!.isEmpty
            ? Text(AppLocalizations.of(context)!.userDataNotFound)
            : buildDropdownField(
                labelText: AppLocalizations.of(context)!.camionType,
                items: _camionTypesMap!.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    camionType = value ?? '';
                  });
                },
                value: camionType.isNotEmpty ? camionType : null
              ),

          const SizedBox(height: 20),

          // Responsible field
          TextFormField(
            controller: _responsibleController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.camionResponsible,
              labelText: AppLocalizations.of(context)!.camionResponsible,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
            validator: (val) {
              return (val == null || val.isEmpty)
                  ? AppLocalizations.of(context)!.required
                  : null;
            },
          ),

          const SizedBox(height: 20),

          // Checks field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.camionChecks,
              style: const TextStyle(fontSize: 20, color: Colors.lightBlue),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: checks.length,
              itemBuilder: (context, index) {
                DateTime date = checks[index];
                return ListTile(
                  title: Text('${date.toLocal()}'.split('.')[0]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        checks.removeAt(index);
                      });
                    },
                  ),
                  onTap: () async {
                    DateTime? updatedDate = await _selectDateTime(date);
                    if (updatedDate != null) {
                      setState(() {
                        checks[index] = updatedDate;
                      });
                    }
                  },
                );
              },
            ),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await _selectDateTime();
                if (pickedDate != null) {
                  setState(() {
                    checks.add(pickedDate);
                  });
                }
              },
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        ),

          const SizedBox(height: 20),

          // Last Intervention field
          TextFormField(
            controller: _lastInterventionController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.camionLastIntervention,
              labelText: AppLocalizations.of(context)!.camionLastIntervention,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
          ),

          const SizedBox(height: 20),

          // Status Dropdown
          buildDropdownField(
            labelText: AppLocalizations.of(context)!.status,
            items: statusOptions.map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                status = value ?? '';
              });
            },
            value: status.isNotEmpty ? status : null
          ),

          const SizedBox(height: 20),

          // Company Dropdown
          _isLoadingCompanies
            ? const CircularProgressIndicator()
            : _companyNamesMap == null || _companyNamesMap!.isEmpty
            ? Text(AppLocalizations.of(context)!.userDataNotFound)
            : buildDropdownField(
                labelText: AppLocalizations.of(context)!.company,
                items: _companyNamesMap!.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    company = value ?? '';
                  });
                },
                value: company.isNotEmpty ? company : null
              ),

          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try{
                  DateTime dateCreation = widget.camion?.createdAt ?? DateTime.now();

                          Camion newCamion = Camion(
                            name: _nameController.text,
                            camionType: camionType,
                            responsible: _responsibleController.text,
                            checks: checks,
                            lastIntervention: _lastInterventionController.text,
                            status: status,
                            location: location,
                            company: company,
                            createdAt: dateCreation,
                            updatedAt: DateTime.now(),
                          );

                  if (widget.camion == null) {
                    insertCamion(db, newCamion, "");
                  } else {
                    updateCamion(db, newCamion, widget.camionID!);
                  }
                  if (widget.onCamionAdded != null) {
                    widget.onCamionAdded!();
                  }
                }
                catch(e){
                  print("Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.errorSavingData)),
                  );
                }
              }
            },
            child: Text(widget.camion == null
                ? AppLocalizations.of(context)!.add
                : AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }
}