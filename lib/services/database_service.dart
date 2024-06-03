// ignore_for_file: constant_identifier_names, avoid_print, use_rethrow_when_possible

import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/task.dart';

const String BLUEPRINT_COLLECTION_REF = "blueprint";
const String TASK_COLLECTION_REF = "tasks";

class DatabaseService{
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _tasksRef;
  late final CollectionReference _blueprintRef;
  late final Reference _referenceImages;
  final Reference _fireReference = FirebaseStorage.instance.ref();

  DatabaseService(){
    _tasksRef = _firestore
        .collection(TASK_COLLECTION_REF)
        .withConverter<TaskChecklist>(
          fromFirestore: (snapshots, _)=> TaskChecklist.fromJson(
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

    _referenceImages = _fireReference.child('images');
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
      throw e; // Gérez l’erreur le cas échéant.
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
    _blueprintRef.doc(blueprintID).update(blueprint.toJson());
  }

  void deleteBlueprint(String blueprintID){
    _blueprintRef.doc(blueprintID).delete();
  }

  Future<String> addImageToFirebase(String path) async {
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImageToUpload = _referenceImages.child(imageName);
    try{
      await referenceImageToUpload.putFile(File(path));
      return await referenceImageToUpload.getDownloadURL();
    }catch(e){
      print(e);
      return '';
    }
  }
}