import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/database_local/table_sync_info.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/camion/database_camion_service.dart';
import 'package:flutter_application_1/services/camion/database_camion_type_service.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local/update_tables.dart';
import 'package:flutter_application_1/services/dialog_services.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:sqflite/sqflite.dart';

class SyncService {
  final Database db;
  final DatabaseCamionService firebaseCamionService = DatabaseCamionService();
  final UserService firebaseUserService = UserService();
  final DatabaseCamionTypeService firebaseCamionTypeService = DatabaseCamionTypeService();

  SyncService(this.db);

  Future<void> syncFromFirebase(String tableName, DateTime timeSync) async {

    print("-----------sync service From Firebase start");
    switch (tableName) {
      case "users":
        ///sync current User data
        MyUser userData = await firebaseUserService.getCurrentUserData();

        break;

      case "camions":
      /// sync Camion DB
        print("----------- sync service From Firebase camions");
        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastSync = lastUpdatedDatas!.lastRemoteSync ?? "";

        final Map<String, Camion> firebaseCamions = await firebaseCamionService.getAllCamionsSinceLastSync(lastSync);
        final Map<String, Camion>? localCamions = await getAllCamionsSinceLastUpdate(db, lastSync);
        print("----------- Firebase camions since last update $firebaseCamions");
        for (var firebaseCamion in firebaseCamions.entries) {
          print(" ------------- camion from Firebase");
          print(" ------------- camion from Firebase $firebaseCamion");
          final Camion? localCamion = localCamions?[firebaseCamion.key];
          if (localCamion == null) {
            await insertCamion(db, firebaseCamion.value, firebaseCamion.key);
          }else{
            ///resolve conflicts
            print("-------------- conflict ");
            showConflictDialog(firebaseCamion.toString(), localCamion.toString());
          }
        }
        print("----------- sync service From Firebase end");
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

  Future<void> syncToFirebase(String tableName, DateTime timeSync) async {
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
        final Map<String, Camion>? localCamions = await getAllCamionsSinceLastUpdate(db, lastUpdated);
        print("----------- camions since last update $localCamions");
        if(localCamions != null){
          for (var camion in localCamions.entries) {
            if(camion.key == ""){
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
    DateTime timeSync = DateTime.now();
    try {
      await syncFromFirebase(tableName, timeSync);
      await syncToFirebase(tableName, timeSync);
      // await updateTableInfo(db, TableSyncInfo(
      //   tableName: tableName,
      //   lastLocalUpdate: timeSync.toIso8601String(),
      //   lastRemoteSync: timeSync.toIso8601String(),
      // ));
      await markCamionAsRemoteSynced(db, tableName, timeSync);
      await markTableLocalAsUpdated(db, tableName, timeSync);
    } catch (e) {
      print("Error during full sync for $tableName: $e");
    }
  }

  Future<void> showConflictDialog(
    String firebaseData,
    String localData,
    // Function onFirebaseVersion,
    // Function onLocalVersion,
    // Function onCreateNew,
    // Function onCancel
    ) async {
    return DialogService().showDialog(
      title: 'Conflict Detected',
      message: 'What action would you like to take?\n\n'
          'Firebase: $firebaseData\n'
          'Local: $localData',
      actions: [
        DialogAction(
          label: 'Merge, use Firebase data',
          onPressed: () {
            // onFirebaseVersion();
            print('Firebase chosen');
          },
        ),
        DialogAction(
          label: 'Merge, use local data',
          onPressed: () {
            // onLocalVersion();
            print('Local data chosen');
          },
        ),
        // DialogAction(
        //   label: 'Merge',
        //   onPressed: () {
        //     print('Merging data');
        //   },
        // ),
        DialogAction(
          label: 'Cancel',
          onPressed: () {
            // onCancel();
            print('cancel');
          },
        ),
      ],
    );
  }
}