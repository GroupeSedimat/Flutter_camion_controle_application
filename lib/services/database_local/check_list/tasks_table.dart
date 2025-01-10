import 'dart:collection';

import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:sqflite/sqflite.dart';

String tableName = "tasks";

Future<void> createTableTasks(Database db) async {
  await db.execute('''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      descriptionOfProblem TEXT,
      photoFilePath TEXT,
      isDone TEXT,
      nrOfList INTEGER,
      nrEntryPosition INTEGER,
      userId TEXT,
      createdAt TEXT,
      updatedAt TEXT
    )
  ''');
}

Future<void> insertTask(dynamic dbOrTxn, TaskChecklist task, String firebaseId) async {
  try{
    await dbOrTxn.insert(
        tableName,
        taskToMap(task, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while inserting data into table Tasks: $e");
  }
}

Future<void> updateTask(dynamic dbOrTxn, TaskChecklist task, String firebaseId) async {
  try{
    await dbOrTxn.update(
        tableName,
        taskToMap(task, firebaseId: firebaseId),
        where: 'id = ?',
        whereArgs: [firebaseId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for pos ${task.nrEntryPosition} in table Equipments: $e");
  }
}

Future<void> updateTaskFirebaseID(Database db, TaskChecklist task, String firebaseId) async {
  List<String> whereConditions = [];
  List<dynamic> whereArgs = [];

    whereConditions.add('nrOfList = ?');
    whereArgs.add(task.nrOfList);
    whereConditions.add('nrEntryPosition = ?');
    whereArgs.add(task.nrEntryPosition);

  String? whereClause = whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null;

  try {
    await db.update(
        tableName,
        taskToMap(task, firebaseId: firebaseId),
        where: whereClause,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for ${task.nrEntryPosition} in table Tasks: $e");
  }
}

Future<void> deleteTask(dynamic dbOrTxn, String firebaseId) async {
  try{
    await dbOrTxn.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [firebaseId]
    );
  } catch (e){
    print("Error while deleting data with id $firebaseId in table Tasks: $e");
  }
}
Future<void> clearTaskTable(dynamic dbOrTxn) async {
  try{
    await dbOrTxn.delete(
        tableName
    );
  } catch (e){
    print("Error while deleting data in table Tasks: $e");
  }
}

Future<Map<String,TaskChecklist>?> getAllTasks(Database db) async {
  Map<String, TaskChecklist> tasks = {};
  try{
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if(maps.isEmpty){
      return null;
    }

    for (var task in maps) {
      tasks[task["id"] as String] = responseItemToTask(task);
    }

  } catch (e){
    print("Error while getting all data from table Tasks: $e");
  }
  return sortedTasks(tasks: tasks);
}

Future<Map<String,TaskChecklist>?> getAllTasksOfUser(dynamic dbOrTxn, String userId) async {
  Map<String, TaskChecklist> tasks = {};
  try{
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId]
    );
    if(maps.isEmpty){
      return null;
    }
    for (var task in maps) {
      tasks[task["id"] as String] = responseItemToTask(task);
    }
  } catch (e){
    print("Error while getting all User tasks from table Tasks: $e");
  }
  return tasks;
}


Future<List<String>> getUserOneListOfTasks(Database db, String userId, int listNr) async {
  List<String> tasks = [];
  try{
    final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'userId = ? AND nrOfList = ?',
        whereArgs: [userId, listNr.toString()]
    );
    if(maps.isEmpty){
      return tasks;
    }
    for (var task in maps) {
      tasks.add(task["id"] as String);
    }
  } catch (e){
    print("Error while getting all tasksId from one list from table Tasks: $e");
  }
  return tasks;
}

Future<Map<String,TaskChecklist>?> getAllTasksSinceLastUpdate(dynamic dbOrTxn, String lastUpdated, String timeSync, String userId) async {
  Map<String, TaskChecklist> tasks = {};
  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
        tableName,
        where: 'updatedAt > ? AND updatedAt < ? AND userId = ?',
        whereArgs: [lastUpdated, timeSync, userId]);
    if(maps.isEmpty){
      return null;
    }
    print("-------- last updated Tasks $lastUpdated");

    for (var task in maps) {
      print("-------- task ${task["id"]} updatedAt ${task["updatedAt"]}");
      tasks[task["id"] as String] = responseItemToTask(task);
    }

    return sortedTasks(tasks: tasks);

  } catch (e){
    print("Error while getting all data from table Tasks since last actualisation: $e");
  }
  return sortedTasks(tasks: tasks);
}

