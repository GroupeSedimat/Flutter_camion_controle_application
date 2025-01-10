import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/services/database_firestore/check_list/database_image_service.dart';
import 'package:flutter_application_1/services/database_local/check_list/tasks_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/pick_image_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class ValidateTask extends StatefulWidget {

  Blueprint blueprint;
  TaskChecklist validate;
  String keyId;
  String userUID;
  final VoidCallback? onValidateAdded;

  ValidateTask({
    super.key,
    required this.blueprint,
    required this.validate,
    required this.keyId,
    required this.userUID,
    this.onValidateAdded
  });

  @override
  State<ValidateTask> createState() => ValidateTaskState();
}

class ValidateTaskState extends State<ValidateTask> {
  final _formKey = GlobalKey<FormState>();
  File? imageGalery;
  late Database db;

  final PickImageService _pickImageService = PickImageService();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _syncValidateTasks() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);

      print("++++ Synchronizing Validate Tasks...");
      await syncService.syncToFirebase("validateTasks", DateTime.now().toString(), userId: widget.userUID);
      print("++++ Synchronization with SQLite completed.");
    } catch (e) {
      print("Error during global data synchronization: $e");
      throw e;
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
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
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    DatabaseImageService databaseImageService = DatabaseImageService();

    return Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Text(
              widget.blueprint.title,
              style: TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: screenWidth * 0.08,
                  color: Colors.green,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.blueprint.description,
              style: TextStyle(
                backgroundColor: Colors.white,
                fontSize: screenWidth * 0.05,
                color: Colors.grey,
              ),
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
                  backgroundColor: Colors.white,
                ),
                focusedBorder: OutlineInputBorder(gapPadding: 15),
                border: UnderlineInputBorder(),
              ),
              validator: (val) {return (val == null || val.isEmpty) ? AppLocalizations.of(context)!.required : null;},
              onChanged: (val) => widget.validate.descriptionOfProblem = val,
            ),
            const SizedBox(height: 40),

            Transform.scale(
              scale: 5,                                                           // Change checkbox scale
              child: Checkbox(
                value: widget.validate.isDone,
                checkColor: Colors.red,
                activeColor: (widget.validate.isDone == true) ? Colors.green: Colors.grey ,
                side: const BorderSide(width: 3, color: Colors.red),
                shape: (widget.validate.isDone == true) ? const ContinuousRectangleBorder() : const CircleBorder(),
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
              child: imageGalery != null
                ? Image.file(imageGalery!)
                :(
                  (widget.validate.photoFilePath != "" && widget.validate.photoFilePath != null)
                    ? Image.network(widget.validate.photoFilePath!)
                    : Text(AppLocalizations.of(context)!.photoNotYet, style: TextStyle(fontSize: screenWidth * 0.03,),)
                ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () => pickImageFromCamera(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.photoMake,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                      size: screenWidth * 0.1,
                    ),
                  ],
                )
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 50),
                padding: const EdgeInsets.all(10),
              ),
              onPressed: () => pickImageFromGallery(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.photoGallery,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                  Icon(
                    Icons.image_outlined,
                    color: Colors.black,
                    size: screenWidth * 0.1,
                  ),
                ],
              )
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
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    widget.validate.updatedAt = DateTime.now();
                    if (imageGalery != null) {
                      try {
                        String photoFilePath = await databaseImageService.addImageToFirebase(imageGalery!.path);
                        if (mounted) {
                          setState(() {
                            widget.validate.photoFilePath = photoFilePath;
                          });
                        }
                      } catch (e) {
                        print('Failed to upload image: $e');
                      }
                    }

                    if(widget.validate.isDone!=true) widget.validate.isDone = false;
                    widget.validate.userId = widget.userUID;
                    widget.validate.nrOfList = widget.blueprint.nrOfList;
                    widget.validate.nrEntryPosition = widget.blueprint.nrEntryPosition;
                    if(widget.keyId == ""){
                      insertTask(db, widget.validate, "");
                    }else{
                      updateTask(db, widget.validate, widget.keyId);
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
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        )
    );
  }
}
