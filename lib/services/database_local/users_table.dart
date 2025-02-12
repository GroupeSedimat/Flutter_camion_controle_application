import 'dart:collection';

import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:sqflite/sqflite.dart';

String tableName = "users";

Future<void> createTableUsers(Database db) async {
  await db.execute('''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      role TEXT,
      username TEXT,
      email TEXT,
      name TEXT,
      firstname TEXT,
      company TEXT,
      apresFormation TEXT,
      apresFormationDoc TEXT,
      camion TEXT,
      thisUser TEXT,
      createdAt TEXT,
      updatedAt TEXT,
      deletedAt TEXT
    )
  ''');
}

Future<void> insertUser(dynamic dbOrTxn, MyUser user, String firebaseId, String thisUser) async {
  try{
    await dbOrTxn.insert(
        tableName,
        userToMap(user, firebaseId: firebaseId, thisUser: thisUser),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while inserting data into table Users: $e");
  }
}

Future<void> updateUser(dynamic dbOrTxn, MyUser user, String firebaseId) async {
  try{
    await dbOrTxn.update(
        tableName,
        userToMap(user, firebaseId: firebaseId),
        where: 'id = ?',
        whereArgs: [firebaseId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for ${user.name} in table Users: $e");
  }
}

Future<void> softDeleteUser(Database db, String firebaseId) async {
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
    print("Error while deleting data with id $firebaseId in table Users: $e");
  }
}

Future<void> restoreUser(Database db, String firebaseId) async {
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
    print("Error while restoring data with id $firebaseId in table Users: $e");
  }
}

Future<Map<String,MyUser>?> getAllUsers(Database db) async {
  Map<String, MyUser> users = {};
  try{
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if(maps.isEmpty){
      return null;
    }

    for (var user in maps) {
      users[user["id"] as String] = responseItemToUser(user);
    }

  } catch (e){
    print("Error while getting all data from table Users: $e");
  }
  return users;
}

Future<Map<String,String>?> getAllUsersNames(Database db) async {
  Map<String, String> usersNames = {};
  try{
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if(maps.isEmpty){
      return null;
    }

    for (var user in maps) {
      usersNames[user["id"] as String] = responseItemToUser(user).username;
    }

  } catch (e){
    print("Error while getting all Names from table Users: $e");
  }
  return usersNames;
}

Future<Map<String,MyUser>?> getAllUsersSinceLastUpdate(dynamic dbOrTxn, String lastUpdated, String timeSync) async {
  Map<String, MyUser> users = {};
  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
        tableName,
        where: 'updatedAt > ? AND updatedAt < ?',
        whereArgs: [lastUpdated, timeSync]);
    if(maps.isEmpty){
      return null;
    }
    print("-------- last updated Users $lastUpdated");

    for (var user in maps) {
      print("-------- user ${user["id"]} updatedAt ${user["updatedAt"]}");
      users[user["id"] as String] = responseItemToUser(user);
    }

    // return sortedUsers(users: users);
    return users;

  } catch (e){
    print("Error while getting all data from table Users since last actualisation: $e");
  }
  return sortedUsers(users: users);
}

Future<Map<String,MyUser>?> getAllCompanyUsersSinceLastUpdate(dynamic dbOrTxn, String lastUpdated, String timeSync, String companyName) async {
  Map<String, MyUser> users = {};
  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
        tableName,
        where: 'updatedAt > ? AND updatedAt < ? AND company = ?',
        whereArgs: [lastUpdated, timeSync, companyName]);
    if(maps.isEmpty){
      return null;
    }
    print("-------- last updated Users $lastUpdated");

    for (var user in maps) {
      print("-------- user ${user["id"]} updatedAt ${user["updatedAt"]}");
      users[user["id"] as String] = responseItemToUser(user);
    }

    return sortedUsers(users: users);

  } catch (e){
    print("Error while getting all data from table Users since last actualisation: $e");
  }
  return sortedUsers(users: users);
}

Future<Map<String,MyUser>?> getUserDataSinceLastUpdate(dynamic dbOrTxn, String lastUpdated, String timeSync, String userId) async {
  Map<String, MyUser> users = {};
  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
        tableName,
        where: 'updatedAt > ? AND updatedAt < ?',
        whereArgs: [lastUpdated, timeSync]);
    if(maps.isEmpty){
      return null;
    }

    for (var user in maps) {
      if(user["id"] == userId){
        print("-------- user ${user["id"]} updatedAt ${user["updatedAt"]}");
        users[user["id"] as String] = responseItemToUser(user);
      }
    }

    return users;

  } catch (e){
    print("Error while getting user data since last actualisation from table Users: $e");
  }
  return sortedUsers(users: users);
}

