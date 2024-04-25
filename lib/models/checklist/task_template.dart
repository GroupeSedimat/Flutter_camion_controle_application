import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/task.dart';

class TaskTemplate extends StatelessWidget{

  final Task task;
  final Function delete;
  TaskTemplate({ required this.task, required this.delete });

  @override
  Widget build(BuildContext context){
    bool? _isDone = false;
    return Card(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8.0,),
            Text(
              task.description,
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8.0,),
            TextButton.icon(
              onPressed: () => delete(),
              label: const Text('delete this'),
              icon: const Icon(Icons.delete),
            ),
            Checkbox(
              checkColor: Colors.white,
              value: _isDone,
              onChanged: (value){
                _isDone = value;
              }
            )
          ],
        ),
      ),
    );
  }
}