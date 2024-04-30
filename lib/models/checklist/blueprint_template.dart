import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';

class BlueprintTemplate extends StatelessWidget{

  final Blueprint blueprint;
  final Function delete;
  final Function edit;
  BlueprintTemplate({ required this.blueprint, required this.delete, required this.edit });

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
              blueprint.title,
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8.0,),
            Text(
              blueprint.description,
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8.0,),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => edit(),
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
                TextButton.icon(
                  onPressed: () => delete(),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                      backgroundColor: Colors.red[900]
                  ),
                  label: const Text('delete this'),
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}