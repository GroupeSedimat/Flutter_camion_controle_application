import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/services/check_list/database_list_of_lists_service.dart';

class AddListForm extends StatefulWidget {
  final ListOfLists? listItem; // Nullable, bo może być używany do edycji lub dodawania
  final DatabaseListOfListsService databaseListOfListsService = DatabaseListOfListsService();

  AddListForm({Key? key, this.listItem}) : super(key: key);

  @override
  _AddListFormState createState() => _AddListFormState();
}

class _AddListFormState extends State<AddListForm> {
  final _formKey = GlobalKey<FormState>();
  final _listNrController = TextEditingController();
  final _listNameController = TextEditingController();
  final _typeControllers = <TextEditingController>[];
  final _types = <String>[];

  @override
  void initState() {
    super.initState();

    if (widget.listItem != null) {
      _listNrController.text = widget.listItem!.listNr.toString();
      _listNameController.text = widget.listItem!.listName;
      _types.addAll(widget.listItem!.types);
      _typeControllers.addAll(
        _types.map((type) => TextEditingController(text: type)),
      );
    }
  }

  @override
  void dispose() {
    _listNrController.dispose();
    _listNameController.dispose();
    for (var controller in _typeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTypeField() {
    setState(() {
      _typeControllers.add(TextEditingController());
      _types.add('');
    });
  }

  void _removeTypeField(int index) {
    setState(() {
      _typeControllers[index].dispose();
      _typeControllers.removeAt(index);
      _types.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listItem == null ? 'Add New List' : 'Edit List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _listNrController,
                decoration: InputDecoration(labelText: 'List Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter list number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _listNameController,
                decoration: InputDecoration(labelText: 'List Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter list name';
                  }
                  return null;
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _typeControllers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: TextFormField(
                        controller: _typeControllers[index],
                        decoration: InputDecoration(labelText: 'Type ${index + 1}'),
                        onChanged: (value) {
                          _types[index] = value;
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () => _removeTypeField(index),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _addTypeField,
                child: Text('Add Type'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final listNr = int.tryParse(_listNrController.text);
                    if (listNr != null) {
                      final listItem = ListOfLists(
                        listNr: listNr,
                        listName: _listNameController.text,
                        types: _types,
                      );

                      if (widget.listItem == null) {
                        await widget.databaseListOfListsService.addList(listItem);
                      } else {
                        await widget.databaseListOfListsService
                            .updateListItemByListNr(int.parse(_listNrController.text), listItem); // Używaj metody `updateList` z odpowiednim ID
                      }
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(widget.listItem == null ? 'Add List' : 'Update List'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}