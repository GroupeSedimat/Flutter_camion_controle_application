import 'dart:collection';

import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:sqflite/sqflite.dart';

String tableName = "listOfLists";

/// une classe fonctionnant sur la table "listOfLists" dans database local
Future<void> createTableListOfLists(Database db) async {
  await db.execute('''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      listNr INTEGER,
      listName TEXT,
      createdAt TEXT,
      updatedAt TEXT,
      deletedAt TEXT
    )
  ''');
}

Future<void> insertList(dynamic dbOrTxn, ListOfLists listOfLists, String firebaseId) async {
  try{
    await dbOrTxn.insert(
        tableName,
        listOfListsToMap(listOfLists, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while inserting data into table ListOfLists: $e");
  }
}

Future<void> updateList(dynamic dbOrTxn, ListOfLists listOfLists, String firebaseId) async {
  try{
    await dbOrTxn.update(
        tableName,
        listOfListsToMap(listOfLists, firebaseId: firebaseId),
        where: 'id = ?',
        whereArgs: [firebaseId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for ${listOfLists.listName} in table ListOfLists: $e");
  }
}

Future<void> updateListFirebaseID(Database db, ListOfLists listOfLists, String firebaseId) async {
  List<String> whereConditions = [];
  List<dynamic> whereArgs = [];

  whereConditions.add('listNr = ?');
  whereArgs.add(listOfLists.listNr);

  String? whereClause = whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null;

  try {
    await db.update(
        tableName,
        listOfListsToMap(listOfLists, firebaseId: firebaseId),
        where: whereClause,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for ${listOfLists.listName} in table ListOfLists: $e");
  }
}

Future<void> softDeleteList(Database db, String firebaseId) async {
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
    print("Error while deleting data with id $firebaseId in table ListOfLists: $e");
  }
}

Future<void> restoreList(Database db, String firebaseId) async {
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
    print("Error while restoring data with id $firebaseId in table List of Lists: $e");
  }
}

Future<Map<String,ListOfLists>?> getAllLists(Database db, String role) async {
  Map<String, ListOfLists> listOfLists = {};
  try{
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if(maps.isEmpty){
      return null;
    }

    for (var litItem in maps) {
      if(litItem["deletedAt"] == null || role == "superadmin"){
        listOfLists[litItem["id"] as String] = responseItemToListOfLists(litItem);
      }
    }

  } catch (e){
    print("Error while getting all data from table ListOfLists: $e");
  }
  return sortedListOfLists(listOfLists: listOfLists);
}

Future<int> getFirstFreeListNumber(Database db) async {
  int lastListID = 0;
  try{
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if(maps.isEmpty){
      return lastListID;
    }

    for (var litItem in maps) {
      String id = litItem["id"];
      if(id.length<10 && int.parse(id)>lastListID){
        lastListID = int.parse(id);
      }
    }

  } catch (e){
    print("Error while getting first free ListOfLists ID: $e");
  }
  return lastListID + 1;
}

Future<Map<String,ListOfLists>?> getAllListsSinceLastUpdate(dynamic dbOrTxn, String lastUpdated, String timeSync) async {
  Map<String, ListOfLists> listOfLists = {};
  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
        tableName,
        where: 'updatedAt > ? AND updatedAt < ?',
        whereArgs: [lastUpdated, timeSync]);
    if(maps.isEmpty){
      return null;
    }

    for (var element in maps) {
      listOfLists[element["id"] as String] = responseItemToListOfLists(element);
    }

    return sortedListOfLists(listOfLists: listOfLists);

  } catch (e){
    print("Error while getting all data from table ListOfLists since last actualisation: $e");
  }
  return sortedListOfLists(listOfLists: listOfLists);
}

Future<void> insertMultipleLists(dynamic dbOrTxn, Map<String, ListOfLists> listOfLists) async {
  try {
    var batch = dbOrTxn.batch();

    listOfLists.forEach((firebaseId, list) {
      batch.insert(
        tableName,
        listOfListsToMap(list, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await batch.commit(noResult: true);
  } catch (e) {
    print("Error while inserting multiple types into table ListOfLists: $e");
  }
}

Future<ListOfLists?> getOneListWithID(dynamic dbOrTxn, String listID) async {
  try{
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
      tableName,
      where: 'id = ?',
      whereArgs: [listID],
    );
    if(maps.isEmpty){
      return null;
    }

    return responseItemToListOfLists(maps.first);

  } catch (e){
    print("Error while getting data of List with id $listID from table ListOfLists: $e");
    return null;
  }
}

Future<LinkedHashMap<String, ListOfLists>?> getMultipleListsWithIDs(dynamic dbOrTxn, List<String> listIDs) async {
  try{
    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    for(String id in listIDs){
      whereConditions.add('id = ?');
      whereArgs.add(id);
    }

    String? whereClause = whereConditions.isNotEmpty ? whereConditions.join(' OR ') : null;
    Map<String, ListOfLists> listOfLists = {};
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
      tableName,
      where: whereConditions,
      whereArgs: whereClause,
    );
    if(maps.isEmpty){
      return null;
    }
    for (var element in maps) {
      listOfLists[element["id"] as String] = responseItemToListOfLists(element);
    }
    return sortedListOfLists(listOfLists: listOfLists);
  } catch (e){
    print("Error while getting data of Lists from table ListOfLists: $e");
    return null;
  }
}

Future<int> findFirstFreeListNr(dynamic dbOrTxn) async{
  try {
    final List<Map<String, dynamic>> result = await dbOrTxn.rawQuery('''
      SELECT MAX(listNr) as maxListNr FROM $tableName
    ''');
    final maxListNr = result.first['maxListNr'] as int?;
    final freeNr = (maxListNr ?? 0) + 1;
    return freeNr;
  } catch (e) {
    print("Error finding first free list number: $e");
    rethrow;
  }
}

Map<String, dynamic> listOfListsToMap(ListOfLists listOfLists, {String? firebaseId}) {
  return {
    'id': firebaseId,
    'listNr': listOfLists.listNr,
    'listName': listOfLists.listName,
    'createdAt': listOfLists.createdAt.toIso8601String(),
    'updatedAt': listOfLists.updatedAt.toIso8601String(),
    'deletedAt': listOfLists.deletedAt?.toIso8601String(),
  };
}

ListOfLists responseItemToListOfLists(var listOfListsItem){
  return ListOfLists(
    listNr: listOfListsItem["listNr"] as int,
    listName: listOfListsItem["listName"] as String,
    createdAt: DateTime.parse(listOfListsItem["createdAt"] as String),
    updatedAt: DateTime.parse(listOfListsItem["updatedAt"] as String),
    deletedAt: listOfListsItem["deletedAt"] != null ? DateTime.parse(listOfListsItem["deletedAt"] as String) : null,
  );
}

LinkedHashMap<String, ListOfLists> sortedListOfLists({
  required Map<String, ListOfLists> listOfLists,
  String sortByField = 'listNr',
  bool isSortDescending = false,
}) {
  List<String> sortedKeys = listOfLists.keys.toList();

  int compareFields(String field, ListOfLists a, ListOfLists b) {
    var valueA, valueB;

    switch (field) {
      case 'listNr':
        valueA = a.listNr;
        valueB = b.listNr;
        break;
      case 'listName':
        valueA = a.listName;
        valueB = b.listName;
        break;
      default:
        valueA = a.createdAt;
        valueB = b.createdAt;
    }

    int comparison = valueA!.compareTo(valueB!);
    return isSortDescending ? -comparison : comparison;
  }

  sortedKeys.sort((a, b) {
    ListOfLists listA = listOfLists[a]!;
    ListOfLists listB = listOfLists[b]!;

    int primaryComparison = compareFields(sortByField, listA, listB);

    if (primaryComparison != 0) {
      return primaryComparison;
    }

    return compareFields('nrEntryPosition', listA, listB);
  });

  return LinkedHashMap.fromIterable(
    sortedKeys,
    key: (k) => k,
    value: (k) => listOfLists[k]!,
  );
}