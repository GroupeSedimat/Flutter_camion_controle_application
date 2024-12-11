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

  Future<Map<String, String>> getAllEquipmentsKeyAndName() async {
    try {
      final querySnapshot = await _equipmentRef.get();
      List snapshotList = querySnapshot.docs;
      Map<String, String> equipments = HashMap();

      for (var snapshotEquipmentItem in snapshotList){
        var snapshotData = snapshotEquipmentItem.data() as Equipment;
        equipments.addAll({snapshotEquipmentItem.id: snapshotData.name});
      }
      var sortedKeys = equipments.keys.toList(growable: false)
        ..sort((k1, k2) => equipments[k1]!.compareTo(equipments[k2]!));

      LinkedHashMap<String, String> sortedEquipments = LinkedHashMap.fromIterable(
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

  Future<Map<String, Equipment>> getAllEquipmentsSinceLastSync(String lastSync) async {
    Query query = _equipmentRef;
    query = query.where('updatedAt', isGreaterThan: lastSync);

    try {
      QuerySnapshot querySnapshot = await query.get();
      Map<String, Equipment> equipment = HashMap();
      for (var doc in querySnapshot.docs) {
        equipment[doc.id] = doc.data() as Equipment;
      }
      return equipment;
    } catch (e) {
      print("Error fetching Equipments since last update data: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getEquipments(){
    return _equipmentRef.snapshots();
  }

  Stream<DocumentSnapshot> getOneEquipmentWithID(String equipmentID){
    return _equipmentRef.doc(equipmentID).snapshots();
  }

  Future<String> addEquipment(Equipment equipment) async {
    var returnAdd = await _equipmentRef.add(equipment);
    print("------------- ---------- Add equipment: ${returnAdd.id}");
    return returnAdd.id;
  }

  Future<void> updateEquipment(String equipmentID, Equipment equipment) async {
    _equipmentRef.doc(equipmentID).update(equipment.toJson());
  }

  void deleteEquipment(String equipmentID){
    _equipmentRef.doc(equipmentID).delete();
  }

}