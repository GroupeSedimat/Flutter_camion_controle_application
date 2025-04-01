import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/camion/camion.dart';

const String CAMION_COLLECTION_REF = "camion";

/// une classe fonctionnant sur la collection "camion" dans Firebase database
class DatabaseCamionService{
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _camionRef;

  DatabaseCamionService(){
    _camionRef = _firestore
        .collection(CAMION_COLLECTION_REF)
        .withConverter<Camion>(
        fromFirestore: (snapshots, _)=> Camion.fromJson(
          snapshots.data()!,
        ),
        toFirestore: (camion, _) => camion.toJson()
    );
  }

  Future<Map<String, Camion>> getAllCamions() async {
    try {
      final querySnapshot = await _camionRef.get();
      List snapshotList = querySnapshot.docs;
      Map<String, Camion> camions = {};

      for (var snapshotCamionItem in snapshotList) {
        camions[snapshotCamionItem.id] = snapshotCamionItem.data();
      }

      return _sortCamions(camions);
    } catch (e) {
      print('Error fetching all camions: $e');
      rethrow;
    }
  }

  Future<Map<String, Camion>> getAllCamionsSinceLastSync(String lastSync) async {
    Query query = _camionRef;
    query = query.where('updatedAt', isGreaterThan: lastSync);

    try {
      QuerySnapshot querySnapshot = await query.get();
      Map<String, Camion> camions = HashMap();
      for (var doc in querySnapshot.docs) {
        camions[doc.id] = doc.data() as Camion;
      }
      return camions;
    } catch (e) {
      print("Error fetching Camions since last update data: $e");
      rethrow;
    }
  }


