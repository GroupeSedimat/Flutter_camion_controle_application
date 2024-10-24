import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/services/camion/database_camion_service.dart';
import 'package:flutter_application_1/services/camion/database_camion_type_service.dart';
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

  DatabaseCamionService databaseCamionService = DatabaseCamionService();
  DatabaseCamionTypeService databaseCamionTypeService = DatabaseCamionTypeService();

  String camionType = "";
  String responsible = "";
  String checks = "";
  String lastIntervention = "";
  String status = "";
  String location = "";
  String company = "";
  String pageTile = "";

  Map<String, CamionType>? _camionTypesMap;
  bool _isLoadingCamionTypes = true;

  @override
  void initState() {
    super.initState();
    if (widget.camion != null) {
      _nameController.text = widget.camion!.name;
      camionType = widget.camion!.camionType;
      responsible = widget.camion!.responsible!;
      checks = widget.camion!.checks!;
      lastIntervention = widget.camion!.lastIntervention!;
      status = widget.camion!.status!;
      location = widget.camion!.location!;
      company = widget.camion!.company;
    }

    _loadCamionTypes();
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

          // Name field without calling setState every time
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

          // DropdownButtonFormField for Camion Types
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
                  responsible: responsible,
                  checks: checks,
                  lastIntervention: lastIntervention,
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