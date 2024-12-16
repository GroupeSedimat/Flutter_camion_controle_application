import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/equipment/equipment.dart';
import 'package:flutter_application_1/models/database_local/table_sync_info.dart';
import 'package:flutter_application_1/services/database_company_service.dart';
import 'package:flutter_application_1/services/database_firestore/database_camion_service.dart';
import 'package:flutter_application_1/services/database_firestore/database_camion_type_service.dart';
import 'package:flutter_application_1/services/database_firestore/database_equipment_service.dart';
import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/equipments_table.dart';
import 'package:flutter_application_1/services/database_local/update_tables.dart';
import 'package:flutter_application_1/services/dialog_services.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:sqflite/sqflite.dart';

class SyncService {
  final Database db;
  final NetworkService networkService;
  final DatabaseCamionService firebaseCamionService = DatabaseCamionService();
  final UserService firebaseUserService = UserService();
  final DatabaseCamionTypeService firebaseCamionTypeService = DatabaseCamionTypeService();
  final DatabaseEquipmentService firebaseEquipmentService = DatabaseEquipmentService();
  final DatabaseCompanyService firebaseCompanyService = DatabaseCompanyService();

  SyncService(this.db, this.networkService);

  Future<bool> syncFromFirebase(String tableName, String timeSync) async {
    bool itsOk = true;
    String lastSync = "";
    TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
    if (lastUpdatedDatas == null) {
      print("No sync available for table: $tableName");
    }else{
      lastSync = lastUpdatedDatas.lastRemoteSync ?? "";
      print("------------ Last sync for table: $tableName was: $lastSync");
    }

    print("-----------sync service From Firebase start");
      switch (tableName) {
        case "users":
          ///sync current User data

          break;

        case "camions":
        /// sync Camion DB
          List<Map<String, dynamic>> conflicts = [];
          await db.transaction((txn) async {
            print("----------- sync service From Firebase camions");
            final Map<String, Camion> firebaseCamions = await firebaseCamionService.getAllCamionsSinceLastSync(lastSync);
            final Map<String, Camion>? localCamions = await getAllCamionsSinceLastUpdate(txn, lastSync, timeSync);
            print("----------- Firebase camions since last update $firebaseCamions");

            for (var firebaseCamion in firebaseCamions.entries) {
              final Camion? localCamion = localCamions?[firebaseCamion.key];
              if (localCamion == null) {
                await insertCamion(txn, firebaseCamion.value, firebaseCamion.key);
              } else {
                conflicts.add({
                  'firebaseKey': firebaseCamion.key,
                  'firebase': firebaseCamion.value,
                  'local': localCamion,
                });
              }
            }
          });

          for (var conflict in conflicts) {
            final shouldContinue = await showConflictDialog(
              conflict['firebase'],
              conflict['local'],
            );

            if (shouldContinue == '') {
              itsOk = false;
              throw Exception("Synchronization canceled by user.");
            }

            await db.transaction((txn) async {
              await resolveConflict(
                txn,
                conflict['firebaseKey'],
                conflict['firebase'],
                conflict['local'],
                shouldContinue,
                tableName,
              );
            });
          }

          print("----------- sync service From Firebase camions end");
          break;

        case "camionTypes":
          /// sync Camion types DB
          List<Map<String, dynamic>> conflicts = [];
          await db.transaction((txn) async {
            print("----------- sync service From Firebase camionTypes");

            final Map<String, CamionType> firebaseCamionTypes = await firebaseCamionTypeService.getAllCamionsSinceLastSync(lastSync);
            final Map<String, CamionType>? localCamionTypes = await getAllCamionTypesSinceLastUpdate(txn, lastSync, timeSync);
            print("----------- Firebase camion types since last update $firebaseCamionTypes");

            for (var firebaseCamionType in firebaseCamionTypes.entries) {
              final CamionType? localCamionType = localCamionTypes?[firebaseCamionType.key];
              if (localCamionType == null) {
                await insertCamionType(txn, firebaseCamionType.value, firebaseCamionType.key);
              } else {
                conflicts.add({
                  'firebaseKey': firebaseCamionType.key,
                  'firebase': firebaseCamionType.value,
                  'local': localCamionType,
                });
              }
            }
          });

          for (var conflict in conflicts) {
            final shouldContinue = await showConflictDialog(
              conflict['firebase'],
              conflict['local'],
            );

            if (shouldContinue == '') {
              itsOk = false;
              throw Exception("Synchronization canceled by user.");
            }

            await db.transaction((txn) async {
              await resolveConflict(
                txn,
                conflict['firebaseKey'],
                conflict['firebase'],
                conflict['local'],
                shouldContinue,
                tableName,
              );
            });
          }

          print("----------- sync service From Firebase camionTypes end");
          break;
        case "companies":
          /// sync Companies DB
          List<Map<String, dynamic>> conflicts = [];
          await db.transaction((txn) async {
            print("----------- sync service From Firebase Companies");
            final Map<String, Company> firebaseCompanies = await firebaseCompanyService.getAllCompaniesSinceLastSync(lastSync);
            final Map<String, Company>? localCompanies = await getAllCompaniesSinceLastUpdate(txn, lastSync, timeSync);
            print("----------- Firebase Companies since last update $firebaseCompanies");

            for (var firebaseCompany in firebaseCompanies.entries) {
              final Company? localCompany = localCompanies?[firebaseCompany.key];
              if (localCompany == null) {
                await insertCompany(txn, firebaseCompany.value, firebaseCompany.key);
              } else {
                conflicts.add({
                  'firebaseKey': firebaseCompany.key,
                  'firebase': firebaseCompany.value,
                  'local': localCompanies,
                });
              }
            }
          });

          for (var conflict in conflicts) {
            final shouldContinue = await showConflictDialog(
              conflict['firebase'],
              conflict['local'],
            );

            if (shouldContinue == '') {
              itsOk = false;
              throw Exception("Synchronization canceled by user.");
            }

            await db.transaction((txn) async {
              await resolveConflict(
                txn,
                conflict['firebaseKey'],
                conflict['firebase'],
                conflict['local'],
                shouldContinue,
                tableName,
              );
            });
          }

          print("----------- sync service From Firebase Companies end");
          break;
        case "listOfLists":

          /// sync LoL DB
          break;
        case "validateTasks":

          /// sync Validated Tasks DB
          break;
        case "equipments":
          /// sync Equipments DB
          List<Map<String, dynamic>> conflicts = [];
          await db.transaction((txn) async {
            print("----------- sync service From Firebase Equipments");

            final Map<String, Equipment> firebaseEquipments = await firebaseEquipmentService.getAllEquipmentsSinceLastSync(lastSync);
            final Map<String, Equipment>? localEquipmentsTypes = await getAllEquipmentsSinceLastUpdate(txn, lastSync, timeSync);
            print("----------- Firebase Equipments since last update $firebaseEquipments");

            for (var firebaseEquipment in firebaseEquipments.entries) {
              final Equipment? localEquipment = localEquipmentsTypes?[firebaseEquipment.key];
              if (localEquipment == null) {
                await insertEquipment(txn, firebaseEquipment.value, firebaseEquipment.key);
              } else {
                conflicts.add({
                  'firebaseKey': firebaseEquipment.key,
                  'firebase': firebaseEquipment.value,
                  'local': localEquipment,
                });
              }
            }
          });

          for (var conflict in conflicts) {
            final shouldContinue = await showConflictDialog(
              conflict['firebase'],
              conflict['local'],
            );

            if (shouldContinue == '') {
              itsOk = false;
              throw Exception("Synchronization canceled by user.");
            }

            await db.transaction((txn) async {
              await resolveConflict(
                txn,
                conflict['firebaseKey'],
                conflict['firebase'],
                conflict['local'],
                shouldContinue,
                tableName,
              );
            });
          }

          print("----------- sync service From Firebase Equipments end");
          break;
        case "blueprints":

          /// sync Blueprints DB
          break;
        default:
          throw "Invalid Table";
      }
      return itsOk;
  }

