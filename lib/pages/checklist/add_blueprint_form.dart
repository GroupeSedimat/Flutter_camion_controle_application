import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/check_list/blueprints_table.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class AddBlueprintForm extends StatefulWidget {
  final int nrOfList;
  final int nrEntryPosition;
  final Blueprint? blueprint;
  final String? blueprintID;
  final VoidCallback? onBlueprintAdded;

  const AddBlueprintForm({
    super.key,
    required this.nrOfList,
    required this.nrEntryPosition,
    this.blueprint,
    this.blueprintID,
    this.onBlueprintAdded
  });

  @override
  State<AddBlueprintForm> createState() => _AdBlueprintFormState();
}

class _AdBlueprintFormState extends State<AddBlueprintForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _photoFilePathController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String pageTile = "";

  late Database db;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _initDatabase();
    if (widget.blueprint != null) {
      _populateFieldsWithEquipmentData();
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  void _populateFieldsWithEquipmentData() {
    _titleController.text = widget.blueprint!.title;
    _descriptionController.text = widget.blueprint!.description;
    _photoFilePathController.text = widget.blueprint!.photoFilePath ?? '';
    _quantityController.text = widget.blueprint!.nrEntryPosition.toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _photoFilePathController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.blueprint != null){
      pageTile = AppLocalizations.of(context)!.edit;
    }else{
      pageTile = AppLocalizations.of(context)!.blueprintAdd;
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
            controller: _titleController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.blueprintAddName,
              labelText: AppLocalizations.of(context)!.blueprintAddName,
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
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.blueprintAddDescription,
              labelText: AppLocalizations.of(context)!.blueprintAddDescription,
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
          TextFormField(
            controller: _photoFilePathController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.photoAdd,
              labelText: AppLocalizations.of(context)!.photoAdd,
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
          Text(
            AppLocalizations.of(context)!.listNumber(widget.nrOfList),
            style: const TextStyle(
              fontSize: 15,
              backgroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.listPosition(widget.nrEntryPosition),
            style: const TextStyle(
              fontSize: 15,
              backgroundColor: Colors.white,
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
              if (_formKey.currentState!.validate()) {
                try{
                  DateTime dateCreation = widget.blueprint?.createdAt ?? DateTime.now();
                  Blueprint newBlueprint = Blueprint(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    photoFilePath: _photoFilePathController.text,
                    nrOfList: widget.nrOfList,
                    nrEntryPosition: widget.nrEntryPosition,
                    createdAt: dateCreation,
                    updatedAt: DateTime.now(),
                  );
                  if (widget.blueprint == null) {
                    insertBlueprint(db, newBlueprint, "");
                  } else {
                    updateBlueprint(db, newBlueprint, widget.blueprintID!);
                  }
                  if (widget.onBlueprintAdded != null) {
                    widget.onBlueprintAdded!();
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
          )
        ],
      )
    );
  }
}
