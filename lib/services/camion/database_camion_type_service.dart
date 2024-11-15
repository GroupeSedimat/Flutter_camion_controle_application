import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';

const String CAMION_TYPE_COLLECTION_REF = "camion_type";

class DatabaseCamionTypeService{
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _camionTypeRef;

  DatabaseCamionTypeService(){
    _camionTypeRef = _firestore
      .collection(CAMION_TYPE_COLLECTION_REF)
      .withConverter<CamionType>(
        fromFirestore: (snapshots, _)=> CamionType.fromJson(
          snapshots.data()!,
        ),
      toFirestore: (camionType, _) => camionType.toJson()
    );
  }

  Future<Map<String, CamionType>> getAllCamionTypes() async {
    try {
      final querySnapshot = await _camionTypeRef.get();
      List snapshotList = querySnapshot.docs;
      Map<String, CamionType> camionType = HashMap();

      for (var snapshotCamionItem in snapshotList){
        camionType.addAll({snapshotCamionItem.id: snapshotCamionItem.data()});
      }
      var sortedKeys = camionType.keys.toList(growable: false)
        ..sort((k1, k2) => camionType[k1]!.name.compareTo(camionType[k2]!.name));

      LinkedHashMap<String, CamionType> sortedCamions = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => camionType[k]!,
      );
      // camions.sort((a, b) => a.name.compareTo(b.name));
      return sortedCamions;

    } catch (e) {
      print("Error getting listItems: $e");
      rethrow; // Gérez l’erreur le cas échéant.
    }
  }

  Future<Map<String, String>> getTypesIdAndName() async {
    try {
      final querySnapshot = await _camionTypeRef.get();
      List snapshotList = querySnapshot.docs;
      Map<String, String> camionType = HashMap();

      for (var snapshotCamionItem in snapshotList){
        camionType.addAll({snapshotCamionItem.id: snapshotCamionItem.data().name});
      }
      var sortedKeys = camionType.keys.toList(growable: false)
        ..sort((k1, k2) => camionType[k1]!.compareTo(camionType[k2]!));

      LinkedHashMap<String, String> sortedCamions = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => camionType[k]!,
      );
      return sortedCamions;

    } catch (e) {
      print("Error getting listItems: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getCamionTypes(){
    return _camionTypeRef.snapshots();
  }

  Future<CamionType?> getOneCamionTypeWithID(String camionTypeID) async {
    try {
      QuerySnapshot querySnapshot = await _camionTypeRef
          .where(FieldPath.documentId, isEqualTo: camionTypeID)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as CamionType?;
      } else {
        print("Camion with ID $camionTypeID does not exist.");
        return null;
      }
    } catch (e) {
      print("Error fetching camion with ID $camionTypeID: $e");
      rethrow;
    }
  }

  void addCamionType(CamionType camionType) async {
    _camionTypeRef.add(camionType);
  }

  void updateCamionType(String camionTypeID, CamionType camionType){
    _camionTypeRef.doc(camionTypeID).update(camionType.toJson());
  }

  void deleteCamionType(String camionTypeID){
    _camionTypeRef.doc(camionTypeID).delete();
  }

}