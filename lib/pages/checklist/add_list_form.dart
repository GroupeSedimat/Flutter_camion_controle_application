import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/services/database_local/check_list/list_of_lists_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class AddListForm extends StatefulWidget {
  final ListOfLists? listItem;
  final String? listItemID;
  final VoidCallback? onListAdded;

  AddListForm({
    super.key,
    this.listItem,
    this.listItemID,
    this.onListAdded
  });

  @override
  _AddListFormState createState() => _AddListFormState();
}

class _AddListFormState extends State<AddListForm> {
  final _formKey = GlobalKey<FormState>();

  final _listNameController = TextEditingController();
  int? _listNr;
  String pageTile = "";
  bool _isLoading = true;

  late Database db;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _setFirstFreeListNr() async {
    int freeNr = await findFirstFreeListNr(db);
    _listNr = freeNr;
  }

  Future<void> _initializeData() async {
    await _initDatabase();
    if (widget.listItem != null) {
      _populateFieldsWithListData();
    }else{
      _setFirstFreeListNr();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  void _populateFieldsWithListData() {
    _listNr = widget.listItem!.listNr;
    _listNameController.text = widget.listItem!.listName;
  }

  @override
  void dispose() {
    _listNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.8),
                  Theme.of(context).primaryColor.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listItem != null
            ? AppLocalizations.of(context)!.edit
            : AppLocalizations.of(context)!.add
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Text(
              pageTile,
              style: TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 30,
                  color: Colors.green,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.listNumber(_listNr!),
              style: const TextStyle(
                fontSize: 15,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _listNameController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.lOLName,
                labelText: AppLocalizations.of(context)!.lOLName,
                labelStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                ),
                focusedBorder: const OutlineInputBorder(gapPadding: 15),
                border: const OutlineInputBorder(gapPadding: 5),
              ),
              validator: (val) {
                return (val == null || val.isEmpty || val == "")
                    ? AppLocalizations.of(context)!.required
                    : null;
              },
            ),
            const SizedBox(height: 50),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(250, 60),
              ),
              child: Text(
                AppLocalizations.of(context)!.confirm,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    DateTime dateCreation = widget.listItem?.createdAt ?? DateTime.now();
                    ListOfLists newBlueprint = ListOfLists(
                      listNr: _listNr!,
                      listName: _listNameController.text,
                      createdAt: dateCreation,
                      updatedAt: DateTime.now(),
                    );
                    if (widget.listItem == null) {
                      print("insert data $newBlueprint");
                      insertList(db, newBlueprint, "");
                    } else {
                      updateList(db, newBlueprint, widget.listItemID!);
                    }
                    if (widget.onListAdded != null) {
                      widget.onListAdded!();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  } catch (e) {
                    print("Error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.errorSavingData)),
                    );
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }
}