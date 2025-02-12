import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/equipment/equipment.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/equipments_table.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class AddEquipment extends StatefulWidget {

  Equipment? equipment;
  String? equipmentID;
  final VoidCallback? onEquipmentAdded;

  AddEquipment({super.key, this.equipment, this.equipmentID, this.onEquipmentAdded});

  @override
  State<AddEquipment> createState() => _AddEquipmentState();
}

class _AddEquipmentState extends State<AddEquipment> {

  final _formKey = GlobalKey<FormState>();

  late Database db;

  final TextEditingController _idShopController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final List<TextEditingController> _photoControllers = [];
  List<String> photo = [];
  bool? available;
  String pageTile = "";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _initDatabase();
    if (widget.equipment != null) {
      _populateFieldsWithEquipmentData();
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  void _populateFieldsWithEquipmentData() {
    List<String> photoList = widget.equipment!.photo ?? [];

    _idShopController.text = widget.equipment!.idShop ?? '';
    _nameController.text = widget.equipment!.name;
    _descriptionController.text = widget.equipment!.description ?? '';


    _quantityController.text = widget.equipment!.quantity?.toString() ?? '';
    available = widget.equipment!.available;

    setState((){
      photo = photoList;
      _photoControllers.addAll(photoList.map((item) => TextEditingController(text: item)));
    });

  }

  @override
  void dispose() {
    _idShopController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _photoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPhotoField() {
    setState(() {
      _photoControllers.add(TextEditingController());
      photo.add('');
    });
  }

  void _removePhotoField(int index) {
    setState(() {
      _photoControllers[index].dispose();
      _photoControllers.removeAt(index);
      photo.removeAt(index);
    });
  }


  @override
  Widget build(BuildContext context) {
    if(widget.equipment != null){
      pageTile = AppLocalizations.of(context)!.edit;
    }else{
      pageTile = AppLocalizations.of(context)!.add;
    }
    return Form(
      key: _formKey,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget> [
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
          TextFormField(
            controller: _idShopController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.equipmentIdShop,
              labelText: AppLocalizations.of(context)!.equipmentIdShop,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
          ),

          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.equipmentName,
              labelText: AppLocalizations.of(context)!.equipmentName,
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

          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.equipmentDescription,
              labelText: AppLocalizations.of(context)!.equipmentDescription,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
          ),

          const Text("Add Photos:"),
          ..._photoControllers.asMap().entries.map((entry) {
            int index = entry.key;
            return ListTile(
              title: TextFormField(
                controller: _photoControllers[index],
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.photoAdd,
                  labelText: AppLocalizations.of(context)!.photoAdd,
                  labelStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.lightBlue,
                    backgroundColor: Colors.white,
                  ),
                  focusedBorder: const OutlineInputBorder(gapPadding: 15),
                  border: const OutlineInputBorder(gapPadding: 5),
                ),
                onChanged: (val) {
                  setState(() {
                    photo[index] = val;
                  });
                },
              ),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () => _removePhotoField(index),
              ),
            );
          }),
          TextButton(
            onPressed: _addPhotoField,
            child: const Text("Add photo link"),
          ),

          const SizedBox(height: 20),
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.equipmentQuantity,
              labelText: AppLocalizations.of(context)!.equipmentQuantity,
              labelStyle: const TextStyle(
                fontSize: 20,
                color: Colors.lightBlue,
                backgroundColor: Colors.white,
              ),
              focusedBorder: const OutlineInputBorder(gapPadding: 15),
              border: const OutlineInputBorder(gapPadding: 5),
            ),
          ),


          const SizedBox(height: 50),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(250, 60),
            ),
            child: Text(
              AppLocalizations.of(context)!.confirm,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try{
                  int? parsedQuantity = int.tryParse(_quantityController.text.trim());
                  if (parsedQuantity == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.equipmentEnterQuantity)),
                    );
                    return;
                  }
                  // List<String> cleanedPhotos = photo?.where((p) => p.trim().isNotEmpty).toList() ?? [];

                  DateTime dateCreation = widget.equipment?.createdAt ?? DateTime.now();
                  Equipment newEquipment = Equipment(
                    idShop: _idShopController.text,
                    name: _nameController.text,
                    description: _descriptionController.text,
                    photo: photo,
                    quantity: parsedQuantity,
                    available: available ?? false,
                    createdAt: dateCreation,
                    updatedAt: DateTime.now(),
                  );

                  if (widget.equipment == null) {
                    insertEquipment(db, newEquipment, "");
                  } else {
                    updateEquipment(db, newEquipment, widget.equipmentID!);
                  }
                  widget.onEquipmentAdded?.call();
                }
                catch(e){
                  print("Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.errorSavingData)),
                  );
                }
              }
            }),
        ],
      )
    );
  }
}
