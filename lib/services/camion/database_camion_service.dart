import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/camion/camion.dart';

const String CAMION_COLLECTION_REF = "camion";

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

  LinkedHashMap<String, Camion> _sortCamions(Map<String, Camion> camions) {
    var sortedKeys = camions.keys.toList(growable: false)
      ..sort((k1, k2) {
        int companyCompare = camions[k1]!.company.compareTo(camions[k2]!.company);
        if (companyCompare != 0) return companyCompare;
        return camions[k1]!.name.compareTo(camions[k2]!.name);
      });

    return LinkedHashMap.fromIterable(sortedKeys, key: (k) => k, value: (k) => camions[k]!);
  }

  Future<Map<String, Camion>> getCompanyCamions(companyID) async {
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
      rethrow; // Gérez l’erreur le cas échéant.
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

    // print(query.parameters);

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

  Stream<DocumentSnapshot> getOneCamionWithID(String camionID){
    return _camionRef.doc(camionID).snapshots();
  }

  void addCamion(Camion camion) async {
    _camionRef.add(camion);
  }

  void updateCamion(String camionID, Camion camion){
    _camionRef.doc(camionID).update(camion.toJson());
  }

  void deleteCamion(String camionID){
    _camionRef.doc(camionID).delete();
  }

}