  Future<void> syncToFirebase(String tableName, String timeSync) async {
    print("-----------sync service To Firebase start");
    switch (tableName) {
      case "users":
      ///sync current User data
        break;

      case "camions":
      /// sync Camions DB
        print("-----------sync service To Firebase camions start");

        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          print("-----------sync service To Firebase camions sync no needed");
          break;
        }
        final Map<String, Camion>? localCamions = await getAllCamionsSinceLastUpdate(db, lastUpdated, timeSync);
        print("----------- camions since last update $localCamions");
        if(localCamions != null){
          for (var camion in localCamions.entries) {
            if(camion.key == ""){
              camion.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseCamionService.addCamion(camion.value);
              await updateCamionFirebaseID(db, camion.value, newID);
            }else{
              await firebaseCamionService.updateCamion(camion.key, camion.value);
            }
          }
        }
        print("-----------sync service To Firebase end");
        break;

      case "camionTypes":
      /// sync Camion types DB
        print("-----------sync service To Firebase camion types start");

        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          print("-----------sync service To Firebase camion types sync no needed");
          break;
        }
        final Map<String, CamionType>? localCamionTypes = await getAllCamionTypesSinceLastUpdate(db, lastUpdated, timeSync);
        print("----------- camion types since last update $localCamionTypes");
        if(localCamionTypes != null){
          for (var camionType in localCamionTypes.entries) {
            if(camionType.key == ""){
              camionType.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseCamionTypeService.addCamionType(camionType.value);
              await updateCamionTypesFirebaseID(db, camionType.value, newID);
            }else{
              await firebaseCamionTypeService.updateCamionType(camionType.key, camionType.value);
            }
          }
        }
        print("-----------sync service To Firebase end");
        break;
      case "companies":
      /// sync Companies DB
        print("-----------sync service To Firebase companies types start");

        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          print("-----------sync service To Firebase companies sync no needed");
          break;
        }
        final Map<String, Company>? localCompanies = await getAllCompaniesSinceLastUpdate(db, lastUpdated, timeSync);
        print("----------- companies since last update $localCompanies");
        if(localCompanies != null){
          for (var company in localCompanies.entries) {
            if(company.key == ""){
              company.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseCompanyService.addCompany(company.value);
              await updateCompanyFirebaseID(db, company.value, newID);
            }else{
              await firebaseCompanyService.updateCompany(company.key, company.value);
            }
          }
        }
        print("-----------sync service To Firebase end");
        break;
      case "listOfLists":
      /// sync LoL DB
        break;
      case "validateTasks":
      /// sync Validated Tasks DB
        break;
      case "equipments":
      /// sync Equipments DB
        print("-----------sync service To Firebase Equipments start");

        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          print("-----------sync service To Firebase Equipments sync no needed");
          break;
        }
        final Map<String, Equipment>? localEquipments = await getAllEquipmentsSinceLastUpdate(db, lastUpdated, timeSync);
        print("----------- Equipments since last update $localEquipments");
        if(localEquipments != null){
          for (var equipment in localEquipments.entries) {
            if(equipment.key == ""){
              equipment.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseEquipmentService.addEquipment(equipment.value);
              await updateEquipmentFirebaseID(db, equipment.value, newID);
            }else{
              await firebaseEquipmentService.updateEquipment(equipment.key, equipment.value);
            }
          }
        }
        print("-----------sync service To Firebase end");
        break;
      case "blueprints":
      /// sync Blueprints DB
        break;
      default:
        throw "Invalid Table";
    }
  }

  Future<void> fullSyncTable(String tableName) async {
    String timeSync = DateTime.now().toIso8601String();
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible for table: $tableName");
      return;
    }
    try {
      print("Online mode, sync possible for table: $tableName");
      bool itsOk = await syncFromFirebase(tableName, timeSync);
      await syncToFirebase(tableName, timeSync);
      if(itsOk){
        await markCamionAsRemoteSynced(db, tableName, timeSync);
        await markTableLocalAsUpdated(db, tableName, timeSync);
      }
    } catch (e) {
      print("Error during full sync for $tableName: $e");
    }
  }

  Future<String> showConflictDialog(
    dynamic firebaseData,
    dynamic localData,
    ) async {
    final result = await DialogService().showDialog<String>(
      title: 'Conflict Detected',
      message: 'What action would you like to take?\n\n'
          'Firebase: ${firebaseData.name} ${firebaseData.updatedAt}\n'
          'Local: ${localData.name} ${localData.updatedAt}',
      actions: [
        DialogAction<String>(
          label: 'Merge, use Firebase data',
          result: 'firebase',
        ),
        DialogAction<String>(
          label: 'Merge, use local data',
          result: 'local',
        ),
        DialogAction<String>(
          label: 'Cancel, sync will be performed later',
          result: '',
        ),
      ],
    );
    return result ?? '';
  }

  Future<void> resolveConflict(
      dynamic dbOrTxn,
      String firebaseKey,
      dynamic firebaseData,
      dynamic localData,
      String shouldContinue,
      String tableName,
      ) async {

    switch (tableName) {
      case "users":
      ///resolve current User data
        break;

      case "camions":
      /// resolve Camion DB
        print("resolve camion with mode: $shouldContinue");
        if (shouldContinue == 'firebase') {
          await updateCamion(dbOrTxn, firebaseData as Camion, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateCamion(dbOrTxn, localData as Camion, firebaseKey);
        }
        break;

      case "camionTypes":
      /// resolve Camion types DB
        print("resolve camion type with mode: $shouldContinue");
        if (shouldContinue == 'firebase') {
          await updateCamionType(dbOrTxn, firebaseData as CamionType, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateCamionType(dbOrTxn, localData as CamionType, firebaseKey);
        }
        break;
      case "companies":
      /// resolve Companies DB
        break;
      case "listOfLists":
      /// resolve LoL DB
        break;
      case "validateTasks":
      /// resolve Validated Tasks DB
        break;
      case "equipments":
      /// resolve Equipments DB
      print("resolve Equipment with mode: $shouldContinue");
        if (shouldContinue == 'firebase') {
          await updateEquipment(dbOrTxn, firebaseData as Equipment, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateEquipment(dbOrTxn, localData as Equipment, firebaseKey);
        }
        break;
      case "blueprints":
      /// resolve Blueprints DB
        break;
      default:
        throw "Invalid Table";
    }
  }
}