import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/services/camion/database_camion_service.dart';
import 'package:flutter_application_1/services/camion/database_camion_type_service.dart';
import 'package:flutter_application_1/services/database_company_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddCamion extends StatefulWidget {

  Camion? camion;
  String? camionID;
  final VoidCallback? onCamionAdded;

  AddCamion({super.key, this.camion, this.camionID, this.onCamionAdded});

  @override
  State<AddCamion> createState() => _AddCamionState();
}

class _AddCamionState extends State<AddCamion> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _responsibleController = TextEditingController();
  final TextEditingController _lastInterventionController = TextEditingController();

  DatabaseCamionService databaseCamionService = DatabaseCamionService();
  DatabaseCamionTypeService databaseCamionTypeService = DatabaseCamionTypeService();
  DatabaseCompanyService databaseCompanyService = DatabaseCompanyService();

  String camionType = "";
  String status = "";
  String location = "";
  String company = "";
  String pageTile = "";

  List<DateTime> checks = [];
  Map<String, CamionType>? _camionTypesMap;
  Map<String, String>? _companyNamesMap;
  bool _isLoadingCamionTypes = true;
  bool _isLoadingCompanies = true;
  final List<String> statusOptions = ["sur la route", "arrêt", "réparation", "pour réparation", "inactif"];

  @override
  void initState() {
    super.initState();
    if (widget.camion != null) {
      _nameController.text = widget.camion!.name;
      _responsibleController.text = widget.camion!.responsible!;
      _lastInterventionController.text = widget.camion!.lastIntervention!;
      checks = widget.camion!.checks ?? [];
      camionType = widget.camion!.camionType;
      status = widget.camion!.status!;
      location = widget.camion!.location!;
      company = widget.camion!.company;
    }

    _loadCamionTypes();
    _loadCompanyNames();
  }

  Future<void> _loadCamionTypes() async {
    try {
      Map<String, CamionType> camionTypes = await databaseCamionTypeService.getAllCamionTypes();
      setState(() {
        _camionTypesMap = camionTypes;
        _isLoadingCamionTypes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCamionTypes = false;
      });
      print('Error loading camion types: $e');
    }
  }

  Future<void> _loadCompanyNames() async {
    try {
      Map<String, String> companies = await databaseCompanyService.getAllCompaniesNames();
      setState(() {
        _companyNamesMap = companies;
        _isLoadingCompanies = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCompanies = false;
      });
      print('Error loading companies: $e');
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
      lastDate: DateTime(2101),
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
              color: Colors.black,
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
              ? const CircularProgressIndicator() // Pokazanie loadinga, jeśli typy się ładują
              : _camionTypesMap == null || _camionTypesMap!.isEmpty
              ? Text(AppLocalizations.of(context)!.userDataNotFound) // W przypadku braku danych
              : DropdownButtonFormField<String>(
            value: camionType.isNotEmpty ? camionType : null,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.camionType,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
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
            validator: (value) {
              return (value == null || value.isEmpty)
                  ? AppLocalizations.of(context)!.required
                  : null;
            },
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
          Text(
            AppLocalizations.of(context)!.camionChecks,
            style: const TextStyle(fontSize: 20, color: Colors.lightBlue),
          ),
          Wrap(
            spacing: 5,
            children: checks.map((date) {
              return GestureDetector(
                onTap: () async {
                  // Open date and time picker for editing
                  DateTime? updatedDate = await _selectDateTime(date);
                  if (updatedDate != null) {
                    setState(() {
                      // Replace old date with the updated one
                      int index = checks.indexOf(date);
                      checks[index] = updatedDate;
                    });
                  }
                },
                child: Chip(
                  label: Text('${date.toLocal()}'.split('.')[0]), // Display full date and time
                  onDeleted: () {
                    setState(() {
                      checks.remove(date);
                    });
                  },
                ),
              );
            }).toList(),
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
          DropdownButtonFormField<String>(
            value: status.isNotEmpty ? status : null,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.status,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
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
            validator: (value) {
              return (value == null || value.isEmpty)
                  ? AppLocalizations.of(context)!.required
                  : null;
            },
          ),

          const SizedBox(height: 20),

          // Company Dropdown
          _isLoadingCompanies
              ? const CircularProgressIndicator()
              : _companyNamesMap == null || _companyNamesMap!.isEmpty
              ? Text(AppLocalizations.of(context)!.userDataNotFound)
              : DropdownButtonFormField<String>(
            value: company.isNotEmpty ? company : null,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.company,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
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
            validator: (value) {
              return (value == null || value.isEmpty)
                  ? AppLocalizations.of(context)!.required
                  : null;
            },
          ),

          const SizedBox(height: 50),

          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(250, 60),
            ),
            child: Text(
              AppLocalizations.of(context)!.confirm,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Camion newCamion = Camion(
                  name: _nameController.text,
                  camionType: camionType,
                  responsible: _responsibleController.text,
                  checks: checks,
                  lastIntervention: _lastInterventionController.text,
                  status: status,
                  location: location,
                  company: company,
                );
                if (widget.camion == null) {
                  databaseCamionService.addCamion(newCamion);
                } else {
                  databaseCamionService.updateCamion(widget.camionID!, newCamion);
                }
                if (widget.onCamionAdded != null) {
                  widget.onCamionAdded!();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}