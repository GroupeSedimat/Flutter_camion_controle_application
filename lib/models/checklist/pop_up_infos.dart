import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/services/database_service.dart';

class PopUpInfo extends StatelessWidget {
  TextEditingController _textEditingController = TextEditingController();
  final DatabaseService databaseService;
  int listNr;
  int counter;
  PopUpInfo({super.key, required this.listNr, required this.counter, required this.databaseService});

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
            databaseService.addBlueprint(task);
            Navigator.pop(context);
            _textEditingController.clear();
          },
        )
      ],
    );
  }

}