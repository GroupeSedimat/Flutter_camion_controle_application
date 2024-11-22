import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/equipment/equipment.dart';
import 'package:flutter_application_1/services/equipment/database_equipment_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddEquipment extends StatefulWidget {

  Equipment? equipment;
  String? equipmentID;
  final VoidCallback? onEquipmentAdded;

  AddEquipment({super.key, this.equipment, this.equipmentID, this.onEquipmentAdded});

  @override
  State<AddEquipment> createState() => _AddEquipmentState();
}

class _AddEquipmentState extends State<AddEquipment> {

  final _formKey = GlobalKey<FormState>();
  DatabaseEquipmentService databaseEquipmentService = DatabaseEquipmentService();
  String name = "";
  String description = "";
  String pageTile = "";

  @override
  void initState() {
    super.initState();
    if (widget.equipment != null) {
      name = widget.equipment!.name;
      description = widget.equipment!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.equipment != null){
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
                  color: Colors.black,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 20),
            TextFormField(
              initialValue: name,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.equipmentName,
                labelText: AppLocalizations.of(context)!.equipmentName,
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
                hintText: AppLocalizations.of(context)!.details,
                labelText: AppLocalizations.of(context)!.details,
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
                    Equipment newEquipment = Equipment(
                        name: name,
                        description: description
                    );
                    if (widget.equipment == null) {
                      databaseEquipmentService.addEquipment(newEquipment);
                    } else {
                      databaseEquipmentService.updateEquipment(widget.equipmentID!, newEquipment);
                    }
                    if (widget.onEquipmentAdded != null) {
                      widget.onEquipmentAdded!();
                    }
                  }
                }),
          ],
        )
    );
  }
}
