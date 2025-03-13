import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/equipment/equipment.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/widgets/base_page.dart';
import 'package:flutter_application_1/pages/camion/camion_list.dart';
import 'package:flutter_application_1/pages/camion/camion_type_list.dart';
import 'package:flutter_application_1/pages/equipment/add_equipment_form.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/equipments_table.dart';
import 'package:flutter_application_1/services/sync_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
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
  late MyUser _user;
  late String _userId;
  bool _isLoading = true;

  late AuthController authController;
  late UserService userService;
  late NetworkService networkService;
  Map<String, Equipment> _equipmentLists = HashMap();

  /// todo repair names order and showing photo(s)
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _initDatabase();
    await _initService();
    if (!networkService.isOnline) {
      print("Offline mode, no user update possible");
    }else{
      await _loadUserToConnection();
    }
    await _loadUser();
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible");
    }{
      await _syncData();
    }
    await _loadDataFromDatabase();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _initService() async {
    try {
      authController = AuthController();
      userService = UserService();
      networkService = Provider.of<NetworkService>(context, listen: false);
    } catch (e) {
      print("Error loading services: $e");
    }
  }

  Future<void> _loadUserToConnection() async {
    Map<String, MyUser>? users = await getThisUser(db);
    if(users != null ){
      return;
    }
    try {
      MyUser user = await userService.getCurrentUserData();
      String? userId = await userService.userID;
      final syncService = Provider.of<SyncService>(context, listen: false);
      await syncService.fullSyncTable("users", user: user, userId: userId);
    } catch (e) {
      print("💽 Error loading user: $e");
    }
  }

  Future<void> _loadUser() async {
    try {
      Map<String, MyUser>? users = await getThisUser(db);
      MyUser user = users!.values.first;
      String? userId = users.keys.first;
      _userId = userId;
      _user = user;
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _syncData() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Users...");
      await syncService.fullSyncTable("users", user: _user, userId: _userId);
      print("💽 Synchronizing Equipments...");
      await syncService.fullSyncTable("equipments", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }

  Future<void> _loadDataFromDatabase() async {
    Map<String, Equipment>? equipmentLists = await getAllEquipments(db, _user.role);
    setState(() {
      _equipmentLists = equipmentLists!;
    });
  }

  bool _isSuperAdmin() {
    return _user.role == 'superadmin';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
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
      );
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
              // Icône stylisée
              Widget leading = Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.cell_tower_outlined, color: Colors.black, size: 50),
              );

              Equipment equipment = _equipmentLists.values.elementAt(index);
              String equipmentId = _equipmentLists.keys.elementAt(index);
              String isDeleted = "";
              if(equipment.deletedAt != null){
                isDeleted = " (deleted)";
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(12.0),
                  child: ExpansionTile(
                    leading: leading,
                    title: Text(
                      "${equipment.name}$isDeleted",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
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
                        } else if (value == 'restore') {
                          await restoreEquipment(db, equipmentId);
                          if (networkService.isOnline) {
                            await _syncEquipments();
                          }
                          await _loadDataFromDatabase();
                          setState(() {});
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                         value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.edit),
                            ],
                          ),
                        ),
                        if (_isSuperAdmin())
                          equipment.deletedAt == null
                            ? PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.redAccent),
                                  SizedBox(width: 8),
                                  Text(AppLocalizations.of(context)!.delete),
                                ],
                              ),
                            )
                              : PopupMenuItem(
                            value: 'restore',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.restore),
                              ],
                            ),
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
                      Container(
                        margin: EdgeInsets.only(top: 8.0),
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          "${AppLocalizations.of(context)!.equipmentDescription}: ${equipment.description}",
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
    if(_isSuperAdmin()){
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
            onEquipmentAdded: () async {
              // on accept, sync and reload data then refresh page
              if (networkService.isOnline) {
                await _syncEquipments();
              }
              await _loadDataFromDatabase();
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
            onPressed: () async {
              await softDeleteEquipment(db, equipmentID);
              if (networkService.isOnline) {
                await _syncEquipments();
              }
              await _loadDataFromDatabase();
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

  Future<void> _syncEquipments() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Equipments...");
      await syncService.fullSyncTable("equipments", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }
}
