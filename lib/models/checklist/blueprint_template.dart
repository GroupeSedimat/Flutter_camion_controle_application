import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';

class BlueprintTemplate extends StatelessWidget{

  final Blueprint blueprint;
  final Function delete;
  final Function edit;
  final Function validate;
  bool? isDone;
  BlueprintTemplate({super.key,  required this.blueprint, required this.delete, required this.edit, required this.validate, this.isDone });

  @override
  Widget build(BuildContext context){

    return Card(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      color: isDone == null ? Colors.grey[800] : isDone! ? Colors.green : Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              blueprint.title,
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.amber ,
              ),
            ),
            const SizedBox(height: 8.0,),
            Text(
              blueprint.description,
              style: const TextStyle(
                fontSize: 12.0,
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
                  label: const Text('Edit Blueprint'),
                  icon: const Icon(
                    Icons.check_box,
                    color: Colors.red,
                  ),
                ),
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
}