Future<void> insertMultipleTasks(dynamic dbOrTxn, Map<String, TaskChecklist> tasks) async {
  try {
    var batch = dbOrTxn.batch();

    tasks.forEach((firebaseId, task) {
      batch.insert(
        tableName,
        taskToMap(task, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await batch.commit(noResult: true);
  } catch (e) {
    print("Error while inserting multiple types into table Tasks: $e");
  }
}

Future<TaskChecklist?> getOneTaskWithID(dynamic dbOrTxn, String taskID) async {
  try{
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
      tableName,
      where: 'id = ?',
      whereArgs: [taskID],
    );
    if(maps.isEmpty){
      return null;
    }

    return responseItemToTask(maps.first);

  } catch (e){
    print("Error while getting data of Task with id $taskID from table Tasks: $e");
    return null;
  }
}

Map<String, dynamic> taskToMap(TaskChecklist task, {String? firebaseId}) {
  String? isDone;
  if(task.isDone == true){
    isDone = "true";
  }else if(task.isDone == false) {
    isDone = "false";
  }else{
    isDone = null;
  }
  return {
    'id': firebaseId,
    'descriptionOfProblem': task.descriptionOfProblem,
    'photoFilePath': task.photoFilePath,
    'isDone': isDone,
    'nrOfList': task.nrOfList,
    'nrEntryPosition': task.nrEntryPosition,
    'userId': task.userId,
    'createdAt': task.createdAt.toIso8601String(),
    'updatedAt': task.updatedAt.toIso8601String(),
  };
}

TaskChecklist responseItemToTask(var task){
  bool isDone = false;
  if(task["isDone"] == "true"){
    isDone = true;
  }
  return TaskChecklist(
    descriptionOfProblem: task["descriptionOfProblem"] != null
        ?  task['descriptionOfProblem'] as String
        : null,
    photoFilePath: task["photoFilePath"] != null
        ?  task['photoFilePath'] as String
        : null,
    isDone: isDone,
    nrOfList: task["nrOfList"] as int,
    nrEntryPosition: task["nrEntryPosition"] as int,
    userId: task["userId"] != null
        ?  task['userId'] as String
        : null,
    createdAt: DateTime.parse(task["createdAt"] as String),
    updatedAt: DateTime.parse(task["updatedAt"] as String),
  );
}

LinkedHashMap<String, TaskChecklist> sortedTasks({
  required Map<String, TaskChecklist> tasks,
  String sortByField = 'nrEntryPosition',
  bool isSortDescending = false,
}) {
  List<String> sortedKeys = tasks.keys.toList();

  int compareFields(String field, TaskChecklist a, TaskChecklist b) {
    int? valueA, valueB;

    switch (field) {
      case 'nrEntryPosition':
        valueA = a.nrEntryPosition;
        valueB = b.nrEntryPosition;
        break;
      case 'nrOfList':
        valueA = a.nrOfList;
        valueB = b.nrOfList;
        break;
      default:
        valueA = a.nrEntryPosition;
        valueB = b.nrEntryPosition;
    }

    int comparison = valueA.compareTo(valueB);
    return isSortDescending ? -comparison : comparison;
  }

  sortedKeys.sort((a, b) {
    TaskChecklist taskA = tasks[a]!;
    TaskChecklist taskB = tasks[b]!;

    int primaryComparison = compareFields(sortByField, taskA, taskB);

    if (primaryComparison != 0) {
      return primaryComparison;
    }

    return compareFields('nrEntryPosition', taskA, taskB);
  });

  return LinkedHashMap.fromIterable(
    sortedKeys,
    key: (k) => k,
    value: (k) => tasks[k]!,
  );
}