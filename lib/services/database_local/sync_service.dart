import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/database_local/table_sync_info.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/camion/database_camion_service.dart';
import 'package:flutter_application_1/services/camion/database_camion_type_service.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
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

  SyncService(this.db, this.networkService);

  Future<bool> syncFromFirebase(String tableName, String timeSync) async {
    bool itsOk = true;
    List<Map<String, dynamic>> conflicts = [];
    print("-----------sync service From Firebase start");
      switch (tableName) {
        case "users":

          ///sync current User data
          MyUser userData = await firebaseUserService.getCurrentUserData();

          break;

        case "camions":

          /// sync Camion DB
          await db.transaction((txn) async {
            print("----------- sync service From Firebase camions");
            TableSyncInfo? lastUpdatedDatas = await getOneWithName(txn, tableName);
            if (lastUpdatedDatas == null) {
              print("No sync information available for table: $tableName");
              return;
            }

            String lastSync = lastUpdatedDatas.lastRemoteSync ?? "";

            final Map<String, Camion> firebaseCamions =
            await firebaseCamionService.getAllCamionsSinceLastSync(lastSync);
            final Map<String, Camion>? localCamions =
            await getAllCamionsSinceLastUpdate(txn, lastSync, timeSync);
            print("----------- Firebase camions since last update $firebaseCamions");

            for (var firebaseCamion in firebaseCamions.entries) {
              final Camion? localCamion = localCamions?[firebaseCamion.key];
              if (localCamion == null) {
                await insertCamion(txn, firebaseCamion.value, firebaseCamion.key);
              } else {
                conflicts.add({
                  'firebase': firebaseCamion.value,
                  'local': localCamion,
                  'firebaseKey': firebaseCamion.key,
                });
              }
            }
          });

          for (var conflict in conflicts) {
            final shouldContinue = await showConflictDialog(
              conflict['firebase'].toString(),
              conflict['local'].toString(),
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
              );
            });
          }

          print("----------- sync service From Firebase end");
          break;

        case "camionTypes":

          /// sync Camion types DB
          Map<String, CamionType> firebaseCamionTypes =
              await firebaseCamionTypeService.getAllCamionTypes();
          break;
        case "companies":

          /// sync Companies DB
          break;
        case "listOfLists":

          /// sync LoL DB
          break;
        case "validateTasks":

          /// sync Validated Tasks DB
          break;
        case "equipments":

          /// sync Equipments DB
          break;
        case "blueprints":

          /// sync Blueprints DB
          break;
        default:
          throw "Role invalide";
      }
      return itsOk;
  }

  Future<void> syncToFirebase(String tableName, String timeSync) async {
    print("-----------sync service To Firebase start");
    switch (tableName) {
      case "users":
      ///sync current User data
        MyUser userData = await firebaseUserService.getCurrentUserData();
        break;

      case "camions":
        print("-----------sync service To Firebase camions start");
      // sync Camion DB
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
              camion.value.updatedAt = timeSync as DateTime;
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
        Map<String, CamionType> firebaseCamionTypes = await firebaseCamionTypeService.getAllCamionTypes();
        break;
      case "companies":
      /// sync Companies DB
        break;
      case "listOfLists":
      /// sync LoL DB
        break;
      case "validateTasks":
      /// sync Validated Tasks DB
        break;
      case "equipments":
      /// sync Equipments DB
        break;
      case "blueprints":
      /// sync Blueprints DB
        break;
      default:
        throw "Role invalide";
    }
  }

  Future<void> fullSyncTable(String tableName) async {
    String timeSync = DateTime.now().toIso8601String();
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible for table: $tableName");
      return;
    }
    try {
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
    String firebaseData,
    String localData,
    ) async {
    final result = await DialogService().showDialog<String>(
      title: 'Conflict Detected',
      message: 'What action would you like to take?\n\n'
          'Firebase: $firebaseData\n'
          'Local: $localData',
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
      Camion firebaseCamion,
      Camion localCamion,
      String shouldContinue,
      ) async {
    if (shouldContinue == 'firebase') {
      await updateCamion(dbOrTxn, firebaseCamion, firebaseKey);
    } else if (shouldContinue == 'local') {
      await updateCamion(dbOrTxn, localCamion, firebaseKey);
    }
  }
}