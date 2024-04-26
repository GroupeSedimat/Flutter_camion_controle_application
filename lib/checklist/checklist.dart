import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/checklist/addTaskForm.dart';
import 'package:flutter_application_1/models/checklist/pop_up_infos.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/models/checklist/task_template.dart';
import 'package:flutter_application_1/services/database_service.dart';

class CheckList extends StatefulWidget {
  const CheckList({super.key});

  @override
  State<CheckList> createState() => _CheckListState();
}

class _CheckListState extends State<CheckList> {

  final DatabaseService databaseService = DatabaseService();

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

  // List<Task> toDoList = [
  //   Task(taskInfo: "Pris charge électrique secteur	a. Débrancher la prise électrique située sur le côté conducteur du camion. b. Débrancher le sectionneur d’alimentation de la prise de recharge du camion.", listNr: 0),
  //   Task(taskInfo: "Serrure portes arrière	Verrouiller non", listNr: 0),
  //   Task(taskInfo: "Serrures prises recharge VE	Verrouiller oui/non", listNr: 0),
  //   Task(taskInfo: "Serrure porte latérale	Verrouiller oui/non", listNr: 0),
  //   Task(taskInfo: "Lumières	Allumer oui/non", listNr: 0),
  //   Task(taskInfo: "Convertisseur	Off oui/non", listNr: 1),
  //   Task(taskInfo: "Présence et arrimage outillage	Vérifier oui/non", listNr: 2),
  //   Task(taskInfo: "Etagère 1: picking selon photo	Vérifier oui/non", listNr: 2),
  //   Task(taskInfo: "Etagère 2: picking huile	Vérifier oui/non", listNr: 2)
  // ];

  late List<int> counter;

  @override
  Widget build(BuildContext context) {

    void showSomething(int listNbr, int position){
      showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          // padding: EdgeInsets.fromLTRB(
          //   20, 60, 20, MediaQuery.of(context).viewInsets.bottom
          // ),
          color: Colors.white,
          margin: EdgeInsets.fromLTRB(
              10, 50, 10, MediaQuery.of(context).viewInsets.bottom
          ),
          child: AddTaskForm(nrOfList: listNbr , nrEntryPosition: position , databaseService: databaseService),
        );
      });
    }
    return DefaultTabController(
      initialIndex: 0,
      length: listOfLists.length,
      child: Scaffold(
        backgroundColor: Colors.lightBlue,
        appBar: AppBar(
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
            tabs: listOfLists.map((task) =>
                Tab(
                  text: task.listName,
                )).toList(),
          ),
        ),
        body:
        StreamBuilder(
          stream: databaseService.getTasks(),
          builder: (context, snapshot) {
            List tasksSnapshotList = snapshot.data?.docs ?? [];
            Map<String, Task> tasks = HashMap();
            for (var taskSnapshot in tasksSnapshotList){
              tasks.addAll({taskSnapshot.id: taskSnapshot.data()});
            }
            counter = List<int>.filled(listOfLists.length, 0);
            for (var i = 0; i < listOfLists.length; i++) {
              for (Task task in tasks.values) {
                if (task.nrOfList == listOfLists[i].listNr) {
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
                      for (Task task in tasks.values)
                        if (task.nrOfList == list.listNr)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: TaskTemplate(
                                task: task,
                                delete: (){
                                  // Find the key corresponding to the task
                                  String key = tasks.keys.firstWhere(
                                        (k) => tasks[k] == task
                                  );
                                  // If key found, delete task using key
                                    databaseService.deleteTask(key);
                                }
                            ),
                          ),
                      FloatingActionButton(
                        onPressed: () async {
                          showSomething(list.listNr, counter[list.listNr] +1);
                          // showDialog(
                          //   context: context,
                          //   builder: (context){
                          //     return PopUpInfo(
                          //         listNr: list.listNr,
                          //         counter: counter[list.listNr],
                          //         databaseService: databaseService
                          //     );
                          //   }
                          // );
                        },
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(
                          Icons.add,
                          color: Colors.lightGreenAccent,
                        ),
                      ),
                    ],
                  ),
              ],
            );
          }
        ),
      ),
    );
  }

  void updateCounters(List tasks) {
    counter = List<int>.filled(listOfLists.length, 0);
    for (var i = 0; i < listOfLists.length; i++) {
      for (var taskSnapshot in tasks) {
        Task task = taskSnapshot.data();
        if (task.nrOfList == listOfLists[i].listNr) {
          counter[i]++;
        }
      }
    }
  }
}