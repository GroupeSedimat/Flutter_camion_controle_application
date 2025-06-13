import 'dart:collection';

import 'package:flutter_application_1/models/equipment/equipment.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

String tableName = "equipments";

Future<void> createTableEquipments(Database db) async {
  await db.execute('''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      idShop TEXT,
      name TEXT,
      description TEXT,
      photo TEXT,
      quantity INTEGER,
      available TEXT,
      createdAt TEXT,
      updatedAt TEXT,
      deletedAt TEXT
    )
  ''');
}

Future<void> insertEquipment(
    dynamic dbOrTxn, Equipment equipment, String firebaseId) async {
  try {
    await dbOrTxn.insert(
        tableName, equipmentToMap(equipment, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e) {
    print("Error while inserting data into table Equipments: $e");
  }
}

Future<void> updateEquipment(
    dynamic dbOrTxn, Equipment equipment, String firebaseId) async {
  try {
    await dbOrTxn.update(
        tableName, equipmentToMap(equipment, firebaseId: firebaseId),
        where: 'id = ?',
        whereArgs: [firebaseId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e) {
    print(
        "Error while updating data for ${equipment.name} in table Equipments: $e");
  }
}

Future<void> updateEquipmentFirebaseID(
    Database db, Equipment equipment, String firebaseId) async {
  List<String> whereConditions = [];
  List<dynamic> whereArgs = [];

  if (equipment.name != "" && equipment.name.isNotEmpty) {
    whereConditions.add('name = ?');
    whereArgs.add(equipment.name);
  }
  if (equipment.idShop != "" && equipment.idShop != null) {
    whereConditions.add('idShop = ?');
    whereArgs.add(equipment.idShop);
  }

  String? whereClause =
      whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null;

  try {
    await db.update(
        tableName, equipmentToMap(equipment, firebaseId: firebaseId),
        where: whereClause,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e) {
    print(
        "Error while updating data for ${equipment.name} in table Equipments: $e");
  }
}

Future<void> softDeleteEquipment(Database db, String firebaseId) async {
  try {
    await db.update(
        tableName,
        {
          'updatedAt': DateTime.now().toIso8601String(),
          'deletedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [firebaseId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e) {
    print(
        "Error while deleting data with id $firebaseId in table Equipments: $e");
  }
}

Future<void> restoreEquipment(Database db, String firebaseId) async {
  try {
    await db.update(tableName,
        {'updatedAt': DateTime.now().toIso8601String(), 'deletedAt': null},
        where: 'id = ?',
        whereArgs: [firebaseId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e) {
    print(
        "Error while restoring data with id $firebaseId in table Equipments: $e");
  }
}

Future<Map<String, Equipment>?> getAllEquipments(
    Database db, String role) async {
  Map<String, Equipment> equipments = {};
  try {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if (maps.isEmpty) {
      return null;
    }

    for (var equipmentItem in maps) {
      if (equipmentItem["deletedAt"] == null || role == "superadmin") {
        equipments[equipmentItem["id"] as String] =
            responseItemToEquipment(equipmentItem);
      }
    }
  } catch (e) {
    print("Error while getting all data from table Equipments: $e");
  }
  return sortedEquipments(equipments: equipments);
}

Future<Map<String, String>?> getAllEquipmentsNames(
    Database db, String role) async {
  Map<String, String> equipmentsNames = {};
  try {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if (maps.isEmpty) {
      return null;
    }

    for (var equipmentItem in maps) {
      if (equipmentItem["deletedAt"] == null || role == "superadmin") {
        equipmentsNames[equipmentItem["id"] as String] =
            responseItemToEquipment(equipmentItem).name;
      }
    }
  } catch (e) {
    print("Error while getting all Names from table Equipments: $e");
  }
  return equipmentsNames;
}

Future<Map<String, Equipment>?> getAllEquipmentsSinceLastUpdate(
    dynamic dbOrTxn, String lastUpdated, String timeSync) async {
  Map<String, Equipment> equipments = {};
  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(tableName,
        where: 'updatedAt > ? AND updatedAt < ?',
        whereArgs: [lastUpdated, timeSync]);
    if (maps.isEmpty) {
      return null;
    }
    print("-------- last updated Equipments $lastUpdated");

    for (var equipmentItem in maps) {
      print(
          "-------- equipment ${equipmentItem["id"]} updatedAt ${equipmentItem["updatedAt"]}");
      equipments[equipmentItem["id"] as String] =
          responseItemToEquipment(equipmentItem);
    }

    return sortedEquipments(equipments: equipments);
  } catch (e) {
    print(
        "Error while getting all data from table Equipments since last actualisation: $e");
  }
  return sortedEquipments(equipments: equipments);
}

Future<void> insertMultipleEquipments(
    dynamic dbOrTxn, Map<String, Equipment> equipments) async {
  try {
    var batch = dbOrTxn.batch();

    equipments.forEach((firebaseId, equipment) {
      batch.insert(
        tableName,
        equipmentToMap(equipment, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await batch.commit(noResult: true);
  } catch (e) {
    print("Error while inserting multiple types into table Equipments: $e");
  }
}

Future<Equipment?> getOneEquipmentWithID(
    dynamic dbOrTxn, String equipmentID) async {
  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
      tableName,
      where: 'id = ?',
      whereArgs: [equipmentID],
    );
    if (maps.isEmpty) {
      return null;
    }

    return responseItemToEquipment(maps.first);
  } catch (e) {
    print(
        "Error while getting data of Equipment with id $equipmentID from table Equipments: $e");
    return null;
  }
}

Map<String, dynamic> equipmentToMap(Equipment equipment, {String? firebaseId}) {
  String? available;
  if (equipment.available == null) {
    available = null;
  } else if (equipment.available == false) {
    available = "false";
  } else {
    available = "true";
  }
  return {
    'id': firebaseId,
    'idShop': equipment.idShop,
    'name': equipment.name,
    'description': equipment.description,
    'photo': (equipment.photo != null && equipment.photo != [])
        ? jsonEncode(equipment.photo!.map((e) => e).toList())
        : null,
    'quantity': equipment.quantity,
    'available': available,
    'createdAt': equipment.createdAt.toIso8601String(),
    'updatedAt': equipment.updatedAt.toIso8601String(),
    'deletedAt': equipment.deletedAt?.toIso8601String(),
  };
}

Equipment responseItemToEquipment(var equipmentItem) {
  bool available = false;
  if (equipmentItem["available"] == "true") {
    available = true;
  }
  return Equipment(
    idShop: equipmentItem["idShop"] != null
        ? equipmentItem['idShop'] as String
        : null,
    name: equipmentItem["name"] as String,
    description: equipmentItem["description"] != null
        ? equipmentItem['description'] as String
        : null,
    photo: equipmentItem["photo"] != null
        ? dataInJsonToList(equipmentItem["photo"] as String)
        : null,
    quantity: equipmentItem["quantity"] != null
        ? equipmentItem['quantity'] as int
        : null,
    available: available,
    createdAt: DateTime.parse(equipmentItem["createdAt"] as String),
    updatedAt: DateTime.parse(equipmentItem["updatedAt"] as String),
    deletedAt: equipmentItem["deletedAt"] != null
        ? DateTime.parse(equipmentItem["deletedAt"] as String)
        : null,
  );
}

List<String> dataInJsonToList(String data) {
  final List<dynamic> decodedData = jsonDecode(data);
  return decodedData.map((item) => item as String).toList();
}

LinkedHashMap<String, Equipment> sortedEquipments({
  required Map<String, Equipment> equipments,
  String sortByField = 'name',
  bool isSortDescending = false,
}) {
  List<String> sortedKeys = equipments.keys.toList();

  int compareFields(String field, Equipment a, Equipment b) {
    String? valueA, valueB;

    switch (field) {
      case 'name':
        valueA = a.name;
        valueB = b.name;
        break;
      case 'idShop':
        valueA = a.idShop;
        valueB = b.idShop;
        break;
      default:
        valueA = a.name;
        valueB = b.name;
    }

    int comparison = valueA!.compareTo(valueB!);
    return isSortDescending ? -comparison : comparison;
  }

  sortedKeys.sort((a, b) {
    Equipment equipmentA = equipments[a]!;
    Equipment equipmentB = equipments[b]!;

    int primaryComparison = compareFields(sortByField, equipmentA, equipmentB);

    if (primaryComparison != 0) {
      return primaryComparison;
    }

    return compareFields('name', equipmentA, equipmentB);
  });

  return LinkedHashMap.fromIterable(
    sortedKeys,
    key: (k) => k,
    value: (k) => equipments[k]!,
  );
}
