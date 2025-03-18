import 'dart:collection';

import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

String tableName = "blueprints";

/// une classe fonctionnant sur la table "blueprints" dans database local
Future<void> createTableBlueprints(Database db) async {
  await db.execute('''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      title TEXT,
      description TEXT,
      photoFilePath TEXT,
      nrOfList INTEGER,
      nrEntryPosition INTEGER,
      createdAt TEXT,
      updatedAt TEXT,
      deletedAt TEXT
    )
  ''');
}

Future<void> insertBlueprint(dynamic dbOrTxn, Blueprint blueprint, String firebaseId) async {
  print("insert blueprint");
  try{
    await dbOrTxn.insert(
        tableName,
        blueprintToMap(blueprint, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while inserting data into table Blueprints: $e");
  }
}

Future<void> updateBlueprint(dynamic dbOrTxn, Blueprint blueprint, String firebaseId) async {
  print("update blueprint");
  try{
    await dbOrTxn.update(
        tableName,
        blueprintToMap(blueprint, firebaseId: firebaseId),
        where: 'id = ?',
        whereArgs: [firebaseId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for ${blueprint.title} in table Blueprints: $e");
  }
}

Future<void> updateBlueprintFirebaseID(Database db, Blueprint blueprint, String firebaseId) async {
  List<String> whereConditions = [];
  List<dynamic> whereArgs = [];

  whereConditions.add('nrOfList = ?');
  whereArgs.add(blueprint.nrOfList);

  whereConditions.add('nrEntryPosition = ?');
  whereArgs.add(blueprint.nrEntryPosition);

  String? whereClause = whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null;

  try {
    await db.update(
        tableName,
        blueprintToMap(blueprint, firebaseId: firebaseId),
        where: whereClause,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for ${blueprint.title} in table Blueprints: $e");
  }
}

Future<void> softDeleteBlueprints(Database db, String firebaseId) async {
  try{
    await db.update(
        tableName,
        {
          'updatedAt': DateTime.now().toIso8601String(),
          'deletedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [firebaseId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while deleting data with id $firebaseId in table Blueprints: $e");
  }
}

Future<void> restoreBlueprints(Database db, String firebaseId) async {
  try{
    await db.update(
        tableName,
        {
          'updatedAt': DateTime.now().toIso8601String(),
          'deletedAt': null
        },
        where: 'id = ?',
        whereArgs: [firebaseId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while restoring data with id $firebaseId in table Blueprints: $e");
  }
}

Future<Map<String,Blueprint>?> getAllBlueprints(Database db, String role) async {
  print("getAllBlueprints");
  Map<String, Blueprint> blueprints = {};
  try{
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if(maps.isEmpty){
      return null;
    }

    for (var blueprintItem in maps) {
      if(blueprintItem["deletedAt"] == null || role == "superadmin"){
        blueprints[blueprintItem["id"] as String] = responseItemToBlueprint(blueprintItem);
      }
    }

  } catch (e){
    print("Error while getting all data from table Blueprints: $e");
  }
  return sortedBlueprints(blueprints: blueprints);
}

Future<Map<String,Blueprint>?> getAllBlueprintsSinceLastUpdate(dynamic dbOrTxn, String lastUpdated, String timeSync) async {
  print("getAllBlueprintsSinceLastUpdate");
  Map<String, Blueprint> blueprints = {};
  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
        tableName,
        where: 'updatedAt > ? AND updatedAt < ?',
        whereArgs: [lastUpdated, timeSync]);
    if(maps.isEmpty){
      return null;
    }

    for (var blueprintItem in maps) {
      blueprints[blueprintItem["id"] as String] = responseItemToBlueprint(blueprintItem);
    }

    return sortedBlueprints(blueprints: blueprints);

  } catch (e){
    print("Error while getting all data from table Blueprints since last actualisation: $e");
  }
  return sortedBlueprints(blueprints: blueprints);
}

Future<void> insertMultipleBlueprints(dynamic dbOrTxn, Map<String, Blueprint> blueprint) async {
  try {
    var batch = dbOrTxn.batch();

    blueprint.forEach((firebaseId, blueprint) {
      batch.insert(
        tableName,
        blueprintToMap(blueprint, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await batch.commit(noResult: true);
  } catch (e) {
    print("Error while inserting multiple types into table Blueprints: $e");
  }
}

Future<Blueprint?> getOneBlueprintWithID(dynamic dbOrTxn, String blueprintID) async {
  try{
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
      tableName,
      where: 'id = ?',
      whereArgs: [blueprintID],
    );
    if(maps.isEmpty){
      return null;
    }

    return responseItemToBlueprint(maps.first);

  } catch (e){
    print("Error while getting data of Blueprint with id $blueprintID from table Blueprints: $e");
    return null;
  }
}

Map<String, dynamic> blueprintToMap(Blueprint blueprint, {String? firebaseId}) {
  print("blueprintToMap");
  return {
    'id': firebaseId,
    'title': blueprint.title,
    'description': blueprint.description,
    'photoFilePath': (blueprint.photoFilePath != null && blueprint.photoFilePath != [] )
        ? jsonEncode(blueprint.photoFilePath!.map((e) => e).toList())
        : null,
    'nrOfList': blueprint.nrOfList,
    'nrEntryPosition': blueprint.nrEntryPosition,
    'createdAt': blueprint.createdAt.toIso8601String(),
    'updatedAt': blueprint.updatedAt.toIso8601String(),
    'deletedAt': blueprint.deletedAt?.toIso8601String(),
  };
}

Blueprint responseItemToBlueprint(var blueprintItem){
  print("responseItemToBlueprint");
  return Blueprint(
    title: blueprintItem["title"] as String,
    description: blueprintItem["description"] as String,
    photoFilePath: blueprintItem["photoFilePath"] != null
        ? dataInJsonToList(blueprintItem["photoFilePath"] as String)
        : null,
    nrOfList: blueprintItem["nrOfList"] as int,
    nrEntryPosition: blueprintItem["nrEntryPosition"] as int,
    createdAt: DateTime.parse(blueprintItem["createdAt"] as String),
    updatedAt: DateTime.parse(blueprintItem["updatedAt"] as String),
    deletedAt: blueprintItem["deletedAt"] != null ? DateTime.parse(blueprintItem["deletedAt"] as String) : null,
  );
}

List<String> dataInJsonToList(String data){
  final List<dynamic> decodedData = jsonDecode(data);
  return decodedData.map((item) => item as String).toList();
}

LinkedHashMap<String, Blueprint> sortedBlueprints({
  required Map<String, Blueprint> blueprints,
  String sortByField = 'nrEntryPosition',
  bool isSortDescending = false,
}) {
  List<String> sortedKeys = blueprints.keys.toList();

  int compareFields(String field, Blueprint a, Blueprint b) {
    var valueA, valueB;

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
        valueA = a.createdAt;
        valueB = b.createdAt;
    }

    int comparison = valueA!.compareTo(valueB!);
    return isSortDescending ? -comparison : comparison;
  }

  sortedKeys.sort((a, b) {
    Blueprint blueprintA = blueprints[a]!;
    Blueprint blueprintB = blueprints[b]!;

    int primaryComparison = compareFields(sortByField, blueprintA, blueprintB);

    if (primaryComparison != 0) {
      return primaryComparison;
    }
    return compareFields('nrEntryPosition', blueprintA, blueprintB);
  });

  return LinkedHashMap.fromIterable(
    sortedKeys,
    key: (k) => k,
    value: (k) => blueprints[k]!,
  );
}