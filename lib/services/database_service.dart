import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/task.dart';

const String BLUEPRINT_COLLECTION_REF = "blueprint";
const String TASK_COLLECTION_REF = "tasks";

class DatabaseService{
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _tasksRef;
  late final CollectionReference _blueprintRef;

  DatabaseService(){
    _tasksRef = _firestore
        .collection(TASK_COLLECTION_REF)
        .withConverter<Task>(
          fromFirestore: (snapshots, _)=> Task.fromJson(
              snapshots.data()!,
            ),
          toFirestore: (task, _) => task.toJson()
    );
    _blueprintRef = _firestore
        .collection(BLUEPRINT_COLLECTION_REF)
        .withConverter<Blueprint>(
          fromFirestore: (snapshots, _)=> Blueprint.fromJson(
              snapshots.data()!,
            ),
          toFirestore: (blueprint, _) => blueprint.toJson()
    );
  }

  Stream<QuerySnapshot> getTasks(){
    return _tasksRef.snapshots();
  }

  Stream<DocumentSnapshot> getOneTaskWithID(String taskID){
    return _tasksRef.doc(taskID).snapshots();
  }

  Future<Task> getOneTaskWithListPos(int nrList, int nrPosition) async {
    // return _firestore
    //     .collection(TASK_COLLECTION_REF)
    //     .where("nrOfList", isEqualTo: nrList)
    //     .where("nrEntryPosition", isEqualTo: nrPosition)
    //     .snapshots()
    //     .map((querySnapshot) {
    //       if (querySnapshot.docs.isNotEmpty) {
    //         return Task.fromJson(querySnapshot.docs.first.data());
    //       } else {
    //         return Task();
    //       }
    //     });
    try {
        final querySnapshot = await _firestore
        .collection(TASK_COLLECTION_REF)
        .where("nrOfList", isEqualTo: nrList)
        .where("nrEntryPosition", isEqualTo: nrPosition)
        .get();
        if (querySnapshot.docs.isNotEmpty) {
          return Task.fromJson(querySnapshot.docs.first.data());
        } else {
          return Task();
        }
    } catch (error) {
      // Obsłuż błąd, jeśli wystąpił.
      print("Error retrieving task: $error");
      return Task();
    }
  }

  void addTask(Task task) async {
    _tasksRef.add(task);
  }

  void updateTask(String taskID, Task task){
    _tasksRef.doc(taskID).update(task.toJson());
  }

  void deleteTask(String taskID){
    _tasksRef.doc(taskID).delete();
  }

  Stream<QuerySnapshot> getBlueprints(){
    return _blueprintRef.snapshots();
  }

  Stream<DocumentSnapshot> getOneBlueprintWithID(String blueprintID){
    return _blueprintRef.doc(blueprintID).snapshots();
  }

  void addBlueprint(Blueprint blueprint) async {
    _blueprintRef.add(blueprint);
  }

  void updateBlueprint(String blueprintID, Blueprint blueprint){
    blueprint.lastUpdate = Timestamp.now();
    _blueprintRef.doc(blueprintID).update(blueprint.toJson());
  }

  void deleteBlueprint(String blueprintID){
    _blueprintRef.doc(blueprintID).delete();
  }

}