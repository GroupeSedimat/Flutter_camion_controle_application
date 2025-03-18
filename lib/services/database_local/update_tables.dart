import 'package:flutter_application_1/models/database_local/table_sync_info.dart';
import 'package:sqflite/sqflite.dart';

String updatesTableName = "updates";

/// une classe fonctionnant sur la table "updates" dans database local
/// la classe d'assistance enregistre les dernières modifications et
/// les dernières dates de synchronisation des tables dans une base de données locale
/// (pour faciliter la synchronisation avec Firebase)
Future<void> createTableInfo(Database db) async {
  await db.execute('''
    CREATE TABLE $updatesTableName (
      tableName TEXT,
      lastLocalUpdate TEXT,
      lastRemoteSync TEXT
    )
  ''');
}

Future<void> insertTableInfo(Database db, String tableName) async {
  try{
    await db.insert(
        updatesTableName,
        {
          'tableName': tableName,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while inserting data into table TableSyncInfo: $e");
  }
}

Future<void> updateTableInfo(Database db, TableSyncInfo table) async {
  print("Updating table ${table.tableName} ...");
  try{
    await db.update(
        updatesTableName,
        table.toJson(),
        where: 'tableName = ?',
        whereArgs: [table.tableName],
        conflictAlgorithm: ConflictAlgorithm.replace);
    print("Updated table ${table.tableName}");
  } catch (e){
    print("Error while updating data for ${table.tableName} in table TableSyncInfo: $e");
  }
}

Future<void> deleteTableInfo(Database db, TableSyncInfo table) async {
  try{
    await db.delete(
        updatesTableName,
        where: 'tableName = ?',
        whereArgs: [table.tableName]
    );
  } catch (e){
    print("Error while deleting data with name ${table.tableName} in table TableSyncInfo: $e");
  }
}

Future<List<TableSyncInfo>?> getAllUpdates(Database db) async {
  try {
    final List<Map<String, dynamic>> maps = await db.query(updatesTableName);
    if (maps.isEmpty) return null;

    return maps.map((table) => TableSyncInfo.fromJson(table)).toList();
  } catch (e){
    print("Error while getting all data from table TableSyncInfo: $e");
    return null;
  }
}

Future<void> insertMultiple(Database db, List<TableSyncInfo> updateTables) async {
  try {
    var batch = db.batch();

    for (var table in updateTables) {
      batch.insert(
        updatesTableName,
        {
          'tableName': table.tableName,
          'lastLocalUpdate': DateTime.now().toIso8601String(),
          'lastRemoteSync': table.lastRemoteSync,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  } catch (e) {
    print("Error while inserting multiple updates into table TableSyncInfo: $e");
  }
}

Future<void> markTableAsRemoteSynced(Database db, String tableName, String timeSync) async {
  try{
    await db.update(
        updatesTableName,
        {
          'lastRemoteSync': timeSync,
        },
        where: 'tableName = ?',
        whereArgs: [tableName],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for $tableName in table UpdatesTable: $e");
  }
}

Future<void> markTableLocalAsUpdated(Database db, String tableName, String timeUpdate) async {
  try{
    await db.update(
        updatesTableName,
        {
          'lastLocalUpdate': timeUpdate,
        },
        where: 'tableName = ?',
        whereArgs: [tableName],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for $tableName in table UpdatesTable: $e");
  }
}

Future<void> updateMultiple(Database db, List<TableSyncInfo> updateTables, DateTime timeSync) async {
  try {
    var batch = db.batch();

    for (var table in updateTables) {
      batch.update(
        updatesTableName,
        {
          'lastLocalUpdate': timeSync.toIso8601String(),
        },
        where: 'tableName = ?',
        whereArgs: [table.tableName],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  } catch (e) {
    print("Error while inserting multiple updates into table TableSyncInfo: $e");
  }
}

Future<TableSyncInfo?> getOneWithName(dynamic dbOrTxn, String tableName) async {
  try{
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
      updatesTableName,
      where: 'tableName = ?',
      whereArgs: [tableName],
    );
    if(maps.isEmpty){
      return null;
    }

    return TableSyncInfo.fromJson(maps.first);

  } catch (e){
    print("Error while getting data of table with name $tableName from table TableSyncInfo: $e");
    return null;
  }
}