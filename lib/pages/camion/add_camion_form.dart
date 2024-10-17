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
  DatabaseCamionService databaseCamionService = DatabaseCamionService();
  DatabaseCamionTypeService databaseCamionTypeService = DatabaseCamionTypeService();
  String name = "";
  String camionType = "";
  String responsible = "";
  String checks = "";
  String lastIntervention = "";
  String status = "";
  String location = "";
  String company = "";
  String pageTile = "";

  @override
  void initState() {
    super.initState();
    if (widget.camion != null) {
      name = widget.camion!.name;
      camionType = widget.camion!.camionType;
      responsible = widget.camion!.responsible;
      checks = widget.camion!.checks;
      lastIntervention = widget.camion!.lastIntervention;
      status = widget.camion!.status;
      location = widget.camion!.location;
      company = widget.camion!.company;
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.camion != null){
      pageTile = AppLocalizations.of(context)!.edit;
    }else{
      pageTile = AppLocalizations.of(context)!.add;
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
              hintText: AppLocalizations.of(context)!.camionName,
              labelText: AppLocalizations.of(context)!.camionName,
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
          FutureBuilder<Map<String, CamionType>>(
            future: databaseCamionTypeService.getAllCamionTypes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text(AppLocalizations.of(context)!.userDataNotFound);
              } else {
                Map<String, CamionType> camionTypesMap = snapshot.data!;

                return DropdownButtonFormField<String>(
                  value: camionType.isNotEmpty ? camionType : null,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.camionType,
                    labelStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.lightBlue,
                      backgroundColor: Colors.white,
                    ),
                    focusedBorder: OutlineInputBorder(gapPadding: 15),
                    border: OutlineInputBorder(gapPadding: 5),
                  ),
                  items: camionTypesMap.entries.map((entry) {
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
                    return (value == null || value.isEmpty) ? AppLocalizations.of(context)!.required : null;
                  },
                );
              }
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
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Camion newCamion = Camion(
                    name: name,
                    camionType: camionType,
                    responsible: responsible,
                    checks: checks,
                    lastIntervention: lastIntervention,
                    status: status,
                    location: location,
                    company: company
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
            }),
        ],
      )
    );
  }
}
