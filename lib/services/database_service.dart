import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/checklist/task.dart';

const String TASK_COLLECTION_REF = "tasks";

class DatabaseService{
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _tasksRef;

  DatabaseService(){
    _tasksRef = _firestore
        .collection(TASK_COLLECTION_REF)
        .withConverter<Task>(
          fromFirestore: (snapshots, _)=> Task.fromJson(
              snapshots.data()!,
            ),
          toFirestore: (task, _) => task.toJson()
    );
  }

  Stream<QuerySnapshot> getTasks(){
    return _tasksRef.snapshots();
  }

  void addTask(Task task) async {
    _tasksRef.add(task);
  }

  void updateTask(String taskID, Task task){
    task.lastUpdate = Timestamp.now();
    _tasksRef.doc(taskID).update(task.toJson());
  }

  void deleteTask(String taskID){
    _tasksRef.doc(taskID).delete();
  }

}