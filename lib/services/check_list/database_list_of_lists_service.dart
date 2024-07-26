import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';

const String LIST_COLLECTION_REF = "listoflists";

class DatabaseListOfListsService{
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _listRef;

  DatabaseListOfListsService(){
    _listRef = _firestore
        .collection(LIST_COLLECTION_REF)
        .withConverter<ListOfLists>(
        fromFirestore: (snapshots, _)=> ListOfLists.fromJson(
          snapshots.data()!,
        ),
        toFirestore: (list, _) => list.toJson()
    );
  }

  Future<List<ListOfLists>> getAllLists() async {
    try {
      final querySnapshot = await _listRef.get();

      List snapshotList = querySnapshot.docs;
      final listOfList = <ListOfLists>[];
      for (var snapshotListItem in snapshotList){
        listOfList.add(snapshotListItem.data());
      }
      listOfList.sort((a, b) => a.listNr.compareTo(b.listNr));
      return listOfList;

    } catch (e) {
      print("Error getting listItems: $e");
      rethrow; // Gérez l’erreur le cas échéant.
    }
  }


  Future<List<ListOfLists>> getListsWithType(String type) async {
    final listOfList = <ListOfLists>[];
    try {
      final querySnapshot = await _firestore
          .collection(LIST_COLLECTION_REF)
          .where("types", arrayContains: type)
          .get();
      List snapshotList = querySnapshot.docs;
      if (snapshotList.isNotEmpty) {
        for (var snapshotListItem in snapshotList) {
          listOfList.add(ListOfLists.fromJson(snapshotListItem.data()));
        }
      }
      listOfList.sort((a, b) => a.listNr.compareTo(b.listNr));
    } catch (error) {
      // Gérez l’erreur
      print("Error retrieving task: $error");
    }
    return listOfList;
  }

  Future<void> addList(ListOfLists listItem) async {
    _listRef.add(listItem);
  }

  void updateList(String listItemID, ListOfLists listItem){
    _listRef.doc(listItemID).update(listItem.toJson());
  }

  Future<void> updateListItemByListNr(int listNr, ListOfLists listItem) async {
    await _listRef.where("listNr", isEqualTo: listNr).get().then((value) => value.docs.forEach((element) async {
      await element.reference.update(listItem.toJson());
    }));
  }

  void deleteListItem(String listItemID){
    _listRef.doc(listItemID).delete();
  }
  
  Future<void> deleteListItemByListNr(int listNr) async {
    await _listRef.where("listNr", isEqualTo: listNr).get().then((value) => value.docs.forEach((element) async {
      await element.reference.delete();
    }));
  }

  Future<void> deleteListItemFuture(String listItemID) async {
    print("Delete listItem with id: $listItemID");
    await _listRef.doc(listItemID).delete();
  }

}