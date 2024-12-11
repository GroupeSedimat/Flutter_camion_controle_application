import 'dart:collection';

import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

String tableName = "camionTypes";

Future<void> createTableCamionTypes(Database db) async {
  await db.execute('''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      name TEXT,
      lol TEXT,
      equipment TEXT,
      routerData TEXT,
      createdAt TEXT,
      updatedAt TEXT,
      deletedAt TEXT
    )
  ''');
}

Future<void> insertCamionType(dynamic dbOrTxn, CamionType camionType, String firebaseId) async {
  try{
    await dbOrTxn.insert(
        tableName,
        camionTypeToMap(camionType, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while inserting data into table Camion Types: $e");
  }
}

Future<void> updateCamionType(dynamic dbOrTxn, CamionType camionType, String firebaseId) async {
  try{
    await dbOrTxn.update(
        tableName,
        camionTypeToMap(camionType, firebaseId: firebaseId),
        where: 'id = ?',
        whereArgs: [firebaseId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for ${camionType.name} in table Camion Types: $e");
  }
}

Future<void> updateCamionTypesFirebaseID(Database db, CamionType camionType, String firebaseId) async {
  List<String> whereConditions = [];
  List<dynamic> whereArgs = [];

  if (camionType.name != "" && camionType.name.isNotEmpty) {
    whereConditions.add('name = ?');
    whereArgs.add(camionType.name);
  }

  String? whereClause = whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null;

  try {
    await db.update(
        tableName,
        camionTypeToMap(camionType, firebaseId: firebaseId),
        where: whereClause,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for ${camionType.name} in table Camion Types: $e");
  }
}

Future<void> softDeleteCamionType(Database db, String firebaseId) async {
  CamionType? camionType = await getOneCamionTypeWithID(db, firebaseId);
  if(camionType == null){
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
    print("Error while deleting data with id $firebaseId in table Camion Types: $e");
  }
}

Future<Map<String,CamionType>?> getAllCamionTypes(Database db) async {
  Map<String, CamionType> camionTypes = {};
  try{
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if(maps.isEmpty){
      return null;
    }

    for (var camionTypeItem in maps) {
      camionTypes[camionTypeItem["id"] as String] = responseItemToCamionType(camionTypeItem);
    }

  } catch (e){
    print("Error while getting all data from table Camion Types: $e");
  }
  return sortedCamionTypes(camionTypes: camionTypes);
}

Future<Map<String,String>?> getAllCamionTypeNames(Database db) async {
  Map<String, String> camionTypesNames = {};
  try{
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if(maps.isEmpty){
      return null;
    }

    for (var camionTypeItem in maps) {
      camionTypesNames[camionTypeItem["id"] as String] = responseItemToCamionType(camionTypeItem).name;
    }

  } catch (e){
    print("Error while getting all data from table Camion Types Names: $e");
  }
  return camionTypesNames;
}

Future<Map<String,CamionType>?> getAllCamionTypesSinceLastUpdate(dynamic dbOrTxn, String lastUpdated, String timeSync) async {
  Map<String, CamionType> camionTypes = {};
  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
        tableName,
        where: 'updatedAt > ? AND updatedAt < ?',
        whereArgs: [lastUpdated, timeSync]);
    if(maps.isEmpty){
      return null;
    }
    print("-------- last updated CamionTypes $lastUpdated");

    for (var camionTypeItem in maps) {
      print("-------- camion type ${camionTypeItem["id"]} updatedAt ${camionTypeItem["updatedAt"]}");
      camionTypes[camionTypeItem["id"] as String] = responseItemToCamionType(camionTypeItem);
    }

    return sortedCamionTypes(camionTypes: camionTypes);

  } catch (e){
    print("Error while getting all data from table Camion Types since last actualisation: $e");
  }
  return sortedCamionTypes(camionTypes: camionTypes);
}

Future<void> insertMultipleCamionTypes(dynamic dbOrTxn, Map<String, CamionType> camionTypes) async {
  try {
    var batch = dbOrTxn.batch();

    camionTypes.forEach((firebaseId, camionType) {
      batch.insert(
        tableName,
        camionTypeToMap(camionType, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await batch.commit(noResult: true);
  } catch (e) {
    print("Error while inserting multiple types into table Camion Types: $e");
  }
}

Future<CamionType?> getOneCamionTypeWithID(dynamic dbOrTxn, String camionTypeID) async {
  try{
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
      tableName,
      where: 'id = ?',
      whereArgs: [camionTypeID],
    );
    if(maps.isEmpty){
      return null;
    }

    return responseItemToCamionType(maps.first);

  } catch (e){
    print("Error while getting data of Camion Type with id $camionTypeID from table Camion Types: $e");
    return null;
  }
}

Future<Map<String, CamionType>?> getSortedFilteredCamionTypes({
  required dynamic dbOrTxn,
  String? searchQuery,
  String sortByField = 'name',
  bool isDescending = false,
}) async {
  Map<String, CamionType> camionTypes = {};
  List<String> whereConditions = [];
  List<dynamic> whereArgs = [];

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

    for (var camionTypeItem in maps) {
      camionTypes[camionTypeItem["id"] as String] = responseItemToCamionType(camionTypeItem);
    }

    return sortedCamionTypes(camionTypes: camionTypes, sortByField: sortByField, isSortDescending: isDescending);

  } catch (e) {
    print("Error while getting Company Camions: $e");
    rethrow;
  }
}

Map<String, dynamic> camionTypeToMap(CamionType camionType, {String? firebaseId}) {
  return {
    'id': firebaseId,
    'name': camionType.name,
    'lol': (camionType.lol != null && camionType.lol != [] )
        ? jsonEncode(camionType.lol!.map((e) => e).toList())
        : null,
    'equipment': (camionType.equipment != null && camionType.equipment != [] )
        ? jsonEncode(camionType.equipment!.map((e) => e).toList())
        : null,
    'routerData': (camionType.routerData != null && camionType.routerData != [] )
        ? jsonEncode(camionType.routerData!.map((e) => e).toList())
        : null,
    'createdAt': camionType.createdAt.toIso8601String(),
    'updatedAt': camionType.updatedAt.toIso8601String(),
    'deletedAt': camionType.deletedAt?.toIso8601String(),
  };
}

CamionType responseItemToCamionType(var camionTypeItem){
  return CamionType(
    name: camionTypeItem["name"] as String,
    lol: camionTypeItem["lol"] != null
        ? dataInJsonToList(camionTypeItem["lol"] as String)
        : null,
    equipment: camionTypeItem["equipment"] != null
        ? dataInJsonToList(camionTypeItem["equipment"] as String)
        : null,
    routerData: camionTypeItem["routerData"] != null
        ? dataInJsonToList(camionTypeItem["routerData"] as String)
        : null,
    createdAt: DateTime.parse(camionTypeItem["createdAt"] as String),
    updatedAt: DateTime.parse(camionTypeItem["updatedAt"] as String),
    deletedAt: camionTypeItem["deletedAt"] != null
        ? DateTime.parse(camionTypeItem["deletedAt"] as String)
        : null,
  );
}

List<String> dataInJsonToList(String data){
  final List<dynamic> decodedData = jsonDecode(data);
  return decodedData.map((item) => item as String).toList();
}

LinkedHashMap<String, CamionType> sortedCamionTypes({
  required Map<String, CamionType> camionTypes,
  String sortByField = 'name',
  bool isSortDescending = false,
}) {
  List<String> sortedKeys = camionTypes.keys.toList();

  int compareFields(String field, CamionType a, CamionType b) {
    String? valueA, valueB;

    switch (field) {
      case 'name':
        valueA = a.name;
        valueB = b.name;
        break;
      // case 'company':
      //   valueA = a.company;
      //   valueB = b.company;
      //   break;
      default:
        valueA = a.name;
        valueB = b.name;
    }

    int comparison = valueA.compareTo(valueB);
    return isSortDescending ? -comparison : comparison;
  }

  sortedKeys.sort((a, b) {
    CamionType camionTypeA = camionTypes[a]!;
    CamionType camionTypeB = camionTypes[b]!;

    int primaryComparison = compareFields(sortByField, camionTypeA, camionTypeB);

    if (primaryComparison != 0) {
      return primaryComparison;
    }

    return compareFields('name', camionTypeA, camionTypeB);
  });

  return LinkedHashMap.fromIterable(
    sortedKeys,
    key: (k) => k,
    value: (k) => camionTypes[k]!,
  );
}