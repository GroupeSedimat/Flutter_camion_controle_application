import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/pages/checklist/add_blueprint_form.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/pages/checklist/blueprint_template.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/pages/checklist/validate_task.dart';
import 'package:flutter_application_1/services/database_blueprints_service.dart';
import 'package:flutter_application_1/services/database_image_service.dart';
import 'package:flutter_application_1/services/database_tasks_service.dart';
import 'package:flutter_application_1/services/pdf_service.dart';
import 'package:flutter_application_1/services/user_service.dart';

class CheckList extends StatefulWidget {
  const CheckList({super.key});

  @override
  State<CheckList> createState() => _CheckListState();
}

class _CheckListState extends State<CheckList> {

  final DatabaseBlueprintsService databaseBlueprintsService = DatabaseBlueprintsService();
  final DatabaseTasksService databaseTasksService = DatabaseTasksService();
  final DatabaseImageService databaseImageService = DatabaseImageService();
  final PdfService pdfService = PdfService();
  final UserService userService = UserService();
  AuthController authController = AuthController.instance;

  List<ListOfLists> listOfLists = [
    ListOfLists(listNr: 0, listName: "Before setting off"),
    ListOfLists(listNr: 1, listName: "Avant intervention"),
    ListOfLists(listNr: 2, listName: "Avant intervention vidange"),
    ListOfLists(listNr: 3, listName: "Avant intervention pneus"),
    ListOfLists(listNr: 4, listName: "Avant intervention clim"),
    ListOfLists(listNr: 5, listName: "Apres interventions"),
    ListOfLists(listNr: 6, listName: "Retour pour huile"),
    ListOfLists(listNr: 7, listName: "Retour home"),
    ListOfLists(listNr: 8, listName: "listName")
  ];

  late List<int> counter;

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      initialIndex: 0,
      length: listOfLists.length,
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
          databaseBlueprintsService: databaseBlueprintsService,
          blueprint: blueprint,
          blueprintID: blueprintID,
        ),
      );
    });
  }

    void makePDF(){

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
              break; //
            }
          }

        String keyId = tasks.keys.firstWhere(
              (k) => tasks[k] == validate,
          orElse: () =>
          '', // Zwróć pusty ciąg, jeśli nie znaleziono dopasowania
        );

          await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.white,
                  margin: EdgeInsets.fromLTRB(
                      10, 50, 10, MediaQuery.of(context).viewInsets.bottom),
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
        // Obsłuż błąd, na przykład wyświetlając komunikat użytkownikowi
      }
    }

  void updateCounters(List blueprints) {
    counter = List<int>.filled(listOfLists.length, 0);
    for (var i = 0; i < listOfLists.length; i++) {
      for (var blueprintSnapshot in blueprints) {
        Blueprint blueprint = blueprintSnapshot.data();
        if (blueprint.nrOfList == listOfLists[i].listNr) {
          counter[i]++;
        }
      }
    }
  }

  appBar() {
    return AppBar(
      title: const Text('Check list: the begining',
        style: TextStyle(
          color: Colors.amber,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.blue[900],
      bottom: TabBar(
        dividerColor: Colors.transparent,
        unselectedLabelColor: Colors.lightGreenAccent,
        // indicatorColor: Colors.red,
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

  body() {
    return StreamBuilder(
        stream: databaseBlueprintsService.getBlueprints(),
        builder: (context, snapshot) {
          String? userUID = authController.getCurrentUserUID();
          Future<Map<String, TaskChecklist>> validatedTask = databaseTasksService.getAllTasks(userUID!);
          List blueprintsSnapshotList = snapshot.data?.docs ?? [];
          Map<String, Blueprint> blueprints = HashMap();
          Map<String, Blueprint> sortedBlueprints = HashMap();
          for (var blueprintSnapshot in blueprintsSnapshotList){
            blueprints.addAll({blueprintSnapshot.id: blueprintSnapshot.data()});
          }
          counter = List<int>.filled(listOfLists.length, 0);
          for (var i = 0; i < listOfLists.length; i++) {
            sortedBlueprints = Map.fromEntries(
                blueprints.entries.toList()..sort((e1,e2) => (e1.value.nrEntryPosition).compareTo(e2.value.nrEntryPosition))
            );
            for (Blueprint blueprint in sortedBlueprints.values) {
              if (blueprint.nrOfList == listOfLists[i].listNr) {
                counter[i]++;
              }
            }
          }
          return TabBarView(
            children: <Widget>[
              for (var list in listOfLists)
                ListView(
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
                                    orElse: () => null
                                );
                                if (task != null) {
                                  return task.isDone;
                                } else {
                                  return null;
                                }
                              }),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
                                    // child: CircularProgressIndicator()
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final isDone = snapshot.data;
                                  return BlueprintTemplate(
                                    isDone: isDone,
                                    blueprint: blueprint,
                                    delete: (){
                                      // Find the key corresponding to the blueprint
                                      String key = sortedBlueprints.keys.firstWhere(
                                              (k) => sortedBlueprints[k] == blueprint
                                      );
                                      // If key found, delete blueprint using key
                                      databaseBlueprintsService.deleteBlueprint(key);
                                    },
                                    validate: (){
                                      showTask(blueprint);
                                    },
                                    edit: (){
                                      String blueprintID = sortedBlueprints.keys.firstWhere(
                                              (k) => sortedBlueprints[k] == blueprint
                                      );
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
                            )
                          ),
                      const SizedBox(height: 10,),
                      FloatingActionButton(
                        heroTag: "addBlueprintHero",
                        onPressed: () async {
                          showBlueprintModal( nrOfList: list.listNr,
                            nrEntryPosition: (counter[list.listNr] + 1),
                            blueprint: null,
                            blueprintID: null,
                          );
                        },
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(
                          Icons.add,
                          color: Colors.lightGreenAccent,
                        ),
                      ),
                      const SizedBox(height: 20,),
                      FloatingActionButton(
                        heroTag: "makePDFHero",
                        onPressed: () async {
                          MyUser user = await userService.getCurrentUserData();
                          String company = user.company;
                          // final data = await PdfService.createInvoice(validatedTask);
                          final data = await pdfService.createInvoice();
                          await pdfService.savePdfFile(company, data);
                        },
                        backgroundColor: Colors.red,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10,),
                            Text('Create PDF',
                              style: TextStyle(
                                color: Colors.white,

                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          );
        }
    );
  }
}