import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/services/database_service.dart';

class ValidateTask extends StatefulWidget {

  int nrOfList;
  int nrEntryPosition;
  DatabaseService databaseService;
  Blueprint blueprint;
  ValidateTask({
    super.key,
    required this.nrOfList,
    required this.nrEntryPosition ,
    required this.databaseService,
    required this.blueprint});

  @override
  State<ValidateTask> createState() => ValidateTaskState();
}

class ValidateTaskState extends State<ValidateTask> {

  final _formKey = GlobalKey<FormState>();
  String? descriptionOfProblem;
  String? photoFilePath;
  bool? isDone;
  Timestamp? validationDate;

  @override
  Widget build(BuildContext context) {

    return Form(
      key: _formKey,
      child: Column(
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
          Transform.scale(

            child: Checkbox(
              value: isDone,
              tristate: true,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  isDone = value;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
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
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(250, 60),
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
                    nrOfList: widget.nrOfList,
                    nrEntryPosition: widget.nrEntryPosition,
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
                  backgroundColor: Colors.blue,
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