Future<void> insertMultipleUsers(dynamic dbOrTxn, Map<String, MyUser> user) async {
  try {
    var batch = dbOrTxn.batch();

    user.forEach((firebaseId, user) {
      batch.insert(
        tableName,
        userToMap(user, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await batch.commit(noResult: true);
  } catch (e) {
    print("Error while inserting multiple types into table Users: $e");
  }
}

Future<MyUser?> getOneUserWithID(dynamic dbOrTxn, String userID) async {
  try{
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
      tableName,
      where: 'id = ?',
      whereArgs: [userID],
    );
    if(maps.isEmpty){
      return null;
    }
    return responseItemToUser(maps.first);
  } catch (e){
    print("Error while getting data of User with id $userID from table Users: $e");
    return null;
  }
}

Future<Map<String,MyUser>?> getThisUser(dynamic dbOrTxn) async {
  Map<String, MyUser> users = {};
  try{
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
      tableName,
      where: 'thisUser = ?',
      whereArgs: ["true"],
    );
    if(maps.isEmpty){
      return null;
    }
    for (var user in maps) {
      if(user["thisUser"] == "true"){
        print("-------- user ${user["id"]} updatedAt ${user["updatedAt"]} is this user ${user["thisUser"]}");
        print("-------- user ${user["role"]} username ${user["username"]} is apresFormation ${user["apresFormation"]}");
        users[user["id"] as String] = responseItemToUser(user);
        print("users $users");
      }
    }
    return users;
  } catch (e){
    print("Error while getting data of this User from table Users: $e");
    return null;
  }
}

Map<String, dynamic> userToMap(MyUser user, {String? firebaseId, String? thisUser}) {
  String? apresFormation;
  if(user.apresFormation == true){
    apresFormation = "true";
  }else if(user.apresFormation == false){
    apresFormation = "false";
  }
  return {
    'id': firebaseId,
    'role': user.role,
    'username': user.username,
    'email': user.email,
    'name': user.name,
    'firstname': user.firstname,
    'company': user.company,
    'apresFormation': apresFormation,
    'apresFormationDoc': user.apresFormationDoc,
    'camion': user.camion,
    'createdAt': user.createdAt.toIso8601String(),
    'updatedAt': user.updatedAt.toIso8601String(),
    'deletedAt': user.deletedAt?.toIso8601String(),
    'thisUser' : thisUser,
  };
}

MyUser responseItemToUser(var user){
  bool? afterFormation;
  if(user['apresFormation'] == "true"){
    afterFormation = true;
  }else if (user['apresFormation'] == "false"){
    afterFormation = false;
  }
  return MyUser(
    role: user["role"] as String,
    username: user["username"] as String,
    email: user["email"] as String,
    name: user["name"]!= null
        ?  user['name'] as String
        : null,
    firstname: user["firstname"]!= null
        ? user['firstname'] as String
        : null,
    company: user["company"] as String,
    apresFormation: afterFormation,
    apresFormationDoc: user["apresFormationDoc"]!= null
        ? user['apresFormationDoc'] as String
        : null,
    camion: user["camion"]!= null
        ? user['camion'] as String
        : null,
    createdAt: DateTime.parse(user["createdAt"] as String),
    updatedAt: DateTime.parse(user["updatedAt"] as String),
    deletedAt: user["deletedAt"] != null
        ? DateTime.parse(user["deletedAt"] as String)
        : null,
  );
}

LinkedHashMap<String, MyUser> sortedUsers({
  required Map<String, MyUser> users,
  String sortByField = 'username',
  bool isSortDescending = false,
}) {
  List<String> sortedKeys = users.keys.toList();

  int compareFields(String field, MyUser a, MyUser b) {
    String? valueA, valueB;

    switch (field) {
      case 'username':
        valueA = a.username;
        valueB = b.username;
        break;
      case 'name':
        valueA = a.name;
        valueB = b.name;
        break;
      case 'firstname':
        valueA = a.firstname;
        valueB = b.firstname;
        break;
      case 'company':
        valueA = a.company;
        valueB = b.company;
        break;
      default:
        valueA = a.username;
        valueB = b.username;
    }

    int comparison = valueA!.compareTo(valueB!);
    return isSortDescending ? -comparison : comparison;
  }

  sortedKeys.sort((a, b) {
    MyUser userA = users[a]!;
    MyUser userB = users[b]!;

    int primaryComparison = compareFields(sortByField, userA, userB);

    if (primaryComparison != 0) {
      return primaryComparison;
    }

    return compareFields('username', userA, userB);
  });

  return LinkedHashMap.fromIterable(
    sortedKeys,
    key: (k) => k,
    value: (k) => users[k]!,
  );
}