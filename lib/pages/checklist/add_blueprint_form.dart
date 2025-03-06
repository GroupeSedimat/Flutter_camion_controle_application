import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/check_list/blueprints_table.dart';
import 'package:flutter_application_1/services/pick_image_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
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
  final TextEditingController _quantityController = TextEditingController();
  late Directory appDocDir;
  List<String> _photoFilePaths = [];
  int photoCounter = 1;
  File? imageGalery;
  String pageTile = "";

  late PickImageService _pickImageService;
  late Database db;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _initDatabase();
    await _initService();
    if (widget.blueprint != null) {
      _populateFieldsWithEquipmentData();
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _initService() async {
    _pickImageService = PickImageService();
    appDocDir = await getApplicationSupportDirectory();
  }

  void _populateFieldsWithEquipmentData() {
    List<String> tempPhotoPath = widget.blueprint!.photoFilePath ?? [];

    _titleController.text = widget.blueprint!.title;
    _descriptionController.text = widget.blueprint!.description;


    _quantityController.text = widget.blueprint!.nrEntryPosition.toString();

    setState(() {
      _photoFilePaths = tempPhotoPath;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickAndSavePhoto() async {
    final image = await _pickImageService.pickImageFromCamera();
    if (image != null) {
      try {
        String listNr = widget.nrOfList.toString().padLeft(4, '0');
        String entryPos = widget.nrEntryPosition.toString().padLeft(4, '0');
        String fileName = "$listNr${entryPos}photoBlueprint$photoCounter.jpeg";
        final fileTemp = File("${appDocDir.path}/$fileName");
        final bytes = await image.readAsBytes();
        await fileTemp.writeAsBytes(bytes);
        print("Photo saved: ${fileTemp.path}");
        setState(() {
          _photoFilePaths.add(fileName);
          photoCounter++;
        });
      } catch (e) {
        print("Photo saving error: $e");
      }
    }
  }

  Future<void> _removePhotoAt(int index) async {
    try {
      String path = _photoFilePaths[index];
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        print("Photo deleted: $path");
      }
      setState(() {
        _photoFilePaths.removeAt(index);
      });
    } catch (e) {
      print("Error deleting photo: $e");
    }
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
          TextButton(
            onPressed: _pickAndSavePhoto,
            child: Text(AppLocalizations.of(context)!.photoMake),
          ),
          const SizedBox(height: 20),
          if (_photoFilePaths.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _photoFilePaths.asMap().entries.map((entry) {
                int index = entry.key;
                String path = "${appDocDir.path}/${entry.value}";
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.file(
                      File(path),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removePhotoAt(index),
                    ),
                  ],
                );
              }).toList(),
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
                    photoFilePath: _photoFilePaths,
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
                  if (mounted && widget.onBlueprintAdded != null) {
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
