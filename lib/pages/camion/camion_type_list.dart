import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/camion/add_camion_type_form.dart';
import 'package:flutter_application_1/pages/camion/camion_list.dart';
import 'package:flutter_application_1/pages/equipment/equipment_list.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local/check_list/list_of_lists_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/equipments_table.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
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
  late MyUser _user;
  late String _userId;
  bool _isLoading = true;
  late Map<String, String> _availableLolMap;
  late Map<String, String> _equipmentLists;
  late Map<String, CamionType> _camionTypesList;

  late AuthController authController;
  late UserService userService;
  late NetworkService networkService;

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
    print("LoL control page user to connection firebase ☢☢☢☢☢☢☢");
    Map<String, MyUser>? users = await getThisUser(db);
    print("users: $users");
    if(users != null ){
      return;
    }
    try {
      MyUser user = await userService.getCurrentUserData();
      print("user ☢☢☢☢☢☢☢ $user");
      String? userId = await userService.userID;
      print("userId ☢☢☢☢☢☢☢ $userId");
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Users...");
      await syncService.fullSyncTable("users", user: user, userId: userId);
    } catch (e) {
      print("💽 Error loading user: $e");
    }
  }

  Future<void> _loadUser() async {
    print("LoL control page local ☢☢☢☢☢☢☢");
    try {
      Map<String, MyUser>? users = await getThisUser(db);
      print("connected as  $users");
      MyUser user = users!.values.first;
      print("local user ☢☢☢☢☢☢☢ $user");
      String? userId = users.keys.first;
      print("local userId ☢☢☢☢☢☢☢ $userId");
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
      print("💽 Synchronizing users Camions...");
      await syncService.fullSyncTable("camions", user: _user, userId: _userId);
      List<String> camionsTypeIdList = [];
      await getAllCamions(db, _user.role).then((camionsMap) {
        if(camionsMap != null){
          for(var camion in camionsMap.entries){
            if(!camionsTypeIdList.contains(camion.value.camionType)){
              camionsTypeIdList.add(camion.value.camionType);
            }
          }
        }
      });
      print("💽 Synchronizing CamionTypess...");
      await syncService.fullSyncTable("camionTypes",  user: _user, userId: _userId, dataPlus: camionsTypeIdList);
      List<String> camionListOfListId = [];
      Map<String, CamionType>? camionTypesMap = await getAllCamionTypes(db, _user.role);
      if(camionTypesMap != null){
        for(var camionType in camionTypesMap.entries){
          if(camionType.value.lol != null){
            for(var list in camionType.value.lol!){
              if(!camionListOfListId.contains(list)){
                camionListOfListId.add(list);
              }
            }
          }
        }
      }
      print("💽 Synchronizing Companies...");
      await syncService.fullSyncTable("companies", user: _user, userId: _userId);
      print("💽 Synchronizing Equipments...");
      await syncService.fullSyncTable("equipments", user: _user, userId: _userId);
      print("💽 Synchronizing LOL...");
      await syncService.fullSyncTable("listOfLists",  user: _user, userId: _userId, dataPlus: camionListOfListId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }

  Future<void> _loadDataFromDatabase() async {
    await _loadEquipmentLists();
    await _loadCamionTypesList();
    await _loadAvailableLolMaps();
  }

  Future<void> _loadEquipmentLists() async {
    Map<String, String>? equipmentLists = await getAllEquipmentsNames(db, _user.role);
    if(equipmentLists != null){
      _equipmentLists = equipmentLists;
    }else {
      _equipmentLists = {};
    }
  }

  Future<void> _loadCamionTypesList() async {
    Map<String, CamionType>? camionTypesList = await getAllCamionTypes(db, _user.role);
    if(camionTypesList != null){
      _camionTypesList = camionTypesList;
    }else {
      _camionTypesList = {};
    }
  }

  Future<void> _loadAvailableLolMaps() async {
    Map<String, ListOfLists>? listOfLists = await getAllLists(db, _user.role);
    var temp = listOfLists?.map((key, list) => MapEntry(key, list.listName));
    if(temp != null){
      _availableLolMap = temp;
    }else {
      _availableLolMap = {};
    }
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
        body: DefaultTabController(
          initialIndex: 0,
          length: _camionTypesList.length,
          child: BasePage(
            title: title(_user),
            body: _buildBody(),
          ),
        ),
        floatingActionButton: Visibility(
          visible: _user.role == 'superadmin',
          child: FloatingActionButton(
            heroTag: "addCamionTypeHero",
            onPressed: () {
              showCamionTypeModal();
            },
            child: const Icon(
              Icons.fire_truck,
              color: Colors.white,
            ),
          ),
        )
    );
  }

  Future<Map<String, CamionType>> getCamionTypesData(MyUser user) async {
    Map<String, CamionType>? list = await getAllCamionTypes(db, _user.role);
    if(list != null){
      return list;
    }else{
      return {};
    }
  }

  Widget _buildBody() {
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
            itemCount: _camionTypesList.length,
            itemBuilder: (_, index) {
              Widget leading = const Icon(Icons.fire_truck, color: Colors.deepPurple, size: 60);

              CamionType camionType = _camionTypesList.values.elementAt(index);
              String isDeleted = "";
              if(camionType.deletedAt != null){
                isDeleted = " (deleted)";
              }
              return Padding(
                padding: const EdgeInsets.all(8),
                child: ExpansionTile(
                  leading: leading,
                  title: Text(
                    "${camionType.name}$isDeleted",
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
                          camionTypeID: _camionTypesList.keys.elementAt(index),
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(_camionTypesList.keys.elementAt(index));
                      } else if (value == 'restore') {
                        await restoreCamionType(db, _camionTypesList.keys.elementAt(index));
                        if (networkService.isOnline) {
                          await _syncCamionsType();
                        }
                        await _loadDataFromDatabase();
                        setState(() {});
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(AppLocalizations.of(context)!.edit),
                      ),
                      if (_user.role == "superadmin")
                        camionType.deletedAt == null
                          ? PopupMenuItem(
                            value: 'delete',
                            child: Text(AppLocalizations.of(context)!.delete),
                        )
                          : PopupMenuItem(
                            value: 'restore',
                            child: Text(AppLocalizations.of(context)!.restore),
                        ),
                    ],
                  ),
                  children: [
                    Wrap(
                      spacing: 16.0,
                      runSpacing: 16.0,
                      children: [
                        // Affichage de la liste "List of lists"
                        if (camionType.lol != null)
                          SizedBox(
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
                                  child: Text(_availableLolMap[item] ?? "Unknown list!", style: textStyle()),
                                )),
                              ],
                            ),
                          ),

                        // Affichage de la liste "equipment"
                        if (camionType.equipment != null)
                          SizedBox(
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
                                  child: Text(_equipmentLists[item] ?? "Unknown equipment!", style: textStyle()),
                                )),
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
            availableLolMap: _availableLolMap,
            equipmentLists: _equipmentLists,
            onCamionTypeAdded: () async {
              if (networkService.isOnline) {
                await _syncCamionsType();
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
            onPressed: () async {
              await softDeleteCamionType(db, camionTypeID);
              if (networkService.isOnline) {
                await _syncCamionsType();
              }
              await _loadDataFromDatabase();
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.yes, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _syncCamionsType() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      List<String> camionsTypeIdList = [];
      await getAllCamions(db, _user.role).then((camionsMap) {
        if(camionsMap != null){
          for(var camion in camionsMap.entries){
            if(!camionsTypeIdList.contains(camion.value.camionType)){
              camionsTypeIdList.add(camion.value.camionType);
            }
          }
        }
      });
      print("💽 Synchronizing CamionTypess...");
      await syncService.fullSyncTable("camionTypes",  user: _user, userId: _userId, dataPlus: camionsTypeIdList);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }
}
