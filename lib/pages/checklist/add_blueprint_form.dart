// ignore_for_file: prefer_const_constructors_in_immutables, avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:intl/intl.dart';

class AddBlueprintForm extends StatefulWidget {
  final int nrOfList;
  final int nrEntryPosition;
  final DatabaseService databaseService;
  final Blueprint? blueprint;
  final String? blueprintID;

  AddBlueprintForm({
    super.key,
    required this.nrOfList,
    required this.nrEntryPosition,
    required this.databaseService,
    this.blueprint,
    this.blueprintID});

  @override
  State<AddBlueprintForm> createState() => _AdBlueprintFormState();
}

class _AdBlueprintFormState extends State<AddBlueprintForm> {

  final _formKey = GlobalKey<FormState>();
  String title = "";
  String description = "";
  String oldTitle = "";
  String oldDescription = "";
  Timestamp lastUpdate = Timestamp.now();

  @override
  Widget build(BuildContext context) {
    if(widget.blueprint != null){
      oldTitle = widget.blueprint!.title;
      oldDescription = widget.blueprint!.description;
      print("Blueprint ID: ${widget.blueprintID!}");
    }
    return Form(
      key: _formKey,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget> [
          const Text(
            "Add new blueprint",
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
            initialValue: oldTitle,
            decoration: const InputDecoration(
              hintText: "Give me name!",
              labelText: "Blueprint name:",
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(gapPadding: 15),
              border: OutlineInputBorder(gapPadding: 5),
            ),
            validator: (val) {return (val == null || val.isEmpty || val == "") ? 'Enter blueprint name:' : null;},
            onChanged: (val) => setState(() {title = val;}),
          ),

          const SizedBox(height: 20),
          TextFormField(
            initialValue: oldDescription,
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
              Blueprint blueprintNew = Blueprint(
                title: (title == "" && title != oldTitle)? oldTitle : title,
                description: (description == "" && description != oldDescription) ? oldDescription : description,
                nrOfList: widget.nrOfList,
                nrEntryPosition: widget.nrEntryPosition,
                lastUpdate: lastUpdate,
              );
              if(widget.blueprintID != null){
                widget.databaseService.updateBlueprint(widget.blueprintID!, blueprintNew);
              }else{
                widget.databaseService.addBlueprint(blueprintNew);
              }
              Navigator.pop(context);
            },
          )
        ],
      )
    );
  }
}
