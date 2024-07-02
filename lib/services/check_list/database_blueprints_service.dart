// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/checklist/blueprint.dart';

const String BLUEPRINT_COLLECTION_REF = "blueprint";

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

  Stream<QuerySnapshot> getBlueprints(){
    return _blueprintRef.snapshots();
  }

  Stream<DocumentSnapshot> getOneBlueprintWithID(String blueprintID){
    return _blueprintRef.doc(blueprintID).snapshots();
  }

  // Stream<QuerySnapshot> getBlueprintsOnList(int nrOfList) {
  //   return _blueprintRef
  //       .where('nrOfList', isEqualTo: nrOfList)
  //       .snapshots();
  // }

  void addBlueprint(Blueprint blueprint) async {
    _blueprintRef.add(blueprint);
  }

  void updateBlueprint(String blueprintID, Blueprint blueprint){
    _blueprintRef.doc(blueprintID).update(blueprint.toJson());
  }

  void deleteBlueprint(String blueprintID){
    _blueprintRef.doc(blueprintID).delete();
  }
}