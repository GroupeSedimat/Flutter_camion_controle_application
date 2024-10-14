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

  Future<List<Camion>> getAllCamions() async {
    try {
      final querySnapshot = await _camionRef.get();

      List snapshotList = querySnapshot.docs;
      final camions = <Camion>[];
      for (var snapshotCamionItem in snapshotList){
        camions.add(snapshotCamionItem.data());
      }
      camions.sort((a, b) => a.name.compareTo(b.name));
      return camions;

    } catch (e) {
      print("Error getting listItems: $e");
      rethrow; // Gérez l’erreur le cas échéant.
    }
  }

  Future<Map<String, Camion>> getCompanyCamions(companyID) async {
    try {
      final querySnapshot = await _camionRef.get();

      List snapshotList = querySnapshot.docs;
      final camions = <Camion>[];
      for (var snapshotCamionItem in snapshotList){
        if(snapshotCamionItem.data().company == companyID){
          camions.add(snapshotCamionItem.data());
        }
      }
      camions.sort((a, b) => a.name.compareTo(b.name));
      return camions;

    } catch (e) {
      print("Error getting listItems: $e");
      rethrow; // Gérez l’erreur le cas échéant.
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