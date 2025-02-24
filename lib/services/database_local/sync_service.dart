import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/equipment/equipment.dart';
import 'package:flutter_application_1/models/database_local/table_sync_info.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/database_firestore/database_company_service.dart';
import 'package:flutter_application_1/services/database_firestore/check_list/database_blueprints_service.dart';
import 'package:flutter_application_1/services/database_firestore/check_list/database_list_of_lists_service.dart';
import 'package:flutter_application_1/services/database_firestore/check_list/database_tasks_service.dart';
import 'package:flutter_application_1/services/database_firestore/database_camion_service.dart';
import 'package:flutter_application_1/services/database_firestore/database_camion_type_service.dart';
import 'package:flutter_application_1/services/database_firestore/database_equipment_service.dart';
import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local/check_list/blueprints_table.dart';
import 'package:flutter_application_1/services/database_local/check_list/list_of_lists_table.dart';
import 'package:flutter_application_1/services/database_local/check_list/tasks_table.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/equipments_table.dart';
import 'package:flutter_application_1/services/database_local/update_tables.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/dialog_services.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:sqflite/sqflite.dart';

class SyncService {
  final Database db;
  final NetworkService networkService;
  final DatabaseCamionService firebaseCamionService = DatabaseCamionService();
  final UserService firebaseUserService = UserService();
  final DatabaseCamionTypeService firebaseCamionTypeService = DatabaseCamionTypeService();
  final DatabaseEquipmentService firebaseEquipmentService = DatabaseEquipmentService();
  final DatabaseCompanyService firebaseCompanyService = DatabaseCompanyService();
  final DatabaseListOfListsService firebaseLOLService = DatabaseListOfListsService();
  final DatabaseTasksService firebaseTaskService = DatabaseTasksService();
  final DatabaseBlueprintsService firebaseBlueprintService = DatabaseBlueprintsService();

  SyncService(this.db, this.networkService);

