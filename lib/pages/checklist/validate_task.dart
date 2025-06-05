import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/services/database_local/check_list/tasks_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/pick_image_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class ValidateTask extends StatefulWidget {
  final Blueprint blueprint;
  final TaskChecklist validate;
  final String keyId;
  final String userUID;
  final Camion camion;
  final String camionId;
  final MyUser user;
  final VoidCallback? onValidateAdded;

  const ValidateTask({
    super.key,
    required this.blueprint,
    required this.validate,
    required this.keyId,
    required this.userUID,
    required this.camion,
    required this.camionId,
    required this.user,
    this.onValidateAdded,
  });

  @override
  State<ValidateTask> createState() => ValidateTaskState();
}

class ValidateTaskState extends State<ValidateTask> {
  final _formKey = GlobalKey<FormState>();
  NetworkService networkService = NetworkService();
  File? imageGalery;
  late Directory tempDir;
  late Database db;
  bool _isInitialized = false;

  final PickImageService _pickImageService = PickImageService();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
    tempDir = await getApplicationSupportDirectory();
    setState(() {
      _isInitialized = true;
    });
  }

  Future pickImageFromGallery() async {
    final image = await _pickImageService.pickImageFromGallery();
    if (image != null) {
      setState(() => imageGalery = image);
    }
  }

  Future pickImageFromCamera() async {
    final image = await _pickImageService.pickImageFromCamera();
    if (image != null) {
      setState(() => imageGalery = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          Text(
            widget.blueprint.title,
            style: TextStyle(
              backgroundColor: Colors.white,
              fontSize: 35,
              color: Colors.green,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.blueprint.description,
            style: TextStyle(
              backgroundColor: Colors.white,
              fontSize: 26,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          if (widget.blueprint.photoFilePath != null &&
              widget.blueprint.photoFilePath!.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.blueprint.photoFilePath!.map((path) {
                return Center(
                  child: Image.file(
                    File("${tempDir.path}/$path"),
                    width: screenWidth * 0.3,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: widget.validate.descriptionOfProblem,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.checkListDescribe,
              labelText: AppLocalizations.of(context)!.checkListDescribe,
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 15),
              border: UnderlineInputBorder(),
            ),
            validator: (val) {
              return (val == null || val.isEmpty)
                  ? AppLocalizations.of(context)!.required
                  : null;
            },
            onChanged: (val) => widget.validate.descriptionOfProblem = val,
          ),
          const SizedBox(height: 40),
          Transform.scale(
            scale: 5,
            child: Checkbox(
              value: widget.validate.isDone,
              checkColor: Colors.red,
              activeColor:
                  (widget.validate.isDone == true) ? Colors.green : Colors.grey,
              side: const BorderSide(width: 3, color: Colors.red),
              shape: (widget.validate.isDone == true)
                  ? const ContinuousRectangleBorder()
                  : const CircleBorder(),
              tristate: true,
              onChanged: (value) {
                setState(() {
                  widget.validate.isDone = value;
                });
              },
            ),
          ),
          const SizedBox(height: 30),
          Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.7,
              maxHeight: screenHeight * 0.7,
            ),
            child: (imageGalery != null && imageGalery!.existsSync())
                ? Image.file(imageGalery!)
                : ((widget.validate.photoFilePath != null &&
                        File(widget.validate.photoFilePath!).existsSync())
                    ? Image.file(File(
                        "${tempDir.path}/${widget.validate.photoFilePath!}"))
                    : Text(AppLocalizations.of(context)!.photoNotYet)),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => pickImageFromCamera(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.photoMake),
                Icon(Icons.camera_alt_outlined, color: Colors.black),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => pickImageFromGallery(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.photoGallery),
                Icon(Icons.image_outlined, color: Colors.black),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(250, 60),
                ),
                child: Text(
                  AppLocalizations.of(context)!.confirm,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  widget.validate.updatedAt = DateTime.now();

                  if (widget.validate.isDone != true) {
                    widget.validate.isDone = false;
                  }

                  widget.validate.userId = widget.userUID;
                  widget.validate.nrOfList = widget.blueprint.nrOfList;
                  widget.validate.nrEntryPosition =
                      widget.blueprint.nrEntryPosition;

                  if (widget.keyId == "") {
                    insertTask(db, widget.validate, "");
                  } else {
                    updateTask(db, widget.validate, widget.keyId);
                  }

                  try {
                    await FirebaseFirestore.instance
                        .collection('camionChecks')
                        .add({
                      'camionId': widget.camionId,
                      'camionName': widget.camion.name,
                      'userId': widget.userUID,
                      'username': widget.user.username,
                      'companyId': widget.user.company,
                      'checkTime': DateTime.now(),
                      'result': {
                        'description':
                            widget.validate.descriptionOfProblem ?? '',
                        'isDone': widget.validate.isDone ?? false,
                        'taskId': widget.validate.nrEntryPosition,
                      },
                    });

                    print("✅ Check enregistré dans Firestore !");
                  } catch (e) {
                    print("❌ Erreur enregistrement check Firebase : $e");
                  }

                  if (mounted) {
                    widget.onValidateAdded?.call();
                  }
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(250, 60),
                ),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
