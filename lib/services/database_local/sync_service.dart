import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/services/camion/database_camion_service.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local/update_tables.dart';

class SyncService {
  final DatabaseHelper localDb;
  final DatabaseCamionService firebaseCamionService;

  SyncService(this.localDb, this.firebaseCamionService);

  Future<void> syncFromFirebase() async {
    final db = await localDb.database;

    /// sync Camion DB
    final Map<String, Camion> firebaseCamions = await firebaseCamionService.getAllCamions();
    final Map<String, Camion>? localCamions = await getAllCamions(db);

    for (var firebaseCamion in firebaseCamions.entries) {
      final Camion? localCamion = localCamions?[firebaseCamion.key];
      if (localCamion == null || firebaseCamion.value.updatedAt.isAfter(localCamion.updatedAt)) {
        await insertCamion(await localDb.database, firebaseCamion.value, firebaseCamion.key);
      }
    }
  }

  Future<void> syncToFirebase() async {
    final Map<String, Camion>? localCamions = await getAllCamions(await localDb.database);
    for (var camion in localCamions!.entries) {
      await firebaseCamionService.updateCamion(camion.key, camion.value);
      await markCamionAsSynced(await localDb.database, camion.key);
    }
  }

  Future<void> fullSync() async {
    await syncFromFirebase();
    await syncToFirebase();
  }

  Future<void> showConflictDialog(
      BuildContext context,
      String firebaseData,
      String localData,
      Function onFirebaseVersion,
      Function onLocalVersion,
      Function onCreateNew,
      Function onCancel
      ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Data conflict!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Firebase: $firebaseData'),
              Text('Local: $localData'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                onFirebaseVersion();
                Navigator.of(context).pop();
              },
              child: const Text('Merge, use Firebase data'),
            ),
            TextButton(
              onPressed: () {
                onLocalVersion();
                Navigator.of(context).pop();
              },
              child: const Text('Merge, use local data'),
            ),
            TextButton(
              onPressed: () {
                onCreateNew();
                Navigator.of(context).pop();
              },
              child: const Text('Make new '),
            ),
            TextButton(
              onPressed: () {
                onCancel();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}