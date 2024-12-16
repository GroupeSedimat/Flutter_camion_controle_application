import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/services/database_firestore/check_list/database_list_of_lists_service.dart';
import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/equipments_table.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

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

  DatabaseListOfListsService databaseListOfListsService = DatabaseListOfListsService();

  late Database db;

  Map<String, String> availableLolMap = {};
  Map<String, String>? _equipmentLists;
  Map<String, bool> equipmentSelection = {};
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _lolControllers = [];
  final List<TextEditingController> _equipmentControllers = [];
  final List<TextEditingController> _routerControllers = [];
  List<String> lol = [];
  List<String> equipment = [];
  List<String> routerData = [];
  String pageTile = "";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _initDatabase();
    await _syncDatas();
    await Future.wait([_loadEquipments(), _loadListOfLists()]);
    if (widget.camionType != null) {
      _populateFieldsWithCamionTypeData();
    }
  }


  void _populateFieldsWithCamionTypeData() {
    _nameController.text = widget.camionType!.name;
    lol = widget.camionType!.lol ?? [];
    equipment = widget.camionType!.equipment ?? [];
    routerData = widget.camionType!.routerData ?? [];
    _lolControllers.addAll(lol.map((item) => TextEditingController(text: item)));
    _equipmentControllers.addAll(equipment.map((item) => TextEditingController(text: item)));
    _routerControllers.addAll(routerData.map((item) => TextEditingController(text: item)));
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _loadEquipments() async {
    try {
      _equipmentLists = await getAllEquipmentsNames(db);
    } catch (e) {
      print('Error loading equipments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.equipmentErrorLoading)),
      );
    }
  }

  Future<void> _loadListOfLists() async {
    Map<String, ListOfLists> listOfLists = await databaseListOfListsService.getAllListsWithId();
    setState(() {
      availableLolMap = listOfLists.map((key, list) => MapEntry(key, list.listName));
      for (var equipmentKey in _equipmentLists!.keys) {
        equipmentSelection[equipmentKey] = equipment.contains(equipmentKey);
      }
    });
  }

  Future<void> _syncDatas() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("++++ Synchronizing Equipments...");
      await syncService.fullSyncTable("equipments");
      print("++++ Synchronization with SQLite completed.");
    } catch (e) {
      print("++++ Error during synchronization with SQLite: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var controller in _lolControllers) {
      controller.dispose();
    }
    for (var controller in _equipmentControllers) {
      controller.dispose();
    }
    for (var controller in _routerControllers) {
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
          ..._equipmentLists!.entries.map((entry) {
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
                try{
                  DateTime dateCreation = widget.camionType?.createdAt ?? DateTime.now();
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
                }
                catch(e){
                  print("Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.errorSavingData)),
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