import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/services/camion/database_camion_type_service.dart';
import 'package:flutter_application_1/services/check_list/database_list_of_lists_service.dart';
import 'package:flutter_application_1/services/equipment/database_equipment_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddCamionType extends StatefulWidget {

  CamionType? camionType;
  String? camionTypeID;
  final VoidCallback? onCamionTypeAdded;

  AddCamionType({super.key, this.camionType, this.camionTypeID, this.onCamionTypeAdded});

  @override
  State<AddCamionType> createState() => _AddCamionTypeState();
}

class _AddCamionTypeState extends State<AddCamionType> {

  final _formKey = GlobalKey<FormState>();
  DatabaseCamionTypeService databaseCamionTypeService = DatabaseCamionTypeService();
  DatabaseListOfListsService databaseListOfListsService = DatabaseListOfListsService();
  DatabaseEquipmentService databaseEquipmentService = DatabaseEquipmentService();
  Map<String, String> availableLolMap = {};
  Map<String, String> availableEquipmentItems = {};
  Map<String, bool> equipmentSelection = {};
  final List<TextEditingController> _lolControllers = [];
  final List<TextEditingController> _equipmentControllers = [];
  String name = "";
  List<String> lol = [];
  List<String> equipment = [];
  List<String> routerData = [];
  String pageTile = "";

  @override
  void initState() {
    super.initState();
    if (widget.camionType != null) {
      name = widget.camionType!.name;
      lol = widget.camionType!.lol;
      equipment = widget.camionType!.equipment;
      routerData = widget.camionType!.routerData;
      _lolControllers.addAll(lol.map((item) => TextEditingController(text: item)));
      _equipmentControllers.addAll(equipment.map((item) => TextEditingController(text: item)));
    }
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    Map<String, ListOfLists> listOfLists = await databaseListOfListsService.getAllListsWithId();
    Map<String, String> equipmentLists = await databaseEquipmentService.getAllEquipmentsKeyAndName();

    setState(() {
      availableLolMap = listOfLists.map((key, list) => MapEntry(key, list.listName));
      availableEquipmentItems = equipmentLists;
      for (var equipmentKey in availableEquipmentItems.keys) {
        equipmentSelection[equipmentKey] = equipment.contains(equipmentKey);
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _lolControllers) {
      controller.dispose();
    }
    for (var controller in _equipmentControllers) {
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
            initialValue: name,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.camionTypeName,
            ),
            validator: (val) {
              return (val == null || val.isEmpty) ? AppLocalizations.of(context)!.required : null;
            },
            onChanged: (val) => setState(() {
              name = val;
            }),
          ),
          const SizedBox(height: 20),

          const Text("Add LOL Items:"),
          ..._lolControllers.asMap().entries.map((entry) {
            int index = entry.key;
            return ListTile(
              title: DropdownButtonFormField<String>(
                value: availableLolMap.containsKey(lol[index]) ? lol[index] : null,
                decoration: InputDecoration(labelText: "List of Lists item ${index + 1}"),
                items: availableLolMap.entries.map((entry) {
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
          }).toList(),
          TextButton(
            onPressed: _addLolField,
            child: const Text("Add LOL Item"),
          ),

          const Text("Add Equipment Items:"),
          ...availableEquipmentItems.entries.map((entry) {
            String equipmentKey = entry.key;
            String equipmentName = entry.value;
            return CheckboxListTile(
              title: Text(equipmentName),
              value: equipmentSelection[equipmentKey] ?? false,
              onChanged: (bool? selected) {
                setState(() {
                  equipmentSelection[equipmentKey] = selected!;
                  if (selected) {
                    equipment.add(equipmentKey);
                  } else {
                    equipment.remove(equipmentKey);
                  }
                });
              },
            );
          }).toList(),

          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                CamionType newCamionType = CamionType(
                  name: name,
                  lol: lol,
                  equipment: equipment,
                  routerData: routerData,
                );
                if (widget.camionType == null) {
                  databaseCamionTypeService.addCamionType(newCamionType);
                } else {
                  databaseCamionTypeService.updateCamionType(widget.camionTypeID!, newCamionType);
                }
                if (widget.onCamionTypeAdded != null) {
                  widget.onCamionTypeAdded!();
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