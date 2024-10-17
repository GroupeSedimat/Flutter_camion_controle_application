import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/equipment/equipment.dart';

const String EQUIPMENT_COLLECTION_REF = "equipment";

class DatabaseEquipmentService{
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _equipmentRef;

  DatabaseEquipmentService(){
    _equipmentRef = _firestore
        .collection(EQUIPMENT_COLLECTION_REF)
        .withConverter<Equipment>(
        fromFirestore: (snapshots, _)=> Equipment.fromJson(
          snapshots.data()!,
        ),
        toFirestore: (equipment, _) => equipment.toJson()
    );
  }

  Future<Map<String, Equipment>> getAllEquipments() async {
    try {
      final querySnapshot = await _equipmentRef.get();
      List snapshotList = querySnapshot.docs;
      Map<String, Equipment> equipments = HashMap();

      for (var snapshotEquipmentItem in snapshotList){
        equipments.addAll({snapshotEquipmentItem.id: snapshotEquipmentItem.data()});
      }
      var sortedKeys = equipments.keys.toList(growable: false)
        ..sort((k1, k2) => equipments[k1]!.name.compareTo(equipments[k2]!.name));

      LinkedHashMap<String, Equipment> sortedEquipments = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => equipments[k]!,
      );
      return sortedEquipments;

    } catch (e) {
      print("Error getting listItems: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getEquipments(){
    return _equipmentRef.snapshots();
  }

  Stream<DocumentSnapshot> getOneEquipmentWithID(String equipmentID){
    return _equipmentRef.doc(equipmentID).snapshots();
  }

  void addEquipment(Equipment equipment) async {
    _equipmentRef.add(equipment);
  }

  void updateEquipment(String equipmentID, Equipment equipment){
    _equipmentRef.doc(equipmentID).update(equipment.toJson());
  }

  void deleteEquipment(String equipmentID){
    _equipmentRef.doc(equipmentID).delete();
  }

}