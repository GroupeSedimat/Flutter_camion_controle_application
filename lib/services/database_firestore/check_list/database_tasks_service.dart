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
      rethrow;
    }
  }

  Future<Map<String, TaskChecklist>> getAllTasksSinceLastSync(String lastSync) async {
    Query query = _tasksRef;
    query = query.where('updatedAt', isGreaterThan: lastSync);

    try {
      QuerySnapshot querySnapshot = await query.get();
      Map<String, TaskChecklist> tasks = HashMap();
      for (var doc in querySnapshot.docs) {
        tasks[doc.id] = doc.data() as TaskChecklist;
      }
      return tasks;
    } catch (e) {
      print("Error fetching Tasks since last update data: $e");
      rethrow;
    }
  }

  Future<String> addTask(TaskChecklist task) async {
    var returnAdd = await _tasksRef.add(task);
    print("------------- ---------- ---------- database add task${returnAdd.id}");
    return returnAdd.id;
  }

  Future<void> updateTask(String taskID, TaskChecklist task) async {
    _tasksRef.doc(taskID).update(task.toJson());
  }

  void deleteTask(String taskID){
    _tasksRef.doc(taskID).delete();
  }

  Future<void> deleteTaskFuture(String taskID) async {
    print("Delete task with id: $taskID");
    await _tasksRef.doc(taskID).delete();
  }

  Future<void> deleteTaskForUser(String userId) async {
    print("Delete tasks for user: $userId");
    Map<String, TaskChecklist> tasks = await getAllTasks(userId);
    for (var firebaseTask in tasks.entries){
      await _tasksRef.doc(firebaseTask.key).delete();
    }
  }

}