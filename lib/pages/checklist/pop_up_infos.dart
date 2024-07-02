// ignore_for_file: unnecessary_import, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/services/check_list/database_blueprints_service.dart';

class PopUpInfo extends StatelessWidget {
  final TextEditingController _textEditingController = TextEditingController();
  final DatabaseBlueprintsService databaseBlueprintsService;
  int listNr;
  int counter;
  PopUpInfo({super.key, required this.listNr, required this.counter, required this.databaseBlueprintsService});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add a Blueprint"),
      content: TextField(
        controller: _textEditingController,
        decoration: const InputDecoration(hintText: "Add Blueprint name"),
        // expands: true,
      ),
      actions: [
        MaterialButton(
          color: Theme.of(context).colorScheme.primary,
          textColor: Colors.lime,
          child: const Text("Ok"),
          onPressed: (){
            Blueprint task = Blueprint(
              title: _textEditingController.text,
              description: "description",
              nrOfList: listNr,
              nrEntryPosition: counter+1,
              lastUpdate: Timestamp.now(),
            );
            databaseBlueprintsService.addBlueprint(task);
            Navigator.pop(context);
            _textEditingController.clear();
          },
        )
      ],
    );
  }

}