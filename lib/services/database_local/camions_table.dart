import 'dart:collection';

import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

String tableName = "camions";

Future<void> createTableCamions(Database db) async {
  await db.execute('''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      name TEXT,
      camionType TEXT,
      responsible TEXT,
      checks TEXT,
      lastIntervention TEXT,
      status TEXT,
      location TEXT,
      company TEXT,
      createdAt TEXT,
      updatedAt TEXT,
      deletedAt TEXT
    )
  ''');
}

Future<void> insertCamion(dynamic dbOrTxn, Camion camion, String firebaseId) async {
  try{
    await dbOrTxn.insert(
        tableName,
        camionToMap(camion, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while inserting data into table Camions: $e");
  }
}

Future<void> updateCamion(dynamic dbOrTxn, Camion camion, String firebaseId) async {
  try{
    await dbOrTxn.update(
        tableName,
        camionToMap(camion, firebaseId: firebaseId),
        where: 'id = ?',
        whereArgs: [firebaseId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for ${camion.name} in table Camions: $e");
  }
}

Future<void> updateCamionFirebaseID(Database db, Camion camion, String firebaseId) async {
  List<String> whereConditions = [];
  List<dynamic> whereArgs = [];

  if (camion.name != "" && camion.name.isNotEmpty) {
    whereConditions.add('name = ?');
    whereArgs.add(camion.name);
  }
  if (camion.company != "" && camion.company.isNotEmpty) {
    whereConditions.add('company = ?');
    whereArgs.add(camion.company);
  }
  if (camion.camionType != "" && camion.camionType.isNotEmpty) {
    whereConditions.add('camionType = ?');
    whereArgs.add(camion.camionType);
  }
  String? whereClause = whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null;

  try {
    await db.update(
        tableName,
        camionToMap(camion, firebaseId: firebaseId),
        where: whereClause,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for ${camion.name} in table Camions: $e");
  }
}

Future<void> softDeleteCamion(Database db, String firebaseId) async {
  Camion? camion = await getOneCamionWithID(db, firebaseId);
  if(camion == null){
    return;
  }
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
    print("Error while deleting data with id $firebaseId in table Camions: $e");
  }
}

Future<void> restoreCamion(Database db, String firebaseId) async {
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
    print("Error while restoring data with id $firebaseId in table Camions: $e");
  }
}

Future<Map<String,Camion>?> getAllCamions(Database db, String role) async {
  Map<String, Camion> camions = {};
  try{
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if(maps.isEmpty){
      return null;
    }

    for (var camionItem in maps) {
      if(camionItem["deletedAt"] == null || role == "superadmin"){
        camions[camionItem["id"] as String] = responseItemToCamion(camionItem);
      }
    }

  } catch (e){
    print("Error while getting all data from table Camions: $e");
  }
  return sortedCamions(camions: camions);
}

Future<Map<String,String>?> getAllCamionsNames(Database db, String role) async {
  Map<String, String> camions = {};
  try{
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if(maps.isEmpty){
      return null;
    }

    for (var camionItem in maps) {
      if(camionItem["deletedAt"] == null || role == "superadmin"){
        camions[camionItem["id"] as String] = camionItem["name"];
      }
    }

  } catch (e){
    print("Error while getting all camion names from table Camions: $e");
  }
  return camions;
}

Future<Map<String,Camion>?> getAllCamionsSinceLastUpdate(dynamic dbOrTxn, String lastUpdated, String timeSync) async {
  Map<String, Camion> camions = {};
  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
        tableName,
        where: 'updatedAt > ? AND updatedAt < ?',
        whereArgs: [lastUpdated, timeSync]);
    if(maps.isEmpty){
      return null;
    }
    print("-------- last updated $lastUpdated");

    for (var camionItem in maps) {
      print("-------- camion ${camionItem["id"]} updatedAt ${camionItem["updatedAt"]}");
      camions[camionItem["id"] as String] = responseItemToCamion(camionItem);
    }

    return sortedCamions(camions: camions);

  } catch (e){
    print("Error while getting all data from table Camions since last actualisation: $e");
  }
  return sortedCamions(camions: camions);
}

Future<void> insertMultipleCamions(dynamic dbOrTxn, Map<String, Camion> camions) async {
  try {
    var batch = dbOrTxn.batch();

    camions.forEach((firebaseId, camion) {
      batch.insert(
        tableName,
        camionToMap(camion, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await batch.commit(noResult: true);
  } catch (e) {
    print("Error while inserting multiple camions into table Camions: $e");
  }
}

Future<Camion?> getOneCamionWithID(dynamic dbOrTxn, String camionID) async {
  try{
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
      tableName,
      where: 'id = ?',
      whereArgs: [camionID],
    );
    if(maps.isEmpty){
      return null;
    }

    return responseItemToCamion(maps.first);

  } catch (e){
    print("Error while getting data of Camion with id $camionID from table Camions: $e");
    return null;
  }
}

Future<Map<String, Camion>?> getCompanyCamions(dynamic dbOrTxn, String companyID, String role) async {
  Map<String, Camion> camions = {};
  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
        tableName,
        where: 'company = ?',
        whereArgs: [companyID]);
    if(maps.isEmpty){
      return null;
    }

    for (var camionItem in maps) {
      if(camionItem["deletedAt"] == null || role == "superadmin"){
        camions[camionItem["id"] as String] = responseItemToCamion(camionItem);
      }
    }

    return sortedCamions(camions: camions);

  } catch (e) {
    print("Error while getting Company Camions: $e");
    rethrow;
  }
}

Future<Map<String, String>?> getCompanyCamionsNames(dynamic dbOrTxn, String companyID, String role) async {
  Map<String, String> camions = {};
  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
        tableName,
        where: 'company = ?',
        whereArgs: [companyID]);
    if(maps.isEmpty){
      return null;
    }

    for (var camionItem in maps) {
      if(camionItem["deletedAt"] == null || role == "superadmin"){
        camions[camionItem["id"] as String] = camionItem["name"];
      }
    }

    return camions;

  } catch (e) {
    print("Error while getting Company Camions: $e");
    rethrow;
  }
}

