import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/pages/checklist/add_blueprint_form.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/pages/checklist/blueprint_template.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/pages/checklist/validate_task.dart';
import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local/check_list/blueprints_table.dart';
import 'package:flutter_application_1/services/database_local/check_list/list_of_lists_table.dart';
import 'package:flutter_application_1/services/database_local/check_list/tasks_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/services/pdf/pdf_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_document/open_document.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class CheckList extends StatefulWidget {
  const CheckList({super.key});

  @override
  State<CheckList> createState() => _CheckListState();
}

class _CheckListState extends State<CheckList> {

  late Database db;
  late MyUser _user;
  late String _userId;
  bool _isLoading = true;
  late List<int> counter;
  late Map<String, ListOfLists> _listOfLists = {};
  late Map<String, Blueprint> _blueprints = {};
  late Map<String, TaskChecklist> _tasks = {};

  late AuthController authController;
  late UserService userService;
  late NetworkService networkService;
  final PdfService pdfService = PdfService();


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
    print("welcome user to connection firebase ☢☢☢☢☢☢☢");
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
    print("welcome page local ☢☢☢☢☢☢☢");
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
      print("💽 Synchronizing users...");
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
      print("💽 Synchronizing LOL...");
      await syncService.fullSyncTable("listOfLists",  user: _user, userId: _userId, dataPlus: camionListOfListId);
      print("💽 Synchronizing Blueprints...");
      await syncService.fullSyncTable("blueprints", user: _user, userId: _userId);
      print("💽 Synchronizing Validate Tasks...");
      await syncService.fullSyncTable("validateTasks", user: _user, userId: _userId);
      print("💽 Synchronizing PDFs...");
      await syncService.fullSyncTable("pdf", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during global data synchronization: $e");
      rethrow;
    }
  }

  Future<void> _loadDataFromDatabase() async {
    await _loadListOfLists();
    await _loadBlueprints();
    await _loadTasks();
  }

  Future<void> _loadBlueprints() async {
    Map<String, Blueprint>? blueprints = await getAllBlueprints(db, _user.role);
    if(blueprints != null){
      _blueprints = blueprints;
    }else{
      _blueprints = {};
    }
  }

  Future<void> _loadTasks() async {
    Map<String, TaskChecklist>? tasks = await getAllTasksOfUser(db, _userId);
    if(tasks != null){
      _tasks = tasks;
    }else{
      _tasks = {};
    }
  }

  Future<void> _loadListOfLists() async {
    try {
      Map<String, ListOfLists>? listOfListsFuture = await getAllLists(db, _user.role);
      if(listOfListsFuture != null){
        _listOfLists = listOfListsFuture;
      }else{
        _listOfLists = {};
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

    return DefaultTabController(
      initialIndex: 0,
      length: _listOfLists.length,
      child: BasePage(
        appBar: appBar(),
        body: body(),
      ),
    );

  }

  void showBlueprintModal({
    required int nrOfList,
    required int nrEntryPosition,
    Blueprint? blueprint,
    String? blueprintID,
  }){
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) {
      return Container(
        padding: const EdgeInsets.all(10),
        color: Colors.white,
        margin: EdgeInsets.fromLTRB(
            10, 50, 10, MediaQuery.of(context).viewInsets.bottom
        ),
        child: AddBlueprintForm(
          nrOfList: nrOfList,
          nrEntryPosition: nrEntryPosition,
          blueprint: blueprint,
          blueprintID: blueprintID,
          onBlueprintAdded: () async {
            if (networkService.isOnline) {
              await _syncBlueprints();
            }
            await _loadDataFromDatabase();
            setState(() {});
            Navigator.pop(context);
          },
        ),
      );
    });
  }

  void showTask(Blueprint blueprint) async {
    try {
      TaskChecklist validate = TaskChecklist(nrOfList: 0, nrEntryPosition: 0, createdAt: DateTime.now(), updatedAt: DateTime.now());
      for (TaskChecklist task in _tasks.values) {
        if (blueprint.nrOfList == task.nrOfList &&
            blueprint.nrEntryPosition == task.nrEntryPosition) {
          validate = task;
          break;
        }
      }

      String keyId = _tasks.keys.firstWhere(
            (k) => _tasks[k] == validate,
        orElse: () => '',
      );

      await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(
                  10, 50, 10, MediaQuery.of(context).viewInsets.bottom
              ),
              child: ValidateTask(
                blueprint: blueprint,
                validate: validate,
                keyId: keyId,
                onValidateAdded: () async {
                  await _syncData();
                  await _loadTasks();
                  setState(() {});
                  Navigator.pop(context);
                },
                userUID: _userId,
              ),
            );
          });
    } catch (e) {
      print("Error showing task: $e");
    }
  }

  Future<bool> testIfFull(Map<String, Blueprint> sortedBlueprints, int listNr, String userUID) async {
    Map<String, TaskChecklist>? validatedTask = await getAllTasksOfUser(db, userUID);
    TaskChecklist emptyTask = TaskChecklist(nrOfList: 0, nrEntryPosition: 0, createdAt: DateTime.now(), updatedAt: DateTime.now());
    for (Blueprint blueprint in sortedBlueprints.values) {
      if (blueprint.nrOfList == listNr) {
        int entryPosition = blueprint.nrEntryPosition;
        TaskChecklist task = validatedTask!.values.firstWhere(
              (element) => element.nrOfList == listNr && element.nrEntryPosition == entryPosition,
          orElse: () => emptyTask,
        );
        if (task.nrEntryPosition == 0) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> deleteOneTasksListForUser(int listNr, String userUID) async {
    Map<String, TaskChecklist> validatedTask = await getUserOneListOfTasks(db, userUID, listNr);
    for (var task in validatedTask.entries) {
      try {
        await deleteTask(db, task.key);
        Directory tempDir = await getApplicationDocumentsDirectory();
        String listNr = task.value.nrOfList.toString().padLeft(4, '0');
        String entryPos = task.value.nrEntryPosition.toString().padLeft(4, '0');
        final fileTemp = File("${tempDir.path}/$listNr${entryPos}photoValidate.jpeg");
        if (await fileTemp.exists()) {
          await fileTemp.delete();
        }

        print("The file with the path ${fileTemp.path} and name $listNr${entryPos}photoValidate.jpeg has been deleted.");
      } catch (e) {
        print("Error deleting file: $e");
      }
    }
    setState(() {});
  }

  AppBar appBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.checkList,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Get.to(() => SettingsPage());
          },
        ),
      ],
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor,
      bottom: TabBar(
        dividerColor: Colors.transparent,
        unselectedLabelColor: Colors.white,
        indicatorPadding: const EdgeInsets.only(left: -10, right: -10),
        indicatorWeight: 5,
        indicatorColor: Colors.red,
        labelColor: Colors.black,
        isScrollable: true,
        tabs: _listOfLists.values.map((blueprint) =>
            Tab(
              text: blueprint.listName,
            )).toList(),
      ),
    );
  }

  bool? taskIsDone(blueprint){
    TaskChecklist task = _tasks.values.firstWhere(
      (task) => task.nrEntryPosition == blueprint.nrEntryPosition && task.nrOfList == blueprint.nrOfList,
      orElse: () => TaskChecklist(nrOfList: 0, nrEntryPosition: 0, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    );
    return task.isDone;
  }

  Widget body() {
    return TabBarView(
      children: <Widget>[
        for (ListOfLists list in _listOfLists.values)
          ListView(
            padding: const EdgeInsets.all(16.0),
            scrollDirection: Axis.vertical,
            children: [
              for (Blueprint blueprint in _blueprints.values
                  .where((b) => b.nrOfList == list.listNr)
                  .toList()
                ..sort((a, b) => a.nrEntryPosition.compareTo(b.nrEntryPosition)))
                BlueprintTemplate(
                  isDone: taskIsDone(blueprint),
                  blueprint: blueprint,
                  role: _user.role,
                  delete: () {
                    String key = _blueprints.keys
                        .firstWhere((k) => _blueprints[k] == blueprint);
                    _showDeleteConfirmation(key);
                  },
                  validate: () {
                    showTask(blueprint);
                  },
                  edit: () {
                    String blueprintID = _blueprints.keys
                        .firstWhere((k) => _blueprints[k] == blueprint);
                    showBlueprintModal(
                      nrOfList: blueprint.nrOfList,
                      nrEntryPosition: blueprint.nrEntryPosition,
                      blueprint: blueprint,
                      blueprintID: blueprintID,
                    );
                  },
                  restore: () async {
                    String key = _blueprints.keys
                        .firstWhere((k) => _blueprints[k] == blueprint);
                    await restoreBlueprints(db, key);
                    if (networkService.isOnline) {
                      await _syncBlueprints();
                    }
                    await _loadDataFromDatabase();
                    setState(() {});
                  }
                ),
              const SizedBox(height: 10),
              if (_user.role == 'superadmin')
                FloatingActionButton(
                  heroTag: "addBlueprintHero${list.listNr}",
                  onPressed: () {
                    showBlueprintModal(
                      nrOfList: list.listNr,
                      nrEntryPosition: (_blueprints.values.where((b) => b.nrOfList == list.listNr).length + 1),
                      blueprint: null,
                      blueprintID: null,
                    );

                  },
                  child: const Icon(
                    Icons.add,
                    color: Colors.lightGreenAccent,
                  ),
                ),
              const SizedBox(height: 20),
              if ((_user.role == 'user' || _user.role == 'admin') &&
                  _tasks.values
                      .where((task) => task.nrOfList == list.listNr)
                      .length ==
                      _blueprints.values
                          .where((b) => b.nrOfList == list.listNr)
                          .length)
                FloatingActionButton(
                  heroTag: "makePDFHero${list.listNr}",
                  onPressed: () async {
                    final pdfData = await pdfService.createInvoice(
                      db,
                      _user,
                      _tasks,
                      _blueprints,
                      list,
                    );
                    String filePath = await pdfService.savePdfFile(
                      _user.company,
                      pdfData,
                      _user,
                      _userId,
                      () async {
                        await deleteOneTasksListForUser(list.listNr, _userId);
                        if (networkService.isOnline) {
                          await _syncTasks();
                        }
                        await _loadTasks();
                      },
                    );
                    setState((){});
                    OpenDocument.openDocument(filePath: filePath);
                  },
                  backgroundColor: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.pdfCreate,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }

  void _showDeleteConfirmation(String key) {
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
              await softDeleteBlueprints(db, key);
              if (networkService.isOnline) {
                await _syncBlueprints();
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

  Future<void> _syncBlueprints() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Blueprints...");
      await syncService.fullSyncTable("blueprints", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during global data synchronization: $e");
      rethrow;
    }
  }

  Future<void> _syncTasks() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Tasks...");
      await syncService.fullSyncTable("validateTasks", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during global data synchronization: $e");
      rethrow;
    }
  }
}
