import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';

class ValidateTask extends StatefulWidget {

  DatabaseService databaseService;
  Blueprint blueprint;
  Task validate;
  String keyId;
  String userUID;

  ValidateTask({
    super.key,
    required this.databaseService,
    required this.blueprint,
    required this.validate,
    required this.keyId,
    required this.userUID});

  @override
  State<ValidateTask> createState() => ValidateTaskState();
}

class ValidateTaskState extends State<ValidateTask> {


  final _formKey = GlobalKey<FormState>();
  String descriptionOfProblem = "";
  String photoFilePath = "";
  bool? isDone;
  Timestamp? validationDate;
  Task? task;
  int? nrOfList;
  int? nrEntryPosition;
  File? imageGalery;
  // bool _isLoading = true; // Dodaj zmienną do śledzenia stanu ładowania

  Future pickImage() async{
    try {
      final image =  await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;

      final imageTemp = File(image.path);
      setState(() => this.imageGalery = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pisk image: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    task = widget.validate;
    return Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Text(
              widget.blueprint.title,
              style: const TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 30,
                  color: Colors.green,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.blueprint.description,
              style: const TextStyle(
                backgroundColor: Colors.white,
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: task?.descriptionOfProblem,
              decoration: const InputDecoration(
                hintText: "Give me description!",
                labelText: "Add description of problem:",
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                ),
                focusedBorder: OutlineInputBorder(gapPadding: 15),
                border: UnderlineInputBorder(),
              ),
              validator: (val) {return (val == null || val.isEmpty) ? 'Enter description!' : null;},
              onChanged: (val) => descriptionOfProblem = val,
            ),
            TextFormField(
              initialValue: task?.photoFilePath,
              decoration: const InputDecoration(
                hintText: "Give me link!",
                labelText: "Add Link to photo:",
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                ),
                focusedBorder: OutlineInputBorder(gapPadding: 15),
                border: UnderlineInputBorder(),
              ),
              validator: (val) {return (val == null || val.isEmpty) ? 'Enter photoFilePath!' : null;},
              onChanged: (val) => photoFilePath = val,
            ),
            const SizedBox(height: 40),

            Transform.scale(                                                      // validation button
              scale: 5,                                                           // zmien skale checkbox
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
            ElevatedButton(
                onPressed: (){

                },
                child: const Row(
                  children: [
                    Text(
                      "Make photo",
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                      size: 50,
                    ),
                  ],
                )
            ),
            const SizedBox(height: 30),
            if (imageGalery != null)
              Image.file(imageGalery!)
            else
              const FlutterLogo(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 150),
                padding: EdgeInsets.all(10),
              ),
              onPressed: () => pickImage(),
              child: const Row(
                children: [
                  Text(
                    "Take photo from gallery",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  Icon(
                    Icons.image_outlined,
                    color: Colors.black,
                    size: 50,
                  ),
                ],
              )
            ),
            const SizedBox(height: 30),
            Text(
              "Nbr of list: ${widget.blueprint.nrOfList}",
              style: const TextStyle(
                backgroundColor: Colors.white,
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Nbr of entry position: ${widget.blueprint.nrEntryPosition}",
              style: const TextStyle(
                backgroundColor: Colors.white,
                fontSize: 20,
                color: Colors.grey,
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
                    padding: const EdgeInsets.only(bottom: 8.0),
                  ),
                  child: const Text(
                    'Validate task',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    validationDate = Timestamp.now();
                    if(isDone!=true) isDone = false;
                    print(widget.validate.userId);
                    Task task = Task(
                        nrOfList: widget.blueprint.nrOfList,
                        nrEntryPosition: widget.blueprint.nrEntryPosition,
                        validationDate: validationDate,
                        isDone: isDone,
                        descriptionOfProblem: descriptionOfProblem,
                        photoFilePath: photoFilePath,
                        userId: widget.userUID
                    );
                    if(widget.keyId == ""){
                      widget.databaseService.addTask(task);
                    }else{
                      widget.databaseService.updateTask(widget.keyId, task);
                    }
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(250, 60),
                  ),
                  child: const Text(
                    'Abandon task',
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

  // @override
  // void initState() {
  //   super.initState();
  //   fetchData();
  // }
  //
  // Future<void> fetchData() async {
  //   nrOfList = widget.blueprint.nrOfList;
  //   nrEntryPosition = widget.blueprint.nrEntryPosition;
  //   task = widget.validate;
  //   isDone = task?.isDone;
  //
  //   setState(() {
  //     _isLoading = false; // Zmień stan na false po pobraniu danych
  //   });
  // }
  //
  // @override
  // Widget build(BuildContext context) {
  //   return _isLoading // Sprawdź, czy dane są nadal ładowane
  //     ? const Center(child: CircularProgressIndicator()) // Pokaż wskaźnik ładowania podczas pobierania danych
  //     : Form(
  //         key: _formKey,
  //         child: ListView(
  //           children: <Widget>[
  //             Text(
  //               widget.blueprint.title,
  //               style: const TextStyle(
  //                   backgroundColor: Colors.white,
  //                   fontSize: 30,
  //                   color: Colors.green,
  //                   letterSpacing: 4,
  //                   fontWeight: FontWeight.bold
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             Text(
  //               widget.blueprint.description,
  //               style: const TextStyle(
  //                 backgroundColor: Colors.white,
  //                 fontSize: 20,
  //                 color: Colors.grey,
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             TextFormField(
  //               initialValue: task?.descriptionOfProblem,
  //               decoration: const InputDecoration(
  //                 hintText: "Give me description!",
  //                 labelText: "Add description of problem:",
  //                 labelStyle: TextStyle(
  //                   fontSize: 20,
  //                   color: Colors.lightBlue,
  //                   backgroundColor: Colors.white,
  //                 ),
  //                 focusedBorder: OutlineInputBorder(gapPadding: 15),
  //                 border: UnderlineInputBorder(),
  //               ),
  //               validator: (val) {return (val == null || val.isEmpty) ? 'Enter description!' : null;},
  //               onChanged: (val) => descriptionOfProblem = val,
  //             ),
  //             TextFormField(
  //               initialValue: task?.photoFilePath,
  //               decoration: const InputDecoration(
  //                 hintText: "Give me link!",
  //                 labelText: "Add Link to photo:",
  //                 labelStyle: TextStyle(
  //                   fontSize: 20,
  //                   color: Colors.lightBlue,
  //                   backgroundColor: Colors.white,
  //                 ),
  //                 focusedBorder: OutlineInputBorder(gapPadding: 15),
  //                 border: UnderlineInputBorder(),
  //               ),
  //               validator: (val) {return (val == null || val.isEmpty) ? 'Enter photoFilePath!' : null;},
  //               onChanged: (val) => photoFilePath = val,
  //             ),
  //             const SizedBox(height: 40),
  //
  //             Transform.scale(                                                      // validation button
  //               scale: 5,                                                           // zmien skale checkbox
  //               child: Checkbox(
  //                 value: isDone,
  //                 checkColor: Colors.red,
  //                 activeColor: (isDone == true) ? Colors.green: Colors.grey ,
  //                 side: const BorderSide(width: 3, color: Colors.red),
  //                 shape: (isDone == true) ? const ContinuousRectangleBorder() : const CircleBorder(),
  //                 tristate: true,
  //                 onChanged: (value) {
  //                     setState(() {
  //                       isDone = value;
  //                     });
  //                 },
  //               ),
  //             ),
  //             const SizedBox(height: 30),
  //             Text(
  //               "Nbr of list: ${widget.blueprint.nrOfList}",
  //               style: const TextStyle(
  //                 backgroundColor: Colors.white,
  //                 fontSize: 20,
  //                 color: Colors.grey,
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             Text(
  //               "Nbr of entry position: ${widget.blueprint.nrEntryPosition}",
  //               style: const TextStyle(
  //                 backgroundColor: Colors.white,
  //                 fontSize: 20,
  //                 color: Colors.grey,
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             Wrap(
  //               alignment: WrapAlignment.spaceEvenly,
  //               children: [
  //                 TextButton(
  //                   style: TextButton.styleFrom(
  //                     backgroundColor: Colors.green,
  //                     minimumSize: const Size(250, 60),
  //                     padding: const EdgeInsets.only(bottom: 8.0),
  //                   ),
  //                   child: const Text(
  //                     'Validate task',
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                   onPressed: () async {
  //                     validationDate = Timestamp.now();
  //                     Task task = Task(
  //                         nrOfList: nrOfList,
  //                         nrEntryPosition: nrEntryPosition,
  //                         validationDate: validationDate,
  //                         isDone: isDone,
  //                         descriptionOfProblem: descriptionOfProblem,
  //                         photoFilePath: photoFilePath
  //                     );
  //                     if(widget.keyId == ""){
  //                       widget.databaseService.addTask(task);
  //                     }else{
  //                       widget.databaseService.updateTask(widget.keyId, task);
  //                     }
  //                     Navigator.pop(context);
  //                   },
  //                 ),
  //                 TextButton(
  //                   style: TextButton.styleFrom(
  //                     backgroundColor: Colors.red,
  //                     minimumSize: const Size(250, 60),
  //                   ),
  //                   child: const Text(
  //                     'Abandon task',
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                   onPressed: () async {
  //                     Navigator.pop(context);
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ],
  //         )
  //     );
  // }
}
