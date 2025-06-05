import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class AddCamionType extends StatefulWidget {
  CamionType? camionType;
  String? camionTypeID;
  Map<String, String>? availableLolMap;
  Map<String, String>? equipmentLists;
  final VoidCallback? onCamionTypeAdded;

  AddCamionType(
      {super.key,
      this.camionType,
      this.camionTypeID,
      this.onCamionTypeAdded,
      this.availableLolMap,
      this.equipmentLists});

  @override
  State<AddCamionType> createState() => _AddCamionTypeState();
}

class _AddCamionTypeState extends State<AddCamionType> {
  final _formKey = GlobalKey<FormState>();

  late Database db;
  Map<String, bool> equipmentSelection = {};

  final TextEditingController _nameController = TextEditingController();
  List<TextEditingController> _lolControllers = [];
  List<TextEditingController> _equipmentControllers = [];
  List<TextEditingController> _routerControllers = [];
  List<String> lol = [];
  List<String> equipment = [];
  List<String> routerData = [];
  String pageTile = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _initDatabase();
    if (widget.camionType != null) {
      _populateFieldsWithCamionTypeData();
    }
  }

  void _populateFieldsWithCamionTypeData() {
    List<String> tempLol = widget.camionType!.lol ?? [];
    List<String> tempEquipment = widget.camionType!.equipment ?? [];
    List<String> tempRouterData = widget.camionType!.routerData ?? [];
    Map<String, bool> tempEquipmentSelection = {
      for (var key in widget.equipmentLists!.keys)
        key: tempEquipment.contains(key)
    };

    setState(() {
      _nameController.text = widget.camionType!.name;
      lol = tempLol;
      equipment = tempEquipment;
      routerData = tempRouterData;
      _lolControllers =
          tempLol.map((item) => TextEditingController(text: item)).toList();
      _equipmentControllers = tempEquipment
          .map((item) => TextEditingController(text: item))
          .toList();
      _routerControllers = tempRouterData
          .map((item) => TextEditingController(text: item))
          .toList();
      equipmentSelection = tempEquipmentSelection;
    });
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var controller in [
      ..._lolControllers,
      ..._equipmentControllers,
      ..._routerControllers
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addLolField() {
    setState(() {
      _lolControllers.add(TextEditingController());
      lol.add('');
    });
  }

  void _removeLolField(int index) {
    setState(() {
      _lolControllers[index].dispose();
      _lolControllers.removeAt(index);
      lol.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.camionTypeName,
              labelText: AppLocalizations.of(context)!.camionTypeName,
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
          const Text("Add LOL Items:"),
          ..._lolControllers.asMap().entries.map((entry) {
            int index = entry.key;
            return ListTile(
              title: DropdownButtonFormField<String>(
                value: widget.availableLolMap!.containsKey(lol[index])
                    ? lol[index]
                    : null,
                decoration: InputDecoration(
                    labelText: "List of Lists item ${index + 1}"),
                items: widget.availableLolMap!.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    lol[index] = val!;
                  });
                },
              ),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () => _removeLolField(index),
              ),
            );
          }),
          TextButton(
            onPressed: _addLolField,
            child: const Text("Add LOL Item"),
          ),
          const Text("Add Equipment Items:"),
          ...widget.equipmentLists!.entries.map((entry) {
            String equipmentKey = entry.key;
            String equipmentName = entry.value;
            return CheckboxListTile(
              title: Text(equipmentName),
              value: equipmentSelection[equipmentKey] ?? false,
              onChanged: (bool? selected) {
                setState(() {
                  equipmentSelection[equipmentKey] = selected ?? false;
                  selected == true
                      ? equipment.add(equipmentKey)
                      : equipment.remove(equipmentKey);
                });
              },
            );
          }),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  DateTime dateCreation =
                      widget.camionType?.createdAt ?? DateTime.now();
                  CamionType newCamionType = CamionType(
                    name: _nameController.text,
                    lol: lol,
                    equipment: equipment,
                    routerData: routerData,
                    createdAt: dateCreation,
                    updatedAt: DateTime.now(),
                  );

                  if (widget.camionType == null) {
                    insertCamionType(db, newCamionType, "");
                  } else {
                    updateCamionType(db, newCamionType, widget.camionTypeID!);
                  }
                  if (widget.onCamionTypeAdded != null) {
                    widget.onCamionTypeAdded!();
                  }
                } catch (e) {
                  print("Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            AppLocalizations.of(context)!.errorSavingData)),
                  );
                }
              }
            },
            child: Text(widget.camionType == null
                ? AppLocalizations.of(context)!.add
                : AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }
}
