import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/equipment/equipment.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/camion/camion_list.dart';
import 'package:flutter_application_1/pages/camion/camion_type_list.dart';
import 'package:flutter_application_1/pages/equipment/add_equipment_form.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/equipments_table.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class EquipmentList extends StatefulWidget {
  const EquipmentList({super.key});

  @override
  State<EquipmentList> createState() => _EquipmentListState();
}

class _EquipmentListState extends State<EquipmentList> {
  late Database db;
  Map<String, Equipment> _equipmentLists = HashMap();
  MyUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    await _initDatabase();
    await _syncData();
    Map<String, Equipment>? equipmentLists = await getAllEquipments(db);
    setState(() {
      _equipmentLists = equipmentLists!;
    });
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _loadUser() async {
    try {
      MyUser user = await getUser();
      setState(() {
        _user = user;
      });
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _syncData() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("++++ Synchronizing Equipments...");
      await syncService.fullSyncTable("equipments");
      print("++++ Synchronization with SQLite completed.");
    } catch (e) {
      print("++++ Error during synchronization with SQLite: $e");
    }
  }

  bool _isSuperAdmin() {
    return _user?.role == 'superadmin';
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null || _equipmentLists.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: BasePage(
        title: title(),
        body: _buildBody(),
      ),
      floatingActionButton: Visibility(
        visible: _isSuperAdmin(),
        child: FloatingActionButton(
          heroTag: "addEquipmentHero",
          onPressed: () {
            showEquipmentModal();
          },
          child: const Icon(Icons.fire_truck, color: Colors.white),
        ),
      ),
    );
  }

  Future<MyUser> getUser() async {
    UserService userService = UserService();
    return await userService.getCurrentUserData();
  }

  Widget _buildBody() {
    return Column(
      children: [
        Wrap(
          spacing: 30,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CamionList()),
                );
              },
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(AppLocalizations.of(context)!.camionMenuTrucks),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CamionTypeList()),
                );
              },
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(AppLocalizations.of(context)!.camionMenuTypes),
            ),
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(AppLocalizations.of(context)!.camionMenuEquipment),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 50),
            itemCount: _equipmentLists.length,
            itemBuilder: (_, index) {
              Widget leading = const Icon(Icons.cell_tower_outlined, color: Colors.deepPurple, size: 60);

              Equipment equipment = _equipmentLists.values.elementAt(index);
              String equipmentId = _equipmentLists.keys.elementAt(index);

              return Padding(
                padding: const EdgeInsets.all(8),
                child: ExpansionTile(
                  leading: leading,
                  title: Text(
                    equipment.name,
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        showEquipmentModal(
                          equipment: equipment,
                          equipmentID: equipmentId,
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(equipmentId);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(AppLocalizations.of(context)!.edit),
                      ),
                      if (_user!.role == "superadmin")
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(AppLocalizations.of(context)!.delete),
                        ),
                    ],
                  ),
                  children: [
                    if(equipment.idShop != "")
                    SizedBox(
                      child: Text(
                        "${AppLocalizations.of(context)!.equipmentIdShop}: ${equipment.idShop }",
                        style: textStyle(),
                      ),
                    ),
                    if(equipment.description != "")
                    SizedBox(
                      child: Text(
                        "${AppLocalizations.of(context)!.equipmentDescription}: ${equipment.description }",
                        style: textStyle(),
                      ),
                    ),
                    if(equipment.quantity != null)
                    SizedBox(
                      child: Text(
                        "${AppLocalizations.of(context)!.equipmentQuantity}: ${equipment.quantity }",
                        style: textStyle(),
                      ),
                    ),
                    if(equipment.photo != null)
                    SizedBox(
                      child: Text(
                        "${AppLocalizations.of(context)!.photoGallery}: ${equipment.photo.toString()}",
                        style: textStyle(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  TextStyle textStyle(){
    return TextStyle(fontSize: 20);
  }
  TextStyle textStyleBold(){
    return TextStyle(fontSize: 25, fontWeight: FontWeight.bold);
  }

  String title() {
    if(_user!.role == "superadmin"){
      return AppLocalizations.of(context)!.equipmentList;
    }else{
      return AppLocalizations.of(context)!.equipmentDescription;
    }
  }
  void showEquipmentModal({
    Equipment? equipment,
    String? equipmentID,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.fromLTRB(
              10, 50, 10, MediaQuery.of(context).viewInsets.bottom
          ),
          child: AddEquipment(
            equipment: equipment,
            equipmentID: equipmentID,
            onEquipmentAdded: () {
              setState(() {});
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(String equipmentID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDelete),
        content: Text(AppLocalizations.of(context)!.confirmDeleteText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.no),
          ),
          TextButton(
            onPressed: () {
              softDeleteEquipment(db, equipmentID);
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.yes, style: TextStyle(color: Colors.red)),
            // AppLocalizations.of(context)!
          ),
        ],
      ),
    );
  }
}
