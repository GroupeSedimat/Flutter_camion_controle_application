import 'package:flutter/material.dart';
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
import 'package:flutter_application_1/services/database_local/check_list/blueprints_table.dart';
import 'package:flutter_application_1/services/database_local/check_list/list_of_lists_table.dart';
import 'package:flutter_application_1/services/database_local/check_list/tasks_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/pdf/pdf_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  late List<int> counter;
  late Map<String, ListOfLists> _listOfLists = {};
  late Map<String, Blueprint> _blueprints = {};
  late Map<String, TaskChecklist> _tasks = {};

  final PdfService pdfService = PdfService();
  final UserService userService = UserService();
  AuthController authController = AuthController.instance;


  @override
  void initState() {
    super.initState();
    _initDatabase();
    _loadData();
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _loadData() async {
    await _loadUser();
    await _syncDatas();
    await _loadListOfLists();
    await _loadBlueprints();
    await _loadTasks();
  }

  Future<void> _syncDatas() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("++++ Synchronizing List of Lists...");
      await syncService.fullSyncTable("listOfLists");
      print("++++ Synchronizing Blueprints...");
      await syncService.fullSyncTable("blueprints");
      print("++++ Synchronizing Validate Tasks...");
      await syncService.fullSyncTable("validateTasks");
      print("++++ Synchronization with SQLite completed.");
    } catch (e) {
      print("Error during global data synchronization: $e");
      rethrow;
    }
  }

  Future<void> _loadUser() async {
    try {
      UserService userService = UserService();
      MyUser user = await userService.getCurrentUserData();
      String userId = userService.userID!;
      setState(() {
        _user = user;
        _userId = userId;
      });
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _loadBlueprints() async {
    Map<String, Blueprint>? blueprints = await getAllBlueprints(db);
    if(blueprints != null){
      setState(() {
        _blueprints = blueprints;
      });
    }
  }

  Future<void> _loadTasks() async {
    Map<String, TaskChecklist>? tasks = await getAllTasksOfUser(db, _userId);
    if(tasks != null){
      setState(() {
        _tasks = tasks;
      });
    }
  }

  Future<void> _loadListOfLists() async {
    try {
      Map<String, ListOfLists>? listOfListsFuture = await getAllLists(db);
      if(listOfListsFuture != null){
        setState(() {
          _listOfLists = listOfListsFuture;
        });
      }
    } catch (e) {
      print("Error loading list of lists: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_listOfLists.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      return DefaultTabController(
        initialIndex: 0,
        length: _listOfLists.length,
        child: BasePage(
          appBar: appBar(),
          body: body(),
        ),
      );
    }
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
          onBlueprintAdded: () {
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
                  await _syncDatas();
                  if (mounted) {
                    setState(() {});
                    Navigator.pop(context);
                  }
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
    List<String> validatedTask = await getUserOneListOfTasks(db, userUID, listNr);
    for (String taskID in validatedTask) {
      await deleteTask(db, taskID);
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
    if (_listOfLists.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    String? userUID = authController.getCurrentUserUID();
    if (userUID == null) {
      return const Center(child: Text("User not logged in"));
    }

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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(AppLocalizations.of(context)!.confirmDelete),
                          content: Text(AppLocalizations.of(context)!.confirmDeleteText),
                          actions: [
                            TextButton(
                              child: Text(AppLocalizations.of(context)!.no),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text(AppLocalizations.of(context)!.yes),
                              onPressed: () {
                                Navigator.of(context).pop();
                                String key = _blueprints.keys
                                    .firstWhere((k) => _blueprints[k] == blueprint);
                                softDeleteBlueprints(db, key);
                              },
                            ),
                          ],
                        );
                      },
                    );
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
                ),
              const SizedBox(height: 10),
              if (_user.role == 'superadmin')
                FloatingActionButton(
                  heroTag: "addBlueprintHero${list.listNr}",
                  onPressed: () {
                    showBlueprintModal(
                      nrOfList: list.listNr,
                      nrEntryPosition: (_blueprints.values
                          .where((b) => b.nrOfList == list.listNr)
                          .length +
                          1),
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
                      _tasks,
                      _blueprints,
                      list,
                    );
                    await pdfService.savePdfFile(
                      _user.company,
                      pdfData,
                          () => deleteOneTasksListForUser(list.listNr, userUID),
                    );
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
}
