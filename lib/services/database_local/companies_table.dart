import 'dart:collection';

import 'package:flutter_application_1/models/company/company.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

String tableName = "companies";

/// une classe fonctionnant sur la table "companies" dans database local
Future<void> createTableCompany(Database db) async {
  await db.execute('''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      name TEXT,
      description TEXT,
      sirene TEXT,
      siret TEXT,
      address TEXT,
      responsible TEXT,
      admin TEXT,
      tel TEXT,
      email TEXT,
      logo TEXT,
      createdAt TEXT,
      updatedAt TEXT,
      deletedAt TEXT
    )
  ''');
}

Future<void> insertCompany(dynamic dbOrTxn, Company company, String firebaseId) async {
  try{
    await dbOrTxn.insert(
        tableName,
        companyToMap(company, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while inserting data into table Companies: $e");
  }
}

Future<void> insertCompanyName(dynamic dbOrTxn, String companyName, String firebaseId) async {
  try{
    await dbOrTxn.insert(
        tableName,
        companyNameToMap(companyName, firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while inserting data into table Companies: $e");
  }
}

Future<void> updateCompany(dynamic dbOrTxn, Company company, String firebaseId) async {
  try{
    await dbOrTxn.update(
        tableName,
        companyToMap(company, firebaseId: firebaseId),
        where: 'id = ?',
        whereArgs: [firebaseId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for ${company.name} in table Companies: $e");
  }
}

Future<void> updateCompanyFirebaseID(Database db, Company company, String firebaseId) async {
  List<String> whereConditions = [];
  List<dynamic> whereArgs = [];

  if (company.name != "" && company.name.isNotEmpty) {
    whereConditions.add('name = ?');
    whereArgs.add(company.name);
  }
  if (company.sirene != "" && company.sirene != null) {
    whereConditions.add('sirene = ?');
    whereArgs.add(company.sirene);
  }
  if (company.siret != "" && company.siret != null) {
    whereConditions.add('siret = ?');
    whereArgs.add(company.siret);
  }

  String? whereClause = whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null;

  try {
    await db.update(
        tableName,
        companyToMap(company, firebaseId: firebaseId),
        where: whereClause,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (e){
    print("Error while updating data for ${company.name} in table Companies: $e");
  }
}

Future<void> softDeleteCompany(Database db, String firebaseId) async {
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
    print("Error while deleting data with id $firebaseId in table Companies: $e");
  }
}

Future<void> restoreCompany(Database db, String firebaseId) async {
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
    print("Error while restoring data with id $firebaseId in table Company: $e");
  }
}

Future<Map<String,Company>?> getAllCompanies(Database db, String role) async {
  Map<String, Company> companies = {};
  try{
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if(maps.isEmpty){
      return null;
    }

    for (var companyItem in maps) {
      if(companyItem["deletedAt"] == null || role == "superadmin"){
        companies[companyItem["id"] as String] = responseItemToCompany(companyItem);
      }
    }

  } catch (e){
    print("Error while getting all data from table Companies: $e");
  }
  return sortedCompanies(companies: companies);
}

Future<Map<String,String>?> getAllCompaniesNames(Database db, String role) async {
  Map<String, String> companiesNames = {};
  try{
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if(maps.isEmpty){
      return null;
    }

    for (var companyItem in maps) {
      if(companyItem["deletedAt"] == null || role == "superadmin"){
        companiesNames[companyItem["id"] as String] = responseItemToCompany(companyItem).name;
      }
    }

  } catch (e){
    print("Error while getting all Names from table Companies: $e");
  }
  return companiesNames;
}

Future<Map<String,Company>?> getAllCompaniesSinceLastUpdate(dynamic dbOrTxn, String lastUpdated, String timeSync) async {
  Map<String, Company> companies = {};
  try {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
        tableName,
        where: 'updatedAt > ? AND updatedAt < ?',
        whereArgs: [lastUpdated, timeSync]);
    if(maps.isEmpty){
      return null;
    }

    for (var companyItem in maps) {
      companies[companyItem["id"] as String] = responseItemToCompany(companyItem);
    }

    return sortedCompanies(companies: companies);

  } catch (e){
    print("Error while getting all data from table Companies since last actualisation: $e");
  }
  return sortedCompanies(companies: companies);
}

Future<void> insertMultipleCompanies(dynamic dbOrTxn, Map<String, Company> companies) async {
  try {
    var batch = dbOrTxn.batch();

    companies.forEach((firebaseId, company) {
      batch.insert(
        tableName,
        companyToMap(company, firebaseId: firebaseId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await batch.commit(noResult: true);
  } catch (e) {
    print("Error while inserting multiple types into table Companies: $e");
  }
}

Future<Company?> getOneCompanyWithID(dynamic dbOrTxn, String companyID) async {
  try{
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
      tableName,
      where: 'id = ?',
      whereArgs: [companyID],
    );
    if(maps.isEmpty){
      return null;
    }

    return responseItemToCompany(maps.first);

  } catch (e){
    print("Error while getting data of Company with id $companyID from table Companies: $e");
    return null;
  }
}

Map<String, dynamic> companyToMap(Company company, {String? firebaseId}) {
  return {
    'id': firebaseId,
    'name': company.name,
    'description': company.description,
    'sirene': company.sirene,
    'siret': company.siret,
    'address': company.address,
    'responsible': company.responsible,
    'admin': company.admin,
    'tel': company.tel,
    'email': company.email,
    'logo': company.logo,
    'createdAt': company.createdAt.toIso8601String(),
    'updatedAt': company.updatedAt.toIso8601String(),
    'deletedAt': company.deletedAt?.toIso8601String(),
  };
}

Map<String, dynamic> companyNameToMap(String companyName, String firebaseId) {
  return {
    'id': firebaseId,
    'name': companyName,
    'description': "",
    'sirene': "",
    'siret': "",
    'address': "",
    'responsible': "",
    'admin': "",
    'tel': "",
    'email': "",
    'logo': "",
    'createdAt': DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };
}

Company responseItemToCompany(var companyItem){
  return Company(
    name: companyItem["name"] as String,
    description: companyItem["description"]!= null
        ?  companyItem['description'] as String
        : null,
    sirene: companyItem["sirene"]!= null
        ? companyItem['sirene'] as String
        : null,
    siret: companyItem["siret"]!= null
        ? companyItem['siret'] as String
        : null,
    address: companyItem["address"]!= null
        ? companyItem['address'] as String
        : null,
    responsible: companyItem["responsible"]!= null
        ? companyItem['responsible'] as String
        : null,
    admin: companyItem["admin"]!= null
        ? companyItem['admin'] as String
        : null,
    tel: companyItem["tel"]!= null
        ? companyItem['tel'] as String
        : null,
    email: companyItem["email"]!= null
        ? companyItem['email'] as String
        : null,
    logo: companyItem["logo"]!= null
        ? companyItem['logo'] as String
        : null,
    createdAt: DateTime.parse(companyItem["createdAt"] as String),
    updatedAt: DateTime.parse(companyItem["updatedAt"] as String),
    deletedAt: companyItem["deletedAt"] != null
        ? DateTime.parse(companyItem["deletedAt"] as String)
        : null,
  );
}

List<String> dataInJsonToList(String data){
  final List<dynamic> decodedData = jsonDecode(data);
  return decodedData.map((item) => item as String).toList();
}

LinkedHashMap<String, Company> sortedCompanies({
  required Map<String, Company> companies,
  String sortByField = 'name',
  bool isSortDescending = false,
}) {
  List<String> sortedKeys = companies.keys.toList();

  int compareFields(String field, Company a, Company b) {
    String? valueA, valueB;

    switch (field) {
      case 'name':
        valueA = a.name;
        valueB = b.name;
        break;
      case 'sirene':
        valueA = a.sirene;
        valueB = b.sirene;
        break;
      case 'siret':
        valueA = a.siret;
        valueB = b.siret;
        break;
      case 'admin':
        valueA = a.admin;
        valueB = b.admin;
        break;
      default:
        valueA = a.name;
        valueB = b.name;
    }

    int comparison = valueA!.compareTo(valueB!);
    return isSortDescending ? -comparison : comparison;
  }

  sortedKeys.sort((a, b) {
    Company companyA = companies[a]!;
    Company companyB = companies[b]!;

    int primaryComparison = compareFields(sortByField, companyA, companyB);

    if (primaryComparison != 0) {
      return primaryComparison;
    }

    return compareFields('name', companyA, companyB);
  });

  return LinkedHashMap.fromIterable(
    sortedKeys,
    key: (k) => k,
    value: (k) => companies[k]!,
  );
}