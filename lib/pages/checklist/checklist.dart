import 'dart:collection';

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
import 'package:flutter_application_1/services/check_list/database_blueprints_service.dart';
import 'package:flutter_application_1/services/check_list/database_image_service.dart';
import 'package:flutter_application_1/services/check_list/database_list_of_lists_service.dart';
import 'package:flutter_application_1/services/check_list/database_tasks_service.dart';
import 'package:flutter_application_1/services/pdf/pdf_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CheckList extends StatefulWidget {
  const CheckList({super.key});

  @override
  State<CheckList> createState() => _CheckListState();
}

class _CheckListState extends State<CheckList> {

  final DatabaseBlueprintsService databaseBlueprintsService = DatabaseBlueprintsService();
  final DatabaseTasksService databaseTasksService = DatabaseTasksService();
  final DatabaseImageService databaseImageService = DatabaseImageService();
  final DatabaseListOfListsService databaseListOfListsService = DatabaseListOfListsService();
  final PdfService pdfService = PdfService();
  final UserService userService = UserService();
  AuthController authController = AuthController.instance;

  late Future<List<ListOfLists>> listOfListsFuture;
  late List<int> counter;

  @override
  void initState() {
    super.initState();
    String? userID = userService.userID;
    listOfListsFuture = databaseListOfListsService.getListsWithType(userID!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ListOfLists>>(
      future: listOfListsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error1: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.dataNoData));
        } else {
          List<ListOfLists> listOfLists = snapshot.data!;
          return DefaultTabController(
            initialIndex: 0,
            length: listOfLists.length,
            child: BasePage(
              appBar: appBar(listOfLists),
              body: body(listOfLists),
            ),
          );
        }
      },
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
          databaseBlueprintsService: databaseBlueprintsService,
          blueprint: blueprint,
          blueprintID: blueprintID,
        ),
      );
    });
  }

  void showTask(Blueprint blueprint) async {
    try {
      String? userUID = authController.getCurrentUserUID();
      if(userUID != null){
        Map<String, TaskChecklist> tasks = await databaseTasksService.getAllTasks(userUID);
        TaskChecklist validate = TaskChecklist();
        for (TaskChecklist task in tasks.values) {
          if (blueprint.nrOfList == task.nrOfList &&
              blueprint.nrEntryPosition == task.nrEntryPosition) {
            validate = task;
            break;
          }
        }

        String keyId = tasks.keys.firstWhere(
              (k) => tasks[k] == validate,
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
                  databaseTasksService: databaseTasksService,
                  blueprint: blueprint,
                  validate: validate,
                  keyId: keyId,
                  userUID: userUID,
                ),
              );
            });
        setState(() {});
      }else{
        print("Error u need to log in");
      }
    } catch (e) {
      print("Error showing task: $e");
    }
  }

  Future<bool> testIfFull(Map<String, Blueprint> sortedBlueprints, int listNr, String userUID) async {
    Map<String, TaskChecklist> validatedTask = await databaseTasksService.getAllTasks(userUID);
    TaskChecklist emptyTask = TaskChecklist();
    for (Blueprint blueprint in sortedBlueprints.values) {
      if (blueprint.nrOfList == listNr) {
        int entryPosition = blueprint.nrEntryPosition;
        TaskChecklist? task = validatedTask.values.firstWhere(
              (element) => element.nrOfList == listNr && element.nrEntryPosition == entryPosition,
          orElse: () => emptyTask,
        );
        if (task.nrEntryPosition == null) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> deleteOneTaskListOfUser(int listNr, String userUID) async {
    List<String> validatedTask = await databaseTasksService.getOneListOfTasks(listNr, userUID);
    for (String taskID in validatedTask) {
      await databaseTasksService.deleteTaskFuture(taskID);
    }
    setState(() {});
  }

  AppBar appBar(List<ListOfLists> listOfLists) {
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
      backgroundColor: Colors.blue,
      bottom: TabBar(
        dividerColor: Colors.transparent,
        unselectedLabelColor: Colors.white,
        indicatorPadding: const EdgeInsets.only(left: -10, right: -10),
        indicatorWeight: 5,
        indicatorColor: Colors.red,
        labelColor: Colors.black,
        isScrollable: true,
        tabs: listOfLists.map((blueprint) =>
            Tab(
              text: blueprint.listName,
            )).toList(),
      ),
    );
  }

  Widget body(List<ListOfLists> listOfLists) {
    return StreamBuilder(
      stream: databaseBlueprintsService.getBlueprints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No data found"));
        }

        String? userUID = authController.getCurrentUserUID();
        if (userUID == null) {
          return const Center(child: Text("User not logged in"));
        }
        Future<Map<String, TaskChecklist>> validatedTask = databaseTasksService.getAllTasks(userUID);
        List blueprintsSnapshotList = snapshot.data?.docs ?? [];
        Map<String, Blueprint> blueprints = HashMap();
        Map<String, Blueprint> sortedBlueprints = HashMap();
        for (var blueprintSnapshot in blueprintsSnapshotList) {
          blueprints.addAll({blueprintSnapshot.id: blueprintSnapshot.data()});
        }
        counter = List<int>.filled(listOfLists.length, 0);
        for (var i = 0; i < listOfLists.length; i++) {
          sortedBlueprints = Map.fromEntries(
              blueprints.entries.toList()..sort((e1, e2) => (e1.value.nrEntryPosition).compareTo(e2.value.nrEntryPosition))
          );
          for (Blueprint blueprint in sortedBlueprints.values) {
            if (blueprint.nrOfList == listOfLists[i].listNr) {
              counter[i]++;
            }
          }
        }

        return FutureBuilder<MyUser>(
          future: userService.getCurrentUserData(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (userSnapshot.hasError) {
              return Center(child: Text('Error: ${userSnapshot.error}'));
            }
            if (!userSnapshot.hasData || userSnapshot.data == null) {
              return const Center(child: Text("User data not found"));
            }

            final user = userSnapshot.data!;
            return TabBarView(
              children: <Widget>[
                for (var list in listOfLists)
                  FutureBuilder<bool>(
                    future: testIfFull(sortedBlueprints, list.listNr, userUID),
                    builder: (context, testIfFullSnapshot) {
                      if (testIfFullSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (testIfFullSnapshot.hasError) {
                        return Center(child: Text('Error: ${testIfFullSnapshot.error}'));
                      }
                      bool isFull = testIfFullSnapshot.data ?? false;
                      return ListView(
                        padding: const EdgeInsets.all(16.0),
                        scrollDirection: Axis.vertical,
                        children: [
                          for (Blueprint blueprint in sortedBlueprints.values)
                            if (blueprint.nrOfList == list.listNr)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: FutureBuilder<bool?>(
                                  future: validatedTask.then((v) {
                                    TaskChecklist? task = v.values.cast().firstWhere(
                                            (element) =>
                                        element.nrEntryPosition == blueprint.nrEntryPosition &&
                                            element.nrOfList == blueprint.nrOfList,
                                        orElse: () => null);
                                    if (task != null) {
                                      return task.isDone;
                                    } else {
                                      return null;
                                    }
                                  }),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Container();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      final isDone = snapshot.data;
                                      return BlueprintTemplate(
                                        isDone: isDone,
                                        blueprint: blueprint,
                                        role: user.role,
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
                                                      String key = sortedBlueprints.keys
                                                          .firstWhere((k) => sortedBlueprints[k] == blueprint);
                                                      databaseBlueprintsService.deleteBlueprint(key);
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
                                          String blueprintID = sortedBlueprints.keys
                                              .firstWhere((k) => sortedBlueprints[k] == blueprint);
                                          showBlueprintModal(
                                            nrOfList: blueprint.nrOfList,
                                            nrEntryPosition: blueprint.nrEntryPosition,
                                            blueprint: blueprint,
                                            blueprintID: blueprintID,
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                          const SizedBox(height: 10),
                          if (user.role == 'superadmin')
                            FloatingActionButton(
                              heroTag: "addBlueprintHero",
                              onPressed: () async {
                                showBlueprintModal(
                                  nrOfList: list.listNr,
                                  nrEntryPosition: (counter[list.listNr] + 1),
                                  blueprint: null,
                                  blueprintID: null,
                                );
                              },
                              // backgroundColor: Theme.of(context).colorScheme.primary,
                              child: const Icon(
                                Icons.add,
                                color: Colors.lightGreenAccent,
                              ),
                            ),
                          const SizedBox(height: 20),
                          if (user.role == 'user' && isFull || user.role == 'admin' && isFull)
                            FloatingActionButton(
                              heroTag: "makePDFHero",
                              onPressed: () async {
                                MyUser user = await userService.getCurrentUserData();
                                String companyID = user.company;
                                Map<String, TaskChecklist> tasks = await validatedTask;
                                final data = await pdfService.createInvoice(tasks, sortedBlueprints, list);
                                await pdfService.savePdfFile(companyID, data,
                                        () async => await deleteOneTaskListOfUser(list.listNr, userUID));
                              },
                              backgroundColor: Colors.red,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    AppLocalizations.of(context)!.pdfCreate,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
              ],
            );
          },
        );
      });
  }
}
