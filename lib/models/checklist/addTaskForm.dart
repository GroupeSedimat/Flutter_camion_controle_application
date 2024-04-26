import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:intl/intl.dart';

class AddTaskForm extends StatefulWidget {
  int nrOfList;
  int nrEntryPosition;
  DatabaseService databaseService;
  AddTaskForm({super.key, required this.nrOfList, required this.nrEntryPosition , required this.databaseService});

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {

  final _formKey = GlobalKey<FormState>();
  late String title;
  late String description;
  Timestamp deleted = Timestamp.now();
  Timestamp lastUpdate = Timestamp.now();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget> [
          const Text(
            "Add new task",
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
            decoration: const InputDecoration(
              hintText: "Give me name!",
              labelText: "Task name:",
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 15),
              border: OutlineInputBorder(gapPadding: 5),
            ),
            validator: (val) {return (val == null || val.isEmpty) ? 'Enter task name:' : null;},
            onChanged: (val) => setState(() {title = val;}),
          ),

          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              hintText: "Description go here!",
              labelText: "Enter description:",
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 50),
              border: OutlineInputBorder(gapPadding: 20),
            ),

            validator: (val) {return (val == null || val.isEmpty) ? 'Enter description please' : null;},
            onChanged: (val) => setState(() {description = val;}),
          ),
          const SizedBox(height: 20),
          Text(
            "List number: ${widget.nrOfList}",
            style: const TextStyle(
              fontSize: 15,
              backgroundColor: Colors.white,
            ),
          ),
          Text(
            "List position: ${widget.nrEntryPosition}",
            style: const TextStyle(
              fontSize: 15,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            DateFormat("dd-MM-yyyy h:mm a").format(lastUpdate.toDate()),
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
            child: const Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              Task task = Task(
                title: title,
                description: description,
                nrOfList: widget.nrOfList,
                nrEntryPosition: widget.nrEntryPosition,
                lastUpdate: lastUpdate,
                deleted: deleted,
              );
              widget.databaseService.addTask(task);
              Navigator.pop(context);
            },
          )
        ],
      )
    );
  }
}
