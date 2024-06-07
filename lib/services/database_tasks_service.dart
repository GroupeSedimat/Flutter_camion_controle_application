import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/checklist/task.dart';

const String TASK_COLLECTION_REF = "tasks";

class DatabaseTasksService{
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _tasksRef;

  DatabaseTasksService(){
    _tasksRef = _firestore
      .collection(TASK_COLLECTION_REF)
      .withConverter<TaskChecklist>(
        fromFirestore: (snapshots, _)=> TaskChecklist.fromJson(
            snapshots.data()!,
          ),
        toFirestore: (task, _) => task.toJson()
      );
  }

  Future<Map<String, TaskChecklist>> getAllTasks(String userUID) async {
    try {
      final querySnapshot = await _tasksRef.where("userId", isEqualTo: userUID).get();

      List tasksSnapshotList = querySnapshot.docs;
      Map<String, TaskChecklist> tasks = HashMap();
      for (var taskSnapshot in tasksSnapshotList){
        tasks.addAll({taskSnapshot.id: taskSnapshot.data()});
      }
      return tasks;

    } catch (e) {
      print("Error getting tasks: $e");
      rethrow; // Gérez l’erreur le cas échéant.
    }
  }

  Future<Map<String, TaskChecklist>> getOneListOfTasks(int nrList, String userUID) async {
    Map<String, TaskChecklist> tasks = HashMap();
    try {
      final querySnapshot = await _firestore
          .collection(TASK_COLLECTION_REF)
          .where("nrOfList", isEqualTo: nrList)
          .where("userId", isEqualTo: userUID)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        List tasksSnapshotList = querySnapshot.docs;
        for (var taskSnapshot in tasksSnapshotList){
          tasks.addAll({taskSnapshot.id: taskSnapshot.data()});
        }
      }
      return tasks;

    } catch (error) {
      // Gérez l’erreur
      print("Error retrieving task: $error");
      return tasks;
    }
  }

  Future<TaskChecklist> getOneTaskWithListPos(int nrList, int nrPosition, String userUID) async {
    try {
      final querySnapshot = await _firestore
          .collection(TASK_COLLECTION_REF)
          .where("nrOfList", isEqualTo: nrList)
          .where("nrEntryPosition", isEqualTo: nrPosition)
          .where("userId", isEqualTo: userUID)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return TaskChecklist.fromJson(querySnapshot.docs.first.data());
      } else {
        return TaskChecklist();
      }
    } catch (error) {
      // Gérez l’erreur
      print("Error retrieving task: $error");
      return TaskChecklist();
    }
  }

  void addTask(TaskChecklist task) async {
    _tasksRef.add(task);
  }

  void updateTask(String taskID, TaskChecklist task){
    _tasksRef.doc(taskID).update(task.toJson());
  }

  void deleteTask(String taskID){
    _tasksRef.doc(taskID).delete();
  }

}