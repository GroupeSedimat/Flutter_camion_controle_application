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

  Future<List<CamionType>> getAllCamionTypes() async {
    try {
      final querySnapshot = await _camionTypeRef.get();

      List snapshotList = querySnapshot.docs;
      final camionTypes = <CamionType>[];
      for (var snapshotCamionTypeItem in snapshotList){
        camionTypes.add(snapshotCamionTypeItem.data());
      }
      camionTypes.sort((a, b) => a.name.compareTo(b.name));
      return camionTypes;

    } catch (e) {
      print("Error getting listItems: $e");
      rethrow; // Gérez l’erreur le cas échéant.
    }
  }

  Stream<QuerySnapshot> getCamionTypes(){
    return _camionTypeRef.snapshots();
  }

  Stream<DocumentSnapshot> getOneCamionTypeWithID(String camionTypeID){
    return _camionTypeRef.doc(camionTypeID).snapshots();
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