  Future<void> fullSyncTable(String tableName, {MyUser? user, String? userId, List<String>? dataPlus}) async {
    String timeSync = DateTime.now().toIso8601String();
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible for table: $tableName");
      return;
    }
    try {
      print("🔛 Online mode, sync possible for table: $tableName 🔛");
      bool itsOk;
      print("Sync data plus: 💾💾💾💾 $dataPlus");
      if(user!=null){
        if(dataPlus != null){
          itsOk = await syncFromFirebase(tableName, timeSync, user: user, userId: userId, dataPlus: dataPlus);
        }else{
          itsOk = await syncFromFirebase(tableName, timeSync, user: user, userId: userId);
        }
        await syncToFirebase(tableName, timeSync, userId: userId);
      }else{
        itsOk = await syncFromFirebase(tableName, timeSync);
        await syncToFirebase(tableName, timeSync);
      }
      if(itsOk){
        await markTableAsRemoteSynced(db, tableName, timeSync);
        await markTableLocalAsUpdated(db, tableName, timeSync);
      }
    } catch (e) {
      print("Error during full sync for $tableName: $e");
    }
  }

  Future<bool> syncFromFirebase(String tableName, String timeSync, {MyUser? user, String? userId, List<String>? dataPlus}) async {
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
          /// sync User data:
          /// get data from firebase about user/s and write it to db local
          /// user need to be connected
          /// for superadmin - all users
          /// for company admin - company users
          /// for user - current user
          if(user == null || userId == null){
            print("user or userId not provided");
            break;
          }
          print("++++++++-----++++++++------- User: ${user.name} Role: ${user.role}");

          List<Map<String, dynamic>> conflicts = [];
          await db.transaction((txn) async {
            print("----------- sync service From Firebase Users");
            if(user.role == "superadmin"){
              final Map<String, MyUser> firebaseUsers = await firebaseUserService.getAllUsersDataSinceLastSync(lastSync);
              final Map<String, MyUser>? localUsers = await getAllUsersSinceLastUpdate(txn, lastSync, timeSync);
              print("----------- Firebase Users for superadmin since last update $firebaseUsers");

              for (var firebaseUser in firebaseUsers.entries) {
                final MyUser? localUser = localUsers?[firebaseUser.key];
                if (localUser == null) {
                  String thisUser = "false";
                  if(userId == firebaseUser.key){
                    thisUser = "true";
                  }
                  await insertUser(txn, firebaseUser.value, firebaseUser.key, thisUser);
                } else {
                  if(!firebaseUser.value.updatedAt.isAtSameMomentAs(localUser.updatedAt)){
                    conflicts.add({
                      'firebaseKey': firebaseUser.key,
                      'firebase': firebaseUser.value,
                      'local': localUser,
                    });
                  }
                }
              }
            }else if (user.role == "admin"){
              String companyName = user.company;
              final Map<String, MyUser> firebaseUsers = await firebaseUserService.getCompanyUsersDataSinceLastSync(lastSync, companyName);
              final Map<String, MyUser>? localUsers = await getAllCompanyUsersSinceLastUpdate(txn, lastSync, timeSync, companyName);
              print("----------- Firebase Users for admin since last update $firebaseUsers");

              for (var firebaseUser in firebaseUsers.entries) {
                final MyUser? localUser = localUsers?[firebaseUser.key];
                if (localUser == null) {
                  String thisUser = "false";
                  if(userId == firebaseUser.key){
                    thisUser = "true";
                  }
                  await insertUser(txn, firebaseUser.value, firebaseUser.key, thisUser);
                } else {
                  conflicts.add({
                    'firebaseKey': firebaseUser.key,
                    'firebase': firebaseUser.value,
                    'local': localUser,
                  });
                }
              }
            }else if (user.role == "user"){
              try{
                final Map<String, MyUser> firebaseUsers = await firebaseUserService.getCurrentUserMapSinceLastSync(lastSync, userId);
                final Map<String, MyUser>? localUsers = await getUserDataSinceLastUpdate(txn, lastSync, timeSync, userId);
                print("----------- Firebase Users for standard user since last update $firebaseUsers");

                for (var firebaseUser in firebaseUsers.entries) {
                  final MyUser? localUser = localUsers?[firebaseUser.key];
                  if (localUser == null) {
                    String thisUser = "false";
                    if(userId == firebaseUser.key){
                      thisUser = "true";
                    }
                    await insertUser(txn, firebaseUser.value, firebaseUser.key, thisUser);
                  } else {
                    if(!firebaseUser.value.updatedAt.isAtSameMomentAs(localUser.updatedAt)){
                      conflicts.add({
                        'firebaseKey': firebaseUser.key,
                        'firebase': firebaseUser.value,
                        'local': localUser,
                      });
                    }
                  }
                }
              }catch(e){
                print("Error retrieving User ${user.name}: $e");
              }
            }

          });

          for (var conflict in conflicts) {
            String shouldContinue = "";
            if(user.role == "superadmin" || user.role == "admin"){
              shouldContinue = await showConflictDialog(
                conflict['firebase'],
                conflict['local'],
              );
            }else{
              shouldContinue = 'firebase';
            }

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

          print("----------- sync service From Firebase Users end");

          break;

        case "camions":
        /// sync Camion DB
        /// get data from firebase about camions and write it do db local
        /// user need to be connected
        /// add camion for user, company or all depend on role
          List<Map<String, dynamic>> conflicts = [];
          if(user == null){
            print("user or userId not provided");
            break;
          }
          await db.transaction((txn) async {
            print("----------- sync service From Firebase camions");
            if(user.role == "superadmin"){
              final Map<String, Camion> firebaseCamions = await firebaseCamionService.getAllCamionsSinceLastSync(lastSync);
              final Map<String, Camion>? localCamions = await getAllCamionsSinceLastUpdate(txn, lastSync, timeSync);
              print("----------- Firebase camions since last update $firebaseCamions");

              for (var firebaseCamion in firebaseCamions.entries) {
                final Camion? localCamion = localCamions?[firebaseCamion.key];
                if (localCamion == null) {
                  await insertCamion(txn, firebaseCamion.value, firebaseCamion.key);
                } else {
                  if(!firebaseCamion.value.updatedAt.isAtSameMomentAs(localCamion.updatedAt)){
                    conflicts.add({
                      'firebaseKey': firebaseCamion.key,
                      'firebase': firebaseCamion.value,
                      'local': localCamion,
                    });
                  }
                }
              }
            }else if(user.role == "admin"){
              final Map<String, Camion> firebaseCamions = await firebaseCamionService.getCompanyCamionsSinceLastSync(user.company, lastSync);
              final Map<String, Camion>? localCamions = await getAllCamionsSinceLastUpdate(txn, lastSync, timeSync);
              print("----------- Firebase camions since last update $firebaseCamions");

              for (var firebaseCamion in firebaseCamions.entries) {
                final Camion? localCamion = localCamions?[firebaseCamion.key];
                if (localCamion == null) {
                  await insertCamion(txn, firebaseCamion.value, firebaseCamion.key);
                } else {
                  if(!firebaseCamion.value.updatedAt.isAtSameMomentAs(localCamion.updatedAt)){
                    conflicts.add({
                      'firebaseKey': firebaseCamion.key,
                      'firebase': firebaseCamion.value,
                      'local': localCamion,
                    });
                  }
                }
              }
            }else if(user.role == "user"){
              final Map<String, Camion> firebaseCamions = await firebaseCamionService.getListCamionSinceLastSync(user.camion!, lastSync);
              final Map<String, Camion>? localCamions = await getAllCamionsSinceLastUpdate(txn, lastSync, timeSync);
              print("----------- Firebase camions since last update $firebaseCamions");

              for (var firebaseCamion in firebaseCamions.entries) {
                if(firebaseCamion.value.deletedAt != null){
                  final Camion? localCamion = localCamions?[firebaseCamion.key];
                  if (localCamion == null) {
                    await insertCamion(txn, firebaseCamion.value, firebaseCamion.key);
                  } else {
                    if(!firebaseCamion.value.updatedAt.isAtSameMomentAs(localCamion.updatedAt)){
                      conflicts.add({
                        'firebaseKey': firebaseCamion.key,
                        'firebase': firebaseCamion.value,
                        'local': localCamion,
                      });
                    }
                  }
                }
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
          /// get data from firebase about camions types and write it do db local
          /// user need to be connected
          /// todo add camion types for company or all depend on role
          List<Map<String, dynamic>> conflicts = [];
          await db.transaction((txn) async {
            print("----------- sync service From Firebase camionTypes");
            Map<String, CamionType> firebaseCamionTypes = {};
            print("Data Plus 💾💾 in camionTypes: $dataPlus");
            if(dataPlus == null){
              firebaseCamionTypes = await firebaseCamionTypeService.getAllCamionTypesSinceLastSync(lastSync);
            }else{
              firebaseCamionTypes = await firebaseCamionTypeService.getListedCamionTypesSinceLastSync(lastSync, dataPlus);
            }
            final Map<String, CamionType>? localCamionTypes = await getAllCamionTypesSinceLastUpdate(txn, lastSync, timeSync);
            print("----------- Firebase camion types since last update $firebaseCamionTypes");

            for (var firebaseCamionType in firebaseCamionTypes.entries) {
              final CamionType? localCamionType = localCamionTypes?[firebaseCamionType.key];
              if (localCamionType == null) {
                await insertCamionType(txn, firebaseCamionType.value, firebaseCamionType.key);
              } else {
                if(!firebaseCamionType.value.updatedAt.isAtSameMomentAs(localCamionType.updatedAt)){
                  conflicts.add({
                    'firebaseKey': firebaseCamionType.key,
                    'firebase': firebaseCamionType.value,
                    'local': localCamionType,
                  });
                }
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
          /// get data from firebase about companies and write it do db local
          /// user no need to be connected
          /// todo add company for user or all depend on role
          /// todo add just companies names when not connected
          List<Map<String, dynamic>> conflicts = [];
          await db.transaction((txn) async {
            if(user == null){
              print("user or userId not provided");
            }else if(userId == "123456789"){
              Map<String, String> companiesNames = await firebaseCompanyService.getAllCompaniesNames();
              print("Names ok");
              for (var firebaseCompany in companiesNames.entries){
                insertCompanyName(txn, firebaseCompany.value, firebaseCompany.key);
              }
            }else{
              if(user.role == "superadmin"){
                print("----------- sync service From Firebase Companies");
                final Map<String, Company> firebaseCompanies = await firebaseCompanyService.getAllCompaniesSinceLastSync(lastSync);
                final Map<String, Company>? localCompanies = await getAllCompaniesSinceLastUpdate(txn, lastSync, timeSync);
                print("----------- Firebase Companies since last update $firebaseCompanies");

                for (var firebaseCompany in firebaseCompanies.entries) {
                  final Company? localCompany = localCompanies?[firebaseCompany.key];
                  if (localCompany == null) {
                    await insertCompany(txn, firebaseCompany.value, firebaseCompany.key);
                  } else {
                    if(!firebaseCompany.value.updatedAt.isAtSameMomentAs(localCompany.updatedAt)){
                      conflicts.add({
                        'firebaseKey': firebaseCompany.key,
                        'firebase': firebaseCompany.value,
                        'local': localCompany,
                      });
                    }
                  }
                }
              }else if(user.role == "admin" || user.role == "user"){
                print("----------- sync service From Firebase Companies");
                final Map<String, Company> firebaseCompanies = await firebaseCompanyService.getCompanyByIdSinceLastSync(lastSync, user.company);
                final Map<String, Company>? localCompanies = await getAllCompaniesSinceLastUpdate(txn, lastSync, timeSync);
                print("----------- Firebase Companies since last update $firebaseCompanies");

                for (var firebaseCompany in firebaseCompanies.entries) {
                  final Company? localCompany = localCompanies?[firebaseCompany.key];
                  if (localCompany == null) {
                    await insertCompany(txn, firebaseCompany.value, firebaseCompany.key);
                  } else {
                    if(!firebaseCompany.value.updatedAt.isAtSameMomentAs(localCompany.updatedAt)){
                      conflicts.add({
                        'firebaseKey': firebaseCompany.key,
                        'firebase': firebaseCompany.value,
                        'local': localCompany,
                      });
                    }
                  }
                }
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
          /// get data from firebase about list of lists and write it do db local
          /// user need to be connected
          List<Map<String, dynamic>> conflicts = [];
          print("Data Plus 💾💾 in List of Lists: $dataPlus");
          await db.transaction((txn) async {
            print("----------- sync service From Firebase LoL");
            Map<String, ListOfLists> firebaseLoL = {};
            if(dataPlus != null){
              firebaseLoL = await firebaseLOLService.getLoLsWithIds(lastSync, dataPlus);
            }else{
              firebaseLoL = await firebaseLOLService.getAllLOLSinceLastSync(lastSync);
            }
            final Map<String, ListOfLists>? localLoL = await getAllListsSinceLastUpdate(txn, lastSync, timeSync);
            print("----------- Firebase LOL since last update $firebaseLoL");

            for (var firebaseList in firebaseLoL.entries) {
              final ListOfLists? localList = localLoL?[firebaseList.key];
              if (localList == null) {
                await insertList(txn, firebaseList.value, firebaseList.key);
              } else {
                if(!firebaseList.value.updatedAt.isAtSameMomentAs(localList.updatedAt)){
                  conflicts.add({
                    'firebaseKey': firebaseList.key,
                    'firebase': firebaseList.value,
                    'local': localList,
                  });
                }
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
          print("----------- sync service From Firebase LoL end");
          break;

        case "validateTasks":
          /// sync Validated Tasks DB
          /// get data from firebase about tasks and write it do db local
          /// user need to be connected
          /// todo for user add task from firebase to local db
          /// todo if at least one date are newer local update delete local
          /// todo if if local are later than firebase data, delete firebase data
          List<Map<String, dynamic>> conflicts = [];
          if(userId == null){
            print("no userId provided");
            break;
          }
          await db.transaction((txn) async {
            print("----------- sync service From Firebase Tasks");
            final Map<String, TaskChecklist> firebaseTasks = await firebaseTaskService.getAllTasks(userId);
            String lastUpdate = (await getOneWithName(txn, tableName))?.lastLocalUpdate ?? "";
            print("----------- Firebase Tasks since last update $firebaseTasks");
            bool resetAllTasks = false;

            for (var firebaseTask in firebaseTasks.entries){
              print("firebase task updated at: ${firebaseTask.value.updatedAt}");
              print("local last updated at: $lastUpdate");
              if(lastUpdate != "" && firebaseTask.value.updatedAt.isAfter(DateTime.parse(lastUpdate))){

                resetAllTasks = true;
              }
            }
            
            print({"--------- -------- --------- ---------- ----- $resetAllTasks"});
            if(resetAllTasks){
              clearTaskTable(txn);
              for (var firebaseTask in firebaseTasks.entries){
                await insertTask(txn, firebaseTask.value, firebaseTask.key);
              }
            }else{
              for (var firebaseTask in firebaseTasks.entries){
                firebaseTaskService.deleteTaskFuture(firebaseTask.key);
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

          print("----------- sync service From Firebase Tasks end");
          break;

        case "equipments":
          /// sync Equipments DB
          /// get data from firebase about equipments and write it do db local
          /// user no need to be connected ?
          /// todo add all or just partial?
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
                if(!firebaseEquipment.value.updatedAt.isAtSameMomentAs(localEquipment.updatedAt)){
                  conflicts.add({
                    'firebaseKey': firebaseEquipment.key,
                    'firebase': firebaseEquipment.value,
                    'local': localEquipment,
                  });
                }
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
          /// get data from firebase about blueprints and write it do db local
          /// user need to be connected
          /// todo add blueprints for camion/s, or all depend on role and list
          List<Map<String, dynamic>> conflicts = [];
          await db.transaction((txn) async {
            print("----------- sync service From Firebase Blueprints");
            final Map<String, Blueprint> firebaseBlueprints = await firebaseBlueprintService.getAllBlueprintsSinceLastSync(lastSync);
            final Map<String, Blueprint>? localBlueprintsTypes = await getAllBlueprintsSinceLastUpdate(txn, lastSync, timeSync);
            print("----------- Firebase Blueprints since last update $firebaseBlueprints");

            for (var firebaseBlueprint in firebaseBlueprints.entries) {
              final Blueprint? localBlueprint = localBlueprintsTypes?[firebaseBlueprint.key];
              if (localBlueprint == null) {
                await insertBlueprint(txn, firebaseBlueprint.value, firebaseBlueprint.key);
              } else {
                if(!firebaseBlueprint.value.updatedAt.isAtSameMomentAs(localBlueprint.updatedAt)){
                  conflicts.add({
                    'firebaseKey': firebaseBlueprint.key,
                    'firebase': firebaseBlueprint.value,
                    'local': localBlueprint,
                  });
                }
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

          print("----------- sync service From Firebase Blueprints end");
          break;
        default:
          throw "Invalid Table";
      }
      return itsOk;
  }

  Future<void> syncToFirebase(String tableName, String timeSync, {String? userId}) async {
    print("-----------sync service To Firebase start");
    switch (tableName) {
      case "users":
      /// sync current User data
      ///
      /// get data from local db and update it in firebase
      /// user need to be connected
      /// todo update user/s, depend on role
      /// superadmin - update all
      /// admin - update company users
      /// user - update just user
      /// add clear data?

        print("-----------sync service To Firebase Users start");

        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          print("-----------sync service To Firebase Users sync no needed");
          break;
        }
        final Map<String, MyUser>? localUsers = await getAllUsersSinceLastUpdate(db, lastUpdated, timeSync);
        print("----------- Users since last update $localUsers");
        if(localUsers != null){
          for (var user in localUsers.entries) {
            print("updating user ${user.key} ${user.value.role} ${user.value.username}");
            await firebaseUserService.updateUser(user.key, user.value);
          }
        }
        print("-----------sync service To Firebase end");
        break;

      case "camions":
      /// sync Camions DB
      ///
      /// get data from local db and update it in firebase
      /// user need to be connected
      /// todo update camion/s, depend on role
      /// superadmin - update all
      /// admin - update company camions
      /// user - update just camion data
      /// add clear data?
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
      ///
      /// get data from local db and update it in firebase
      /// user need to be connected
      /// todo update camion types, depend on role
      /// superadmin - update all
      /// admin - update company involved types (or all?)
      /// user - update just user involved type
      /// add clear data?
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
      ///
      /// get data from local db and update it in firebase
      /// user need to be connected
      /// todo update company, depend on role
      /// superadmin - update all
      /// admin - update company
      /// user - can't update?
      /// add clear data?
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
      ///
      /// get data from local db and update it in firebase
      /// user need to be connected
      /// todo update list of lists
      /// superadmin - update all
      /// admin - can't update
      /// user - can't update
      /// add clear data?
        print("-----------sync service To Firebase LOL types start");

        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          print("-----------sync service To Firebase LOL sync no needed");
          break;
        }
        final Map<String, ListOfLists>? localListOfLists = await getAllListsSinceLastUpdate(db, lastUpdated, timeSync);
        print("----------- LOL last update $localListOfLists");
        if(localListOfLists != null){
          for (var list in localListOfLists.entries) {
            if(list.key == ""){
              list.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseLOLService.addList(list.value);
              await updateListFirebaseID(db, list.value, newID);
            }else{
              await firebaseLOLService.updateList(list.key, list.value);
            }
          }
        }
        print("-----------sync service To Firebase end");
        break;

      case "validateTasks":
      /// sync Validated Tasks DB
      ///
      /// get data from local db and update it in firebase
      /// user need to be connected
      /// todo update tasks, depend on role
      /// superadmin - don't have - clear data?
      /// admin - update users task data
      /// user - update user tasks data
      /// add clear data of tasks when list not in user list of lists?
        print("-----------sync service To Firebase Tasks start");
        TableSyncInfo? tableInfo = await getOneWithName(db, tableName);
        if(userId == null || tableInfo == null){
          print("---------- /////// +++++++++ no userId provided or no table info");
          break;
        }
        final Map<String, TaskChecklist>? tasks = await getAllTasksOfUser(db, userId);
        print("----------- Tasks last update $tasks");
        if(tasks != null){
          await firebaseTaskService.deleteTaskForUser(userId);
          for (var task in tasks.entries) {
            if(task.key == ""){
              task.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseTaskService.addTask(task.value);
              await updateTaskFirebaseID(db, task.value, newID);
            }else{
              await firebaseTaskService.addTask(task.value);
            }
          }
        }
        print("-----------sync service To Firebase end");
        break;

      case "equipments":
      /// sync Equipments DB
      ///
      /// get data from local db and update it in firebase
      /// user need to be connected
      /// todo update equipments
      /// superadmin - update all
      /// admin - can't update
      /// user - can't update
      /// add clear data?
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
      ///
      /// get data from local db and update it in firebase
      /// user need to be connected
      /// todo update blueprints
      /// superadmin - update all
      /// admin - can't update
      /// user - cant update
      /// add clear data?
        print("-----------sync service To Firebase Blueprints start");

        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          print("-----------sync service To Firebase Blueprints sync no needed");
          break;
        }
        final Map<String, Blueprint>? blueprints = await getAllBlueprintsSinceLastUpdate(db, lastUpdated, timeSync);
        print("----------- Blueprints last update $blueprints");
        if(blueprints != null){
          for (var blueprint in blueprints.entries) {
            if(blueprint.key == ""){
              blueprint.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseBlueprintService.addBlueprint(blueprint.value);
              await updateBlueprint(db, blueprint.value, newID);
            }else{
              await firebaseBlueprintService.updateBlueprint(blueprint.key, blueprint.value);
            }
          }
        }
        print("-----------sync service To Firebase end");
        break;

      default:
        throw "Invalid Table";
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
        print("resolve Users with mode: $shouldContinue");
        if (shouldContinue == 'firebase') {
          await updateUser(dbOrTxn, firebaseData as MyUser, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateUser(dbOrTxn, localData as MyUser, firebaseKey);
        }
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
        print("resolve Companies with mode: $shouldContinue");
        if (shouldContinue == 'firebase') {
          await updateCompany(dbOrTxn, firebaseData as Company, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateCompany(dbOrTxn, localData as Company, firebaseKey);
        }
        break;

      case "listOfLists":
      /// resolve LoL DB
        print("resolve LOL with mode: $shouldContinue");
        if (shouldContinue == 'firebase') {
          await updateList(dbOrTxn, firebaseData as ListOfLists, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateList(dbOrTxn, localData as ListOfLists, firebaseKey);
        }
        break;

      case "validateTasks":
      /// resolve Validated Tasks DB
        print("resolve Validated Tasks with mode: $shouldContinue");
        if (shouldContinue == 'firebase') {
          await updateTask(dbOrTxn, firebaseData as TaskChecklist, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateTask(dbOrTxn, localData as TaskChecklist, firebaseKey);
        }
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
        print("resolve Blueprints with mode: $shouldContinue");
        if (shouldContinue == 'firebase') {
          await updateBlueprint(dbOrTxn, firebaseData as Blueprint, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateBlueprint(dbOrTxn, localData as Blueprint, firebaseKey);
        }
        break;

      default:
        throw "Invalid Table";
    }
  }
}