import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';

const String BLUEPRINT_COLLECTION_REF = "blueprint";

/// une classe fonctionnant sur la collection "blueprint" dans Firebase database
class DatabaseBlueprintsService{
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _blueprintRef;

  DatabaseBlueprintsService(){
    _blueprintRef = _firestore
      .collection(BLUEPRINT_COLLECTION_REF)
      .withConverter<Blueprint>(
        fromFirestore: (snapshots, _)=> Blueprint.fromJson(
            snapshots.data()!,
          ),
        toFirestore: (blueprint, _) => blueprint.toJson()
    );
  }

  Future<Map<String, Blueprint>> getAllBlueprintsSinceLastSync(String lastSync) async {
    Query query = _blueprintRef;
    query = query.where('updatedAt', isGreaterThan: lastSync);

    try {
      QuerySnapshot querySnapshot = await query.get();
      Map<String, Blueprint> blueprints = HashMap();
      for (var doc in querySnapshot.docs) {
        blueprints[doc.id] = doc.data() as Blueprint;
      }
      return blueprints;
    } catch (e) {
      print("Error fetching Blueprints since last update data: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getBlueprints(){
    return _blueprintRef.snapshots();
  }

  Stream<DocumentSnapshot> getOneBlueprintWithID(String blueprintID){
    return _blueprintRef.doc(blueprintID).snapshots();
  }

  Future<String> addBlueprint(Blueprint blueprint) async {
    var returnAdd = await _blueprintRef.add(blueprint);
    return returnAdd.id;
  }

  Future<void> updateBlueprint(String blueprintID, Blueprint blueprint) async {
    final data = blueprint.toJson();
    if(blueprint.deletedAt == null){
      data['deletedAt'] = FieldValue.delete();
    }
    await _blueprintRef.doc(blueprintID).update(data);
  }

  void deleteBlueprint(String blueprintID){
    _blueprintRef.doc(blueprintID).delete();
  }
}