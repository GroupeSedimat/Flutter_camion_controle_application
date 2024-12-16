import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/services/database_firestore/check_list/database_list_of_lists_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddListForm extends StatefulWidget {
  final ListOfLists? listItem;
  final DatabaseListOfListsService databaseListOfListsService = DatabaseListOfListsService();

  AddListForm({super.key, this.listItem});

  @override
  _AddListFormState createState() => _AddListFormState();
}

class _AddListFormState extends State<AddListForm> {
  final _formKey = GlobalKey<FormState>();
  final _listNameController = TextEditingController();
  int? _listNr;

  @override
  void initState() {
    super.initState();

    if (widget.listItem != null) {
      _listNr = widget.listItem!.listNr;
      _listNameController.text = widget.listItem!.listName;
    } else {
      _setFirstFreeListNr();
    }
  }

  Future<void> _setFirstFreeListNr() async {
    int freeNr = await widget.databaseListOfListsService.findFirstFreeListNr();
    setState(() {
      _listNr = freeNr;
    });
  }

  @override
  void dispose() {
    _listNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listItem == null ? AppLocalizations.of(context)!.lOLAdd : AppLocalizations.of(context)!.lOLEdit),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_listNr != null) ...[
                Text(
                  "${AppLocalizations.of(context)!.lOLNumber}: $_listNr",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
              ] else ...[
                CircularProgressIndicator(),
                const SizedBox(height: 20),
              ],
              TextFormField(
                controller: _listNameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.lOLName),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.lOLNameText;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_listNr != null) {
                      final listItem = ListOfLists(
                        listNr: _listNr!,
                        listName: _listNameController.text,
                      );

                      if (widget.listItem == null) {
                        await widget.databaseListOfListsService.addList(listItem);
                      } else {
                        await widget.databaseListOfListsService
                            .updateListItemByListNr(_listNr!, listItem);
                      }
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(widget.listItem == null
                    ? AppLocalizations.of(context)!.lOLAdd
                    : AppLocalizations.of(context)!.confirm
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}