import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/equipment/equipment.dart';
import 'package:flutter_application_1/models/database_local/table_sync_info.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/database_firestore/check_list/database_image_service.dart';
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
import 'package:flutter_application_1/utils/dialog_services.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/pdf/pdf_service.dart';
import 'package:open_document/my_files/init.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Service responsable de la synchronisation Firebase ↔ SQLite.
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

  /// Cette fonction assure le suivi de la synchronisation dans les deux sens
  /// (c'est-à-dire qu'elle appelle les fonctions syncFromFirebase et syncToFirebase de manière séquentielle)
  Future<void> fullSyncTable(String tableName, {MyUser? user, String? userId, List<String>? dataPlus}) async {
    String timeSync = DateTime.now().toIso8601String();
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible for table: $tableName");
      return;
    }
    try {
      bool itsOk;
      if(user!=null){
        if(dataPlus != null){
          itsOk = await syncFromFirebase(tableName, timeSync, user: user, userId: userId, dataPlus: dataPlus);
        }else{
          itsOk = await syncFromFirebase(tableName, timeSync, user: user, userId: userId);
        }
        await syncToFirebase(tableName, timeSync, user: user, userId: userId);
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

  /// Récupère les données de Firestore et met à jour la base de données locale.
  Future<bool> syncFromFirebase(String tableName, String timeSync, {MyUser? user, String? userId, List<String>? dataPlus}) async {
    bool itsOk = true;
    String lastSync = "";
    TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
    if (lastUpdatedDatas == null) {
      print("No sync available for table: $tableName");
    }else{
      lastSync = lastUpdatedDatas.lastRemoteSync ?? "";
    }

      switch (tableName) {
        case "users":
          /// sync User data:
          /// Récupérer les données de Firebase sur les utilisateurs et les enregistrer dans la base de données locale
          /// L'utilisateur doit être connecté
          /// Pour superadmin: tous les utilisateurs
          /// Pour admin: utilisateurs de l'entreprise
          /// Pour user : utilisateur actuel
          if(user == null || userId == null){
            print("user or userId not provided");
            break;
          }

          List<Map<String, dynamic>> conflicts = [];
          await db.transaction((txn) async {
            if(user.role == "superadmin"){
              final Map<String, MyUser> firebaseUsers = await firebaseUserService.getAllUsersDataSinceLastSync(lastSync);
              final Map<String, MyUser>? localUsers = await getAllUsersSinceLastUpdate(txn, lastSync, timeSync);

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
          break;

        case "camions":
        /// sync Camion DB
        /// Récupérer les données des camions depuis Firebase et les enregistrer dans la base de données locale
        /// L'utilisateur doit être connecté
        /// Ajouter un camion pour l'utilisateur, l'entreprise ou récupérer tous les camions, selon le rôle
          List<Map<String, dynamic>> conflicts = [];
          if(user == null){
            print("user or userId not provided");
            break;
          }else if(user.camion == null){
            print("no camion for user");
            break;
          }
          await db.transaction((txn) async {
            if(user.role == "superadmin"){
              final Map<String, Camion> firebaseCamions = await firebaseCamionService.getAllCamionsSinceLastSync(lastSync);
              final Map<String, Camion>? localCamions = await getAllCamionsSinceLastUpdate(txn, lastSync, timeSync);

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
              for (var firebaseCamion in firebaseCamions.entries) {
                if(firebaseCamion.value.deletedAt == null){
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
            }else if(user.role == "user"){
              final Map<String, Camion> firebaseCamions = await firebaseCamionService.getListCamionSinceLastSync(user.camion!, lastSync);
              final Map<String, Camion>? localCamions = await getAllCamionsSinceLastUpdate(txn, lastSync, timeSync);
              for (var firebaseCamion in firebaseCamions.entries){
                if(firebaseCamion.value.deletedAt == null){
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
          break;

        case "camionTypes":
          /// sync Camion types DB
          /// Récupération des données Firebase sur les types de camions les enregistrer dans la base de données locale
          /// L'utilisateur doit être connecté
          List<Map<String, dynamic>> conflicts = [];
          await db.transaction((txn) async {
            Map<String, CamionType> firebaseCamionTypes = {};
            if(dataPlus == null){
              firebaseCamionTypes = await firebaseCamionTypeService.getAllCamionTypesSinceLastSync(lastSync);
            }else{
              firebaseCamionTypes = await firebaseCamionTypeService.getListedCamionTypesSinceLastSync(lastSync, dataPlus);
            }
            final Map<String, CamionType>? localCamionTypes = await getAllCamionTypesSinceLastUpdate(txn, lastSync, timeSync);

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
          break;

        case "companies":
          /// sync Companies DB
          /// Récupérer des données sur les entreprises depuis Firebase et les enregistrer dans une base de données locale.
          /// L'utilisateur n'a pas besoin d'être connecté pour obtenir uniquement les noms des entreprises.
          ///
          List<Map<String, dynamic>> conflicts = [];
          await db.transaction((txn) async {
            if(userId == "123456789"){
              Map<String, String> companiesNames = await firebaseCompanyService.getAllCompaniesNames();
              for (var firebaseCompany in companiesNames.entries){
                insertCompanyName(txn, firebaseCompany.value, firebaseCompany.key);
              }
            }else if(user == null || userId == null){
              print("user or userId not provided");
            }else {
              if(user.role == "superadmin"){
                final Map<String, Company> firebaseCompanies = await firebaseCompanyService.getAllCompaniesSinceLastSync(lastSync);
                final Map<String, Company>? localCompanies = await getAllCompaniesSinceLastUpdate(txn, lastSync, timeSync);

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
                final Map<String, Company> firebaseCompanies = await firebaseCompanyService.getCompanyByIdSinceLastSync(lastSync, user.company);
                final Map<String, Company>? localCompanies = await getAllCompaniesSinceLastUpdate(txn, lastSync, timeSync);

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
          break;

        case "listOfLists":
          /// sync LoL DB
          /// Récupérer les données de Firebase concernant une liste de listes
          /// et les enregistrer dans la base de données locale.
          /// L'utilisateur doit être connecté.
          List<Map<String, dynamic>> conflicts = [];
          await db.transaction((txn) async {
            Map<String, ListOfLists> firebaseLoL = {};
            if(dataPlus != null){
              firebaseLoL = await firebaseLOLService.getLoLsWithIds(lastSync, dataPlus);
            }else{
              firebaseLoL = await firebaseLOLService.getAllLOLSinceLastSync(lastSync);
            }
            final Map<String, ListOfLists>? localLoL = await getAllListsSinceLastUpdate(txn, lastSync, timeSync);

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
          break;

        case "validateTasks":
          /// sync Validated Tasks DB
          /// Récupérer les données de Firebase concernant les tâches validées et les enregistrer dans la base de données locale
          /// L'utilisateur doit être connecté
          List<Map<String, dynamic>> conflicts = [];
          if(userId == null){
            print("no userId provided");
            break;
          }
          await db.transaction((txn) async {
            final Map<String, TaskChecklist> firebaseTasks = await firebaseTaskService.getAllTasks(userId);
            String lastUpdate = (await getOneWithName(txn, tableName))?.lastLocalUpdate ?? "";
            bool resetAllTasks = false;

            for (var firebaseTask in firebaseTasks.entries){
              if(lastUpdate != "" && firebaseTask.value.updatedAt.isAfter(DateTime.parse(lastUpdate))){
                resetAllTasks = true;
              }
            }

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
          break;

        case "equipments":
          /// sync Equipments DB
          /// récupérer les données des équipements depuis Firebase et les enregistrer dans la base de données locale
          List<Map<String, dynamic>> conflicts = [];
          await db.transaction((txn) async {

            final Map<String, Equipment> firebaseEquipments = await firebaseEquipmentService.getAllEquipmentsSinceLastSync(lastSync);
            final Map<String, Equipment>? localEquipmentsTypes = await getAllEquipmentsSinceLastUpdate(txn, lastSync, timeSync);

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
          break;

        case "blueprints":
          /// sync Blueprints DB
          /// Récupérer les données des blueprints depuis Firebase et les enregistrer dans la base de données locale.
          /// L'utilisateur doit être connecté.
          List<Map<String, dynamic>> conflicts = [];
          Directory appDocDir = await getApplicationSupportDirectory();
          DatabaseImageService databaseImageService = DatabaseImageService();
          await db.transaction((txn) async {
            final Map<String, Blueprint> firebaseBlueprints = await firebaseBlueprintService.getAllBlueprintsSinceLastSync(lastSync);
            final Map<String, Blueprint>? localBlueprintsTypes = await getAllBlueprintsSinceLastUpdate(txn, lastSync, timeSync);

            for (var firebaseBlueprint in firebaseBlueprints.entries) {
              final Blueprint? localBlueprint = localBlueprintsTypes?[firebaseBlueprint.key];
              if (localBlueprint == null) {
                await insertBlueprint(txn, firebaseBlueprint.value, firebaseBlueprint.key);
                for (String imageName in firebaseBlueprint.value.photoFilePath!) {
                  Uint8List? imageData = await databaseImageService.downloadBlueprintImageFromFirebase(imageName);

                  if (imageData != null) {
                    File localImageFile = File("${appDocDir.path}/$imageName");
                    await localImageFile.writeAsBytes(imageData);
                  } else {
                    print("Failed to load photo: $imageName");
                  }
                }
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
          break;

        case "pdf":
          /// La partie responsable de la synchronisation du PDF de Firebase vers la base de données locale
          /// Si je change d'avis (ou si quelqu'un d'autre le fait), j'ajouterai ici ce que devrait faire la synchronisation du côté Firestore vers la base de données locale.
          /// Il n'y a rien ici, vous n'êtes pas obligé de télécharger immédiatement les PDF depuis le serveur
          /// (cela se fait via la liste pdf de user, de admin ou du superadmin, c'est-à-dire en cliquant sur "download" à côté du fichier pdf souhaité)
          break;

        default:
          throw "Invalid Table";
      }
      return itsOk;
  }

  /// Envoie les modifications locales à Firestore.
  Future<void> syncToFirebase(String tableName, String timeSync, {MyUser? user, String? userId}) async {
    switch (tableName) {
      case "users":
      /// sync current User data

        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          // no change == no need sync
          break;
        }
        final Map<String, MyUser>? localUsers = await getAllUsersSinceLastUpdate(db, lastUpdated, timeSync);
        if(localUsers != null){
          for (var user in localUsers.entries) {
            await firebaseUserService.updateUser(user.key, user.value);
          }
        }
        break;

      case "camions":
      /// sync Camions DB

        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          // no change == no need sync
          break;
        }
        final Map<String, Camion>? localCamions = await getAllCamionsSinceLastUpdate(db, lastUpdated, timeSync);
        if(localCamions != null){
          for (var camion in localCamions.entries) {
            if(camion.key.length < 12){
              camion.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseCamionService.addCamion(camion.value);
              await updateCamionFirebaseID(db, camion.value, newID);
            }else{
              await firebaseCamionService.updateCamion(camion.key, camion.value);
            }
          }
        }
        break;

      case "camionTypes":
      /// sync Camion types DB

        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          // no change == no need sync
          break;
        }
        final Map<String, CamionType>? localCamionTypes = await getAllCamionTypesSinceLastUpdate(db, lastUpdated, timeSync);
        if(localCamionTypes != null){
          for (var camionType in localCamionTypes.entries) {
            if(camionType.key.length < 16){
              camionType.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseCamionTypeService.addCamionType(camionType.value);
              await updateCamionTypesFirebaseID(db, camionType.value, newID);
            }else{
              await firebaseCamionTypeService.updateCamionType(camionType.key, camionType.value);
            }
          }
        }
        break;

      case "companies":
      /// sync Companies DB

        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          // no change == no need sync
          break;
        }
        final Map<String, Company>? localCompanies = await getAllCompaniesSinceLastUpdate(db, lastUpdated, timeSync);
        if(localCompanies != null){
          for (var company in localCompanies.entries) {
            if(company.key.length < 16){
              company.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseCompanyService.addCompany(company.value);
              await updateCompanyFirebaseID(db, company.value, newID);
            }else{
              await firebaseCompanyService.updateCompany(company.key, company.value);
            }
          }
        }
        break;

      case "listOfLists":
      /// sync LoL DB

        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          // no change == no need sync
          break;
        }
        final Map<String, ListOfLists>? localListOfLists = await getAllListsSinceLastUpdate(db, lastUpdated, timeSync);
        if(localListOfLists != null){
          for (var list in localListOfLists.entries) {
            if(list.key.length < 16){
              list.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseLOLService.addList(list.value);
              await updateListFirebaseID(db, list.value, newID);
            }else{
              await firebaseLOLService.updateList(list.key, list.value);
            }
          }
        }
        break;

      case "validateTasks":
      /// sync Validated Tasks DB
        TableSyncInfo? tableInfo = await getOneWithName(db, tableName);
        if(userId == null || tableInfo == null){
          // no userId provided or no table info == no need sync
          break;
        }
        final Map<String, TaskChecklist>? tasks = await getAllTasksOfUser(db, userId);
        // no change == no need sync
        if(tasks != null){
          await firebaseTaskService.deleteTaskForUser(userId);
          for (var task in tasks.entries) {
            if(task.key.length < 16){
              task.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseTaskService.addTask(task.value);
              await updateTaskFirebaseID(db, task.value, newID);
            }else{
              await firebaseTaskService.addTask(task.value);
            }
          }
        }
        break;

      case "equipments":
      /// sync Equipments DB

        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          // no change == no need sync
          break;
        }
        final Map<String, Equipment>? localEquipments = await getAllEquipmentsSinceLastUpdate(db, lastUpdated, timeSync);
        if(localEquipments != null){
          for (var equipment in localEquipments.entries) {
            if(equipment.key.length < 16){
              equipment.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseEquipmentService.addEquipment(equipment.value);
              await updateEquipmentFirebaseID(db, equipment.value, newID);
            }else{
              await firebaseEquipmentService.updateEquipment(equipment.key, equipment.value);
            }
          }
        }
        break;

      case "blueprints":
      /// sync Blueprints DB
        DatabaseImageService databaseImageService = DatabaseImageService();
        TableSyncInfo? lastUpdatedDatas = await getOneWithName(db, tableName);
        String lastUpdated = lastUpdatedDatas?.lastLocalUpdate ?? "";
        if (lastUpdated == ""){
          // no change == no need sync
          break;
        }
        final Map<String, Blueprint>? blueprints = await getAllBlueprintsSinceLastUpdate(db, lastUpdated, timeSync);
        if(blueprints != null){
          for (var blueprint in blueprints.entries) {
            if(blueprint.key.length < 16){
              blueprint.value.updatedAt = DateTime.parse(timeSync);
              String newID = await firebaseBlueprintService.addBlueprint(blueprint.value);
              await updateBlueprintFirebaseID(db, blueprint.value, newID);
            }else{
              await firebaseBlueprintService.updateBlueprint(blueprint.key, blueprint.value);
            }
            if(blueprint.value.photoFilePath!=null){
              for(String path in blueprint.value.photoFilePath!){
                Directory appDocDir = await getApplicationSupportDirectory();
                databaseImageService.addBlueprintImageToFirebase(appDocDir.path, path);
              }
            }
          }
        }
        break;

      case "pdf":
      /// sync PDF to firebase
      /// Le fichier est initialement enregistré à deux endroits: dans /Documents/camion_appli/ et dans Firebase.
      /// S'il a été enregistré hors ligne, il est allé dans "getApplicationSupportDirectory()" au lieu de l'enregistrer dans Firebase.
      /// Et lors de la synchronisation, il devrait être enregistré.
        if(userId == null || user == null){
          print("no user or userId provided");
          break;
        }
        PdfService pdfService = PdfService();
        pdfService.uploadAllTemporaryPDFs(user, userId);
        break;

      default:
        throw "Invalid Table";
    }
  }

  /// Gère les conflits si un changement s'est produit dans les deux bases de données en même temps.
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
        if (shouldContinue == 'firebase') {
          await updateUser(dbOrTxn, firebaseData as MyUser, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateUser(dbOrTxn, localData as MyUser, firebaseKey);
        }
        break;

      case "camions":
      /// resolve Camion DB
        if (shouldContinue == 'firebase') {
          await updateCamion(dbOrTxn, firebaseData as Camion, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateCamion(dbOrTxn, localData as Camion, firebaseKey);
        }
        break;

      case "camionTypes":
      /// resolve Camion types DB
        if (shouldContinue == 'firebase') {
          await updateCamionType(dbOrTxn, firebaseData as CamionType, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateCamionType(dbOrTxn, localData as CamionType, firebaseKey);
        }
        break;

      case "companies":
      /// resolve Companies DB
        if (shouldContinue == 'firebase') {
          await updateCompany(dbOrTxn, firebaseData as Company, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateCompany(dbOrTxn, localData as Company, firebaseKey);
        }
        break;

      case "listOfLists":
      /// resolve LoL DB
        if (shouldContinue == 'firebase') {
          await updateList(dbOrTxn, firebaseData as ListOfLists, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateList(dbOrTxn, localData as ListOfLists, firebaseKey);
        }
        break;

      case "validateTasks":
      /// resolve Validated Tasks DB
        if (shouldContinue == 'firebase') {
          await updateTask(dbOrTxn, firebaseData as TaskChecklist, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateTask(dbOrTxn, localData as TaskChecklist, firebaseKey);
        }
        break;

      case "equipments":
      /// resolve Equipments DB
        if (shouldContinue == 'firebase') {
          await updateEquipment(dbOrTxn, firebaseData as Equipment, firebaseKey);
        } else if (shouldContinue == 'local') {
          await updateEquipment(dbOrTxn, localData as Equipment, firebaseKey);
        }
        break;

      case "blueprints":
      /// resolve Blueprints DB
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