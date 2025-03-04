import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BlueprintTemplate extends StatelessWidget{

  final Blueprint blueprint;
  final Function delete;
  final Function edit;
  final Function validate;
  final Function restore;
  final String role;
  bool? isDone;
  BlueprintTemplate({super.key,  required this.blueprint, required this.delete, required this.edit, required this.validate, required this.restore, required this.role, this.isDone });
/// TODO add adding/editing/deleting photos from gallery/camera
  @override
  Widget build(BuildContext context){
    String isDeleted = "";
    if(blueprint.deletedAt != null){
      isDeleted = " (deleted)";
    }
    return Card(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      color: colorColor("card_background"),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "${blueprint.title}$isDeleted",
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
                  label: Text(AppLocalizations.of(context)!.edit),
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
                  label: Text(AppLocalizations.of(context)!.checkListValidation),
                  icon: const Icon(
                    Icons.check_box,
                    color: Colors.red,
                  ),
                ),
                if(role == "superadmin" && blueprint.deletedAt == null)
                TextButton.icon(
                  onPressed: () => delete(),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                      backgroundColor: Colors.red[900]
                  ),
                  label: Text(AppLocalizations.of(context)!.delete),
                  icon: const Icon(Icons.delete),
                ),
                if(role == "superadmin" && blueprint.deletedAt != null)
                TextButton.icon(
                  onPressed: () => restore(),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                      backgroundColor: Colors.red[900]
                  ),
                  label: Text(AppLocalizations.of(context)!.restore),
                  icon: const Icon(Icons.restore),
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