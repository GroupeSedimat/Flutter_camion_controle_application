import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/services/database_service.dart';

class ValidateTask extends StatefulWidget {

  DatabaseService databaseService;
  Blueprint blueprint;
  ValidateTask({
    super.key,
    required this.databaseService,
    required this.blueprint});

  @override
  State<ValidateTask> createState() => ValidateTaskState();
}

class ValidateTaskState extends State<ValidateTask> {

  final _formKey = GlobalKey<FormState>();
  String? descriptionOfProblem;
  String? photoFilePath;
  bool? isDone = true;
  Timestamp? validationDate;
  Task? task;
  int? nrOfList;
  int? nrEntryPosition;

  @override
  void initState() {
    super.initState();
    // Wywołujemy funkcję asynchroniczną w metodzie initState
    fetchTask();
  }

  Future<void> fetchTask() async {
    // Pobieramy obiekt Task z bazy danych i aktualizujemy stan komponentu
    nrOfList = widget.blueprint.nrOfList;
    nrEntryPosition = widget.blueprint.nrEntryPosition;

    task = await widget.databaseService.getOneTaskWithListPos(nrOfList!, nrEntryPosition!);
    setState(() {}); // Wywołujemy setState, aby zaktualizować widok
  }

  @override
  Widget build(BuildContext context) {
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
            onChanged: (val) => setState(() {descriptionOfProblem = val;}),
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
            onChanged: (val) => setState(() {photoFilePath = val;}),
          ),
          const SizedBox(height: 40),

          Transform.scale(                                                      // validation button
            scale: 5,                                                           // zmien skale checkbox
            child: Checkbox(
              value: isDone,
              checkColor: Colors.red,
              activeColor: (isDone == true) ? Colors.green: Colors.grey ,
              side: const BorderSide(width: 3, color: Colors.red),
              shape: (isDone == true) ? const ContinuousRectangleBorder() : const CircleBorder(),
              tristate: true,
              onChanged: (value) {
                setState(() {
                  isDone = value;
                });
              },
            ),
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
                  Task task = Task(
                    nrOfList: nrOfList,
                    nrEntryPosition: nrEntryPosition,
                    validationDate: validationDate,
                    isDone: isDone,
                    descriptionOfProblem: descriptionOfProblem,
                    photoFilePath: photoFilePath
                  );
                  widget.databaseService.addTask(task);
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
}
