// ignore_for_file: must_be_immutable

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';

class BlueprintTemplate extends StatelessWidget{

  final Blueprint blueprint;
  final Function delete;
  final Function edit;
  final Function validate;
  final String role;
  bool? isDone;
  BlueprintTemplate({super.key,  required this.blueprint, required this.delete, required this.edit, required this.validate, required this.role, this.isDone });

  @override
  Widget build(BuildContext context){

    return Card(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      color: colorColor("card_background"),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              blueprint.title,
              style: TextStyle(
                fontSize: 20.0,
                color: colorColor("card_text") ,
              ),
            ),
            const SizedBox(height: 8.0,),
            Text(
              blueprint.description,
              style: TextStyle(
                fontSize: 15.0,
                color: colorColor("card_text"),
              ),
            ),
            const SizedBox(height: 8.0,),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                if(role == "superadmin")
                TextButton.icon(
                  onPressed: () => edit(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.cyan
                  ),
                  label: const Text('Edit Blueprint'),
                  icon: const Icon(
                    Icons.check_box,
                    color: Colors.red,
                  ),
                ),
                if(role == "admin" || role == "user")
                TextButton.icon(
                  onPressed: () => validate(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.cyan
                  ),
                  label: const Text('Validation process'),
                  icon: const Icon(
                    Icons.check_box,
                    color: Colors.red,
                  ),
                ),
                if(role == "superadmin")
                TextButton.icon(
                  onPressed: () => delete(),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                      backgroundColor: Colors.red[900]
                  ),
                  label: const Text('Delete Blueprint'),
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color? colorColor(String dest){
    if(dest == "card_background"){
      return isDone == null ? Colors.grey[800] : isDone! ? Colors.green : Colors.red.shade400;
    }else if(dest == "card_text"){
      return isDone == null ? Colors.white : isDone! ? Colors.black : Colors.black;
    }else{
      return Colors.red.shade50;
    }
  }
}