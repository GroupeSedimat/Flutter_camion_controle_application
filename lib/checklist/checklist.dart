import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/add_blueprint_form.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/models/checklist/blueprint_template.dart';
import 'package:flutter_application_1/models/checklist/validate_task.dart';
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

  // List<Blueprint> toDoList = [
  //   Blueprint(blueprintInfo: "Pris charge électrique secteur	a. Débrancher la prise électrique située sur le côté conducteur du camion. b. Débrancher le sectionneur d’alimentation de la prise de recharge du camion.", listNr: 0),
  //   Blueprint(blueprintInfo: "Serrure portes arrière	Verrouiller non", listNr: 0),
  //   Blueprint(blueprintInfo: "Serrures prises recharge VE	Verrouiller oui/non", listNr: 0),
  //   Blueprint(blueprintInfo: "Serrure porte latérale	Verrouiller oui/non", listNr: 0),
  //   Blueprint(blueprintInfo: "Lumières	Allumer oui/non", listNr: 0),
  //   Blueprint(blueprintInfo: "Convertisseur	Off oui/non", listNr: 1),
  //   Blueprint(blueprintInfo: "Présence et arrimage outillage	Vérifier oui/non", listNr: 2),
  //   Blueprint(blueprintInfo: "Etagère 1: picking selon photo	Vérifier oui/non", listNr: 2),
  //   Blueprint(blueprintInfo: "Etagère 2: picking huile	Vérifier oui/non", listNr: 2)
  // ];

  late List<int> counter;

  @override
  Widget build(BuildContext context) {

    void showAddBlueprint(int listNbr, int position){
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
          child: AddBlueprintForm(
              nrOfList: listNbr,
              nrEntryPosition: position,
              databaseService: databaseService),
        );
      });
    }


    void showTask(int listNbr, int position, Blueprint blueprint){
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
          child: ValidateTask(
            nrOfList: listNbr,
            nrEntryPosition: position,
            databaseService: databaseService,
            blueprint: blueprint),
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
            tabs: listOfLists.map((blueprint) =>
                Tab(
                  text: blueprint.listName,
                )).toList(),
          ),
        ),
        body:
        StreamBuilder(
          stream: databaseService.getBlueprints(),
          builder: (context, snapshot) {
            List blueprintsSnapshotList = snapshot.data?.docs ?? [];
            Map<String, Blueprint> blueprints = HashMap();
            for (var blueprintSnapshot in blueprintsSnapshotList){
              blueprints.addAll({blueprintSnapshot.id: blueprintSnapshot.data()});
            }
            counter = List<int>.filled(listOfLists.length, 0);
            for (var i = 0; i < listOfLists.length; i++) {
              for (Blueprint blueprint in blueprints.values) {
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
                      for (Blueprint blueprint in blueprints.values)
                        if (blueprint.nrOfList == list.listNr)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: BlueprintTemplate(
                                blueprint: blueprint,
                                delete: (){
                                  // Find the key corresponding to the blueprint
                                  String key = blueprints.keys.firstWhere(
                                        (k) => blueprints[k] == blueprint
                                  );
                                  // If key found, delete blueprint using key
                                    databaseService.deleteBlueprint(key);
                                },
                              edit: (){
                                showTask(list.listNr, counter[list.listNr], blueprint);
                              }
                            ),
                          ),
                      FloatingActionButton(
                        onPressed: () async {
                          showAddBlueprint(list.listNr, counter[list.listNr] +1);
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
}