  Future<Map<String, Camion>> getCompanyCamions(String companyID) async {
    try {
      final querySnapshot = await _camionRef.get();
      List snapshotList = querySnapshot.docs;
      Map<String, Camion> camions = HashMap();

      for (var snapshotCamionItem in snapshotList){
        if(snapshotCamionItem.data().company == companyID){
          camions.addAll({snapshotCamionItem.id: snapshotCamionItem.data()});
        }
      }
      var sortedKeys = camions.keys.toList(growable: false)
        ..sort((k1, k2) => camions[k1]!.name.compareTo(camions[k2]!.name));

      LinkedHashMap<String, Camion> sortedCamions = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => camions[k]!,
      );
      return sortedCamions;

    } catch (e) {
      print("Error getting listItems: $e");
      rethrow;
    }
  }

  Future<Map<String, Camion>> getCompanyCamionsSinceLastSync(String companyID, String lastSync) async {
    Query query = _camionRef;
    query = query.where('updatedAt', isGreaterThan: lastSync);

    try {
      QuerySnapshot querySnapshot = await query.get();
      List snapshotList = querySnapshot.docs;
      Map<String, Camion> camions = HashMap();

      for (var snapshotCamionItem in snapshotList){
        if(snapshotCamionItem.data().company == companyID){
          camions.addAll({snapshotCamionItem.id: snapshotCamionItem.data()});
        }
      }
      var sortedKeys = camions.keys.toList(growable: false)
        ..sort((k1, k2) => camions[k1]!.name.compareTo(camions[k2]!.name));

      LinkedHashMap<String, Camion> sortedCamions = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => camions[k]!,
      );
      return sortedCamions;

    } catch (e) {
      print("Error getting listItems: $e");
      rethrow;
    }
  }

  Future<Map<String, Camion>> getOneCamionSinceLastSync(String? camion, String lastSync) async {
    Query query = _camionRef;
    query = query.where('updatedAt', isGreaterThan: lastSync);

    if(camion == null){
      Map<String, Camion> sortedCamions = {};
      return sortedCamions;
    }
    try {
      QuerySnapshot querySnapshot = await _camionRef
        .where(FieldPath.documentId, isEqualTo: camion)
        .get();
      List snapshotList = querySnapshot.docs;
      Map<String, Camion> camions = HashMap();

      for (var snapshotCamionItem in snapshotList){
        camions.addAll({snapshotCamionItem.id: snapshotCamionItem.data()});
      }
      var sortedKeys = camions.keys.toList(growable: false)
        ..sort((k1, k2) => camions[k1]!.name.compareTo(camions[k2]!.name));

      LinkedHashMap<String, Camion> sortedCamions = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => camions[k]!,
      );
      return sortedCamions;

    } catch (e) {
      print("Error getting listItems: $e");
      rethrow;
    }
  }

  Future<Map<String, Camion>> getListCamionSinceLastSync(List<String> camions, String lastSync) async {
    Query query = _camionRef;
    query = query.where('updatedAt', isGreaterThan: lastSync);

    if (camions.isEmpty) {
      return {};
    }

    try {
      QuerySnapshot querySnapshot = await _camionRef
          .where(FieldPath.documentId, whereIn: camions)
          .get();

      Map<String, Camion> camionsMap = {};

      for (var snapshotCamionItem in querySnapshot.docs) {
        camionsMap[snapshotCamionItem.id] = snapshotCamionItem.data() as Camion;
      }

      var sortedKeys = camionsMap.keys.toList()
        ..sort((k1, k2) => camionsMap[k1]!.name.compareTo(camionsMap[k2]!.name));

      return LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => camionsMap[k]!,
      );

    } catch (e) {
      print("Error getting Camions: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCamionsPaginated({
    String? companyId,
    String? searchQuery,
    String? camionTypeId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
    String sortByField = 'name',
    bool isDescending = false,
  }) async {
    Query query = _camionRef;

    if (companyId != null && companyId.isNotEmpty) {
      query = query.where('company', isEqualTo: companyId);
    }

    if (camionTypeId != null && camionTypeId.isNotEmpty) {
      query = query.where('camionType', isEqualTo: camionTypeId);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
    }
    query = query.orderBy(sortByField, descending: isDescending);
    if(sortByField != "name"){
      query = query.orderBy("name", descending: isDescending);
    }
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    query = query.limit(limit);

    try {
      QuerySnapshot querySnapshot = await query.get();
      Map<String, Camion> camions = HashMap();
      for (var doc in querySnapshot.docs) {
        camions[doc.id] = doc.data() as Camion;
      }
      DocumentSnapshot? lastDoc = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
      return {
        'camions': camions,
        'lastDocument': lastDoc,
      };
    } catch (e) {
      print("Error fetching paginated data: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getCamions(){
    return _camionRef.snapshots();
  }

  Future<Camion?> getOneCamionWithID(String camionID) async {
    try {
      QuerySnapshot querySnapshot = await _camionRef
          .where(FieldPath.documentId, isEqualTo: camionID)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Camion?;
      } else {
        print("Camion with ID $camionID does not exist.");
        return null;
      }
    } catch (e) {
      print("Error fetching camion with ID $camionID: $e");
      rethrow;
    }
  }

  Future<String> addCamion(Camion camion) async {
    var returnAdd = await _camionRef.add(camion);
    return returnAdd.id;
  }

  Future<void> updateCamion(String camionID, Camion camion) async {
    final data = camion.toJson();
    if(camion.deletedAt == null){
      data['deletedAt'] = FieldValue.delete();
    }
    await _camionRef.doc(camionID).update(data);
  }

  void deleteCamion(String camionID){
    _camionRef.doc(camionID).delete();
  }

  Future<void> softDeleteCamion(String camionID) async {
    try{
      await _camionRef.doc(camionID).update({
        'deletedAt': DateTime.now().toIso8601String(),
      });
      print("Camion with ID $camionID not found for soft delete.");
    }catch(e){
      print("Error while trying soft deleting camion with ID $camionID: $e");
    }
  }

  LinkedHashMap<String, Camion> _sortCamions(Map<String, Camion> camions) {
    var sortedKeys = camions.keys.toList(growable: false)
      ..sort((k1, k2) {
        int companyCompare = camions[k1]!.company.compareTo(camions[k2]!.company);
        if (companyCompare != 0) return companyCompare;
        return camions[k1]!.name.compareTo(camions[k2]!.name);
      });

    return LinkedHashMap.fromIterable(sortedKeys, key: (k) => k, value: (k) => camions[k]!);
  }

}