Future<Map<String, Camion>?> getSortedFilteredCamions({
    required dynamic dbOrTxn,
    String? companyID,
    String? camionTypeId,
    String? searchQuery,
    String sortByField = 'name',
    bool isDescending = false,
  }) async {
  Map<String, Camion> camions = {};
  List<String> whereConditions = [];
  List<dynamic> whereArgs = [];

  if (companyID != null && companyID.isNotEmpty) {
    whereConditions.add('company = ?');
    whereArgs.add(companyID);
  }
  if (camionTypeId != null && camionTypeId.isNotEmpty) {
    whereConditions.add('camionType = ?');
    whereArgs.add(camionTypeId);
  }
  if (searchQuery != null && searchQuery.isNotEmpty) {
    whereConditions.add('name LIKE ?');
    whereArgs.add('%$searchQuery%');
  }

  String? whereClause = whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null;

  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs);
    if(maps.isEmpty){
      return null;
    }

    for (var camionItem in maps) {
      camions[camionItem["id"] as String] = responseItemToCamion(camionItem);
    }

    return sortedCamions(camions: camions, sortByField: sortByField, isSortDescending: isDescending);

  } catch (e) {
    print("Error while getting Company Camions: $e");
    rethrow;
  }
}

Map<String, dynamic> camionToMap(Camion camion, {String? firebaseId}) {
  return {
    'id': firebaseId,
    'name': camion.name,
    'checks': camion.checks != null
        ? jsonEncode(camion.checks!.map((e) => e.toIso8601String()).toList())
        : null,
    'camionType': camion.camionType,
    'responsible': camion.responsible,
    'lastIntervention': camion.lastIntervention,
    'status': camion.status,
    'location': camion.location,
    'company': camion.company,
    'createdAt': camion.createdAt.toIso8601String(),
    'updatedAt': camion.updatedAt.toIso8601String(),
    'deletedAt': camion.deletedAt?.toIso8601String(),
  };
}

Camion responseItemToCamion(var camionItem){
  return Camion(
    name: camionItem["name"] as String,
    checks: camionItem["checks"] != null
        ? timeInJsonToListDateTime(camionItem["checks"] as String)
        : null,
    camionType: camionItem["camionType"] as String,
    responsible: camionItem["responsible"] as String?,
    lastIntervention: camionItem["lastIntervention"] as String?,
    status: camionItem["status"] as String?,
    location: camionItem["location"] as String?,
    company: camionItem["company"] as String,
    createdAt: DateTime.parse(camionItem["createdAt"] as String),
    updatedAt: DateTime.parse(camionItem["updatedAt"] as String),
    deletedAt: camionItem["deletedAt"] != null
        ? DateTime.parse(camionItem["deletedAt"] as String)
        : null,
  );
}

List<DateTime> timeInJsonToListDateTime(String checks){
  final List<dynamic> decodedChecks = jsonDecode(checks as String);
  return decodedChecks.map((item) => DateTime.parse(item)).toList();
}

LinkedHashMap<String, Camion> sortedCamions({
  required Map<String, Camion> camions,
  String sortByField = 'name',
  bool isSortDescending = false,
}) {
  // Tworzymy listę kluczy
  List<String> sortedKeys = camions.keys.toList();

  // Funkcja porównawcza dla pól
  int compareFields(String field, Camion a, Camion b) {
    String? valueA, valueB;

    switch (field) {
      case 'name':
        valueA = a.name;
        valueB = b.name;
        break;
      case 'camionType':
        valueA = a.camionType;
        valueB = b.camionType;
        break;
      case 'company':
        valueA = a.company;
        valueB = b.company;
        break;
      default:
        valueA = a.name;
        valueB = b.name;
    }

    // Porównanie rosnąco lub malejąco
    int comparison = valueA.compareTo(valueB);
    return isSortDescending ? -comparison : comparison;
  }

  // Sortowanie
  sortedKeys.sort((a, b) {
    Camion camionA = camions[a]!;
    Camion camionB = camions[b]!;

    // Sortuj po głównym polu
    int primaryComparison = compareFields(sortByField, camionA, camionB);

    if (primaryComparison != 0) {
      return primaryComparison;
    }

    // W przypadku remisu sortuj po nazwie
    return compareFields('name', camionA, camionB);
  });

  // Tworzenie LinkedHashMap z posortowanymi kluczami
  return LinkedHashMap.fromIterable(
    sortedKeys,
    key: (k) => k,
    value: (k) => camions[k]!,
  );
}