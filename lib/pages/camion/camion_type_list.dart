import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/camion/add_camion_type_form.dart';
import 'package:flutter_application_1/pages/camion/camion_list.dart';
import 'package:flutter_application_1/pages/equipment/equipment_list.dart';
import 'package:flutter_application_1/services/check_list/database_list_of_lists_service.dart';
import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/equipments_table.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class CamionTypeList extends StatefulWidget {
  const CamionTypeList({super.key});

  @override
  State<CamionTypeList> createState() => _CamionTypeListState();
}

class _CamionTypeListState extends State<CamionTypeList> {
  late Database db;
  DatabaseListOfListsService databaseListOfListsService = DatabaseListOfListsService();
  Future<MyUser>? _futureUser;
  Map<String, String> availableLolMap = {};
  Map<String, String>? _equipmentLists;

  @override
  void initState() {
    super.initState();
    _futureUser = getUser();
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    await _initDatabase();
    await _syncDatas();
    Map<String, ListOfLists> listOfLists = await databaseListOfListsService.getAllListsWithId();
    _equipmentLists = await getAllEquipmentsNames(db);

    setState(() {
      availableLolMap = listOfLists.map((key, list) => MapEntry(key, list.listName));
    });
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _syncDatas() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("Synchronizing CamionTypess...");
      await syncService.fullSyncTable("camionTypes");
      print("Synchronization with SQLite completed.");
    } catch (e) {
      print("Error during synchronization with SQLite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MyUser>(
      future: _futureUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          MyUser user = snapshot.data!;
          return Scaffold(
              body: FutureBuilder(
                future: getCamionTypesData(user),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    Map<String, CamionType> camionTypesList = snapshot.data!;
                    return DefaultTabController(
                      initialIndex: 0,
                      length: camionTypesList.length,
                      child: BasePage(
                        title: title(user),
                        body: _buildBody(camionTypesList, user),
                      ),
                    );
                  }
                },
              ),
              floatingActionButton: Visibility(
                visible: user.role == 'superadmin',
                child: FloatingActionButton(
                  heroTag: "addCamionTypeHero",
                  onPressed: () {
                    showCamionTypeModal();
                  },
                  // backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.fire_truck,
                    color: Colors.white,
                  ),
                ),
              )
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<MyUser> getUser() async {
    UserService userService = UserService();
    return await userService.getCurrentUserData();
  }

  Future<Map<String, CamionType>> getCamionTypesData(MyUser user) async {
    Map<String, CamionType>? list = await getAllCamionTypes(db);
    if(list != null){
      return list;
    }else{
      return {};
    }
  }

  Widget _buildBody(Map<String, CamionType> camionTypeList, MyUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
              onPressed: null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(AppLocalizations.of(context)!.camionMenuTypes),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EquipmentList()),
                );
              },
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
            itemCount: camionTypeList.length,
            itemBuilder: (_, index) {
              Widget leading = const Icon(Icons.fire_truck, color: Colors.deepPurple, size: 60);

              CamionType camionType = camionTypeList.values.elementAt(index);

              return Padding(
                padding: const EdgeInsets.all(8),
                child: ExpansionTile(
                  leading: leading,
                  title: Text(
                    camionType.name,
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        showCamionTypeModal(
                          camionType: camionType,
                          camionTypeID: camionTypeList.keys.elementAt(index),
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(camionTypeList.keys.elementAt(index));
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(AppLocalizations.of(context)!.edit),
                      ),
                      if (user.role == "superadmin")
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(AppLocalizations.of(context)!.delete),
                        ),
                    ],
                  ),
                  children: [
                    Wrap(
                      spacing: 16.0,
                      runSpacing: 16.0,
                      children: [
                        // Wyświetlanie listy "lol"
                        if (camionType.lol != null)
                          Container(
                            width: 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("List of lists:", style: textStyleBold()),
                                ...camionType.lol!.map((item) => Container(
                                  margin: EdgeInsets.only(top: 8.0),
                                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorLight,
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
                                  child: Text(availableLolMap[item] ?? "Unknown list!", style: textStyle()),
                                )).toList(),
                              ],
                            ),
                          ),

                        // Wyświetlanie listy "equipment"
                        if (camionType.equipment != null)
                          Container(
                            width: 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Equipment:", style: textStyleBold()),
                                ...camionType.equipment!.map((item) => Container(
                                  margin: EdgeInsets.only(top: 8.0),
                                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorLight,
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
                                  child: Text(_equipmentLists?[item] ?? "Unknown equipment!", style: textStyle()),
                                )).toList(),
                              ],
                            ),
                          ),
                      ],
                    )
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

  String title(MyUser user) {
    if(user.role == "superadmin"){
      return AppLocalizations.of(context)!.camionTypesList;
    }else{
      return AppLocalizations.of(context)!.details;
    }
  }
  void showCamionTypeModal({
    CamionType? camionType,
    String? camionTypeID,
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
          child: AddCamionType(
            camionType: camionType,
            camionTypeID: camionTypeID,
            onCamionTypeAdded: () {
              setState(() {});
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(String camionTypeID) {
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
              softDeleteCamionType(db, camionTypeID);
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
