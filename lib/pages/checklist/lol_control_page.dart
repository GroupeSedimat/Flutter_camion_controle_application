import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/checklist/add_list_form.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local/check_list/list_of_lists_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class ListOfListsControlPage extends StatefulWidget {
  const ListOfListsControlPage({super.key});

  @override
  State<ListOfListsControlPage> createState() => _ListOfListsControlPageState();
}

class _ListOfListsControlPageState extends State<ListOfListsControlPage> {

  late Database db;
  MyUser? _user;
  String? _userId;
  Map<String, ListOfLists> _listOfLists = {};
  Map<String, String> _userMap = {};
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
    await _initServices();
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
    setState((){});
  }

  Future<void> _loadDataFromDatabase() async {
    Map<String, ListOfLists>? listOfLists = await getAllLists(db) ?? {};
    Map<String, String> usersNames = await getAllUsersNames(db) ?? {};
    setState(() {
      _listOfLists = listOfLists;
      _userMap = usersNames;
    });
  }

  Future<void> _initServices() async {
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

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _syncData() async {

    if (_user == null || _userId == null) {
      print("Cannot sync data: user or userID is not loaded");
      return;
    }else{
      print("Can sync data: user: ${_user!.name} is loaded");
    }
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Users...");
      await syncService.fullSyncTable("users", user: _user, userId: _userId);
      print("💽 Synchronizing users Camions...");
      await syncService.fullSyncTable("camions", user: _user, userId: _userId);
      List<String> camionsTypeIdList = [];
      await getAllCamions(db).then((camionsMap) {
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
      Map<String, CamionType>? camionTypesMap = await getAllCamionTypes(db);
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
      print("Camion List of Lists Ids: $camionListOfListId");
      print("💽 Synchronizing LOL...");
      await syncService.fullSyncTable("listOfLists",  user: _user, userId: _userId, dataPlus: camionListOfListId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// delete DefaultTabController??
      body: DefaultTabController(
        initialIndex: 0,
        length: _listOfLists.length,
        child: BasePage(
          title: AppLocalizations.of(context)!.listOfLists,
          body: body(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddListForm(),
            ),
          );
          setState(() {});
        },
        tooltip: AppLocalizations.of(context)!.lOLAdd,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget body() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 50),
      itemCount: _listOfLists.length,
      itemBuilder: (_, index) {
        String key = _listOfLists.keys.elementAt(index);
        ListOfLists listItem = _listOfLists[key]!;
        print("List Item 💡💡💡 $listItem");
        return Padding(
          padding: EdgeInsets.all(8),
          child: Card(
            color: Theme.of(context).primaryColor.withOpacity(0.4),
            child: ExpansionTile(
              leading: const Icon(Icons.edit, color: Colors.deepPurple, size: 50),
              title: Text(
                  "${listItem.listNr}. ${listItem.listName}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
              ),
              trailing: PopupMenuButton(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddListForm(
                          listItem: listItem,
                          listItemID: key,
                          onListAdded:  () async {
                            // on accept sync and reload data then refresh page
                            await _syncData();
                            await _loadDataFromDatabase();
                            Navigator.pop(context);
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    bool confirmed = await _showConfirmationDialog(context);
                    if (confirmed) {
                      await softDeleteList(db, key);
                      // on delete sync and reload data then refresh page
                      await _syncData();
                      await _loadDataFromDatabase();
                      setState(() {});
                    }
                  }
                  setState(() {});
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(
                      AppLocalizations.of(context)!.edit,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      AppLocalizations.of(context)!.delete,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                ],
              ),
            ),
          )
        );
      },
    );
  }
  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDelete),
          content: Text(AppLocalizations.of(context)!.confirmDeleteText),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.no),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yes),
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }
}