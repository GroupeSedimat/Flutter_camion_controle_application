import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
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
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class ListOfListsControlPage extends StatefulWidget {
  const ListOfListsControlPage({super.key});

  @override
  State<ListOfListsControlPage> createState() => _ListOfListsControlPageState();
}

class _ListOfListsControlPageState extends State<ListOfListsControlPage> {
  late Database db;
  late MyUser _user;
  late String _userId;
  bool _isLoading = true;
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
    await _initService();
    if (!networkService.isOnline) {
      print("Offline mode, no user update possible");
    } else {
      await _loadUserToConnection();
    }
    await _loadUser();
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible");
    }
    {
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
    if (users != null) {
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
      print("💽 Synchronizing users Camions...");
      await syncService.fullSyncTable("camions", user: _user, userId: _userId);
      List<String> camionsTypeIdList = [];
      await getAllCamions(db, _user.role).then((camionsMap) {
        if (camionsMap != null) {
          for (var camion in camionsMap.entries) {
            if (!camionsTypeIdList.contains(camion.value.camionType)) {
              camionsTypeIdList.add(camion.value.camionType);
            }
          }
        }
      });
      print("💽 Synchronizing CamionTypess...");
      await syncService.fullSyncTable("camionTypes",
          user: _user, userId: _userId, dataPlus: camionsTypeIdList);
      List<String> camionListOfListId = [];
      Map<String, CamionType>? camionTypesMap =
          await getAllCamionTypes(db, _user.role);
      if (camionTypesMap != null) {
        for (var camionType in camionTypesMap.entries) {
          if (camionType.value.lol != null) {
            for (var list in camionType.value.lol!) {
              if (!camionListOfListId.contains(list)) {
                camionListOfListId.add(list);
              }
            }
          }
        }
      }
      print("💽 Synchronizing LOL...");
      await syncService.fullSyncTable("listOfLists",
          user: _user, userId: _userId, dataPlus: camionListOfListId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }

  Future<void> _loadDataFromDatabase() async {
    await _loadListOfLists();
    await _loadUsersNames();
  }

  Future<void> _loadListOfLists() async {
    try {
      Map<String, ListOfLists>? listOfListsFuture =
          await getAllLists(db, _user.role);
      if (listOfListsFuture != null) {
        _listOfLists = listOfListsFuture;
      }
    } catch (e) {
      print("Error loading list of lists: $e");
    }
  }

  Future<void> _loadUsersNames() async {
    try {
      Map<String, String>? usersNames = await getAllUsersNames(db, _user.role);
      if (usersNames != null) {
        _userMap = usersNames;
      }
    } catch (e) {
      print("Error loading list of lists: $e");
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
        String isDeleted;
        if (listItem.deletedAt != null) {
          isDeleted = " (deleted)";
        } else {
          isDeleted = "";
        }
        return Padding(
            padding: EdgeInsets.all(8),
            child: Card(
              color: Theme.of(context).primaryColor.withOpacity(0.4),
              child: ExpansionTile(
                leading: Icon(Icons.edit, color: Colors.black, size: 50),
                title: Text(
                  "${listItem.listNr}. ${listItem.listName}$isDeleted",
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
                            onListAdded: () async {
                              // on accept, sync and reload data then refresh page
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
                        if (networkService.isOnline) {
                          await _syncData();
                        }
                        await _loadDataFromDatabase();
                        setState(() {});
                      }
                    } else if (value == 'restore') {
                      await restoreList(db, key);
                      if (networkService.isOnline) {
                        await _syncData();
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
                    listItem.deletedAt == null
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
              ),
            ));
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
        ) ??
        false;
  }
}
