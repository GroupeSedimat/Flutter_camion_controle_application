import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/services/check_list/database_image_service.dart';
import 'package:flutter_application_1/services/check_list/database_tasks_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ValidateTask extends StatefulWidget {

  DatabaseTasksService databaseTasksService;
  Blueprint blueprint;
  TaskChecklist validate;
  String keyId;
  String userUID;

  ValidateTask({
    super.key,
    required this.databaseTasksService,
    required this.blueprint,
    required this.validate,
    required this.keyId,
    required this.userUID});

  @override
  State<ValidateTask> createState() => ValidateTaskState();
}

class ValidateTaskState extends State<ValidateTask> {


  final _formKey = GlobalKey<FormState>();
  late String descriptionOfProblem;
  String? photoFilePath;
  bool? isDone;
  Timestamp? validationDate;
  TaskChecklist? task;
  int? nrOfList;
  int? nrEntryPosition;
  File? imageGalery;
  double screenWidth = 50;
  double screenHeight = 50;

  @override
  void initState() {
    super.initState();

    task = widget.validate;
    descriptionOfProblem = task?.descriptionOfProblem ?? "";
    photoFilePath = task?.photoFilePath ?? "";
    isDone = task?.isDone;
  }

  Future pickImageFromGallery() async{
    try {
      final image =  await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;

      final imageTemp = File(image.path);
      setState(() => imageGalery = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image from gallery: $e');
    }
  }

  Future pickImageFromCamera() async{
    try {
      final image =  await ImagePicker().pickImage(source: ImageSource.camera);
      if(image == null) return;

      final imageTemp = File(image.path);
      setState(() => imageGalery = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image from camera: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
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
              initialValue: task?.descriptionOfProblem,
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
              onChanged: (val) => descriptionOfProblem = val,
            ),
            const SizedBox(height: 40),

            Transform.scale(
              scale: 5,                                                           // Change checkbox scale
              child: Checkbox(
                value: task?.isDone,
                checkColor: Colors.red,
                activeColor: (task?.isDone == true) ? Colors.green: Colors.grey ,
                side: const BorderSide(width: 3, color: Colors.red),
                shape: (task?.isDone == true) ? const ContinuousRectangleBorder() : const CircleBorder(),
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    isDone = value;
                    task?.isDone = value;
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
                  (photoFilePath != "" && photoFilePath != null)
                    ? Image.network(photoFilePath!)
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
                    validationDate = Timestamp.now();
                    if (imageGalery != null) {
                      try {
                        String photoFilePath = await databaseImageService.addImageToFirebase(imageGalery!.path);
                        if (mounted) {
                          setState(() {
                            this.photoFilePath = photoFilePath;
                          });
                        }
                      } catch (e) {
                        print('Failed to upload image: $e');
                      }
                    }

                    if(isDone!=true) isDone = false;
                    TaskChecklist task = TaskChecklist(
                        nrOfList: widget.blueprint.nrOfList,
                        nrEntryPosition: widget.blueprint.nrEntryPosition,
                        validationDate: validationDate,
                        isDone: isDone,
                        descriptionOfProblem: descriptionOfProblem,
                        photoFilePath: photoFilePath,
                        userId: widget.userUID
                    );
                    if(widget.keyId == ""){
                      widget.databaseTasksService.addTask(task);
                    }else{
                      widget.databaseTasksService.updateTask(widget.keyId, task);
                    }
                    if (mounted) {
                      Navigator.pop(context);
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
