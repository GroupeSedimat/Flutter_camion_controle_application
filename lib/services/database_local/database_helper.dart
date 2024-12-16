import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/equipments_table.dart';
import 'package:flutter_application_1/services/database_local/update_tables.dart';
import 'package:sqflite/sqflite.dart';
import 'camions_table.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<void> init() async {
    await database; // This ensures the database is initialized.
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/mctruck.db';

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await createTableCamions(db);
        await createTableCamionTypes(db);
        await createTableEquipments(db);
        await createTableInfo(db);
        await createTableCompany(db);
        await _initializeUpdateTable(db, [
          "users",
          "camions",
          "camionTypes",
          "companies",
          "listOfLists",
          "blueprints",
          "validateTasks",
          "equipments"
        ]);
      },
    );
  }

  Future<void> _initializeUpdateTable(Database db, List<String> tableNames) async {
    for (var tableName in tableNames) {
      final existingEntry = await db.query(
        updatesTableName,
        where: 'tableName = ?',
        whereArgs: [tableName],
      );

      if (existingEntry.isEmpty) {
        await insertTableInfo(db, tableName);
      }
    }
  }
}