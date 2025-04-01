import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';

const String LIST_COLLECTION_REF = "listoflists";

/// une classe fonctionnant sur la collection "listoflists" dans Firebase database
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
      rethrow;
    }
  }

  Future<Map<String, ListOfLists>> getAllLOLSinceLastSync(String lastSync) async {
    Query query = _listRef;
    query = query.where('updatedAt', isGreaterThan: lastSync);

    try {
      QuerySnapshot querySnapshot = await query.get();
      Map<String, ListOfLists> lol = HashMap();
      for (var doc in querySnapshot.docs) {
        lol[doc.id] = doc.data() as ListOfLists;
      }
      return lol;
    } catch (e) {
      print("Error fetching ListOfLists since last update data: $e");
      rethrow;
    }
  }

  Future<Map<String, ListOfLists>> getAllListsWithId() async {
    try {
      final querySnapshot = await _listRef.get();
      List snapshotList = querySnapshot.docs;
      Map<String, ListOfLists> listOfLists = HashMap();

      for (var snapshotListOfListsItem in snapshotList){
        listOfLists.addAll({snapshotListOfListsItem.id: snapshotListOfListsItem.data()});
      }
      var sortedKeys = listOfLists.keys.toList(growable: false)
        ..sort((k1, k2) => listOfLists[k1]!.listName.compareTo(listOfLists[k2]!.listName));

      LinkedHashMap<String, ListOfLists> sortedLists = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => listOfLists[k]!,
      );
      return sortedLists;

    } catch (e) {
      print("Error getting listItems: $e");
      rethrow;
    }
  }

  Future<Map<String, ListOfLists>> getLoLsWithIds(String lastSync, List<String> lolIds) async {
    try {
      final querySnapshot = await _listRef
          .where('updatedAt', isGreaterThan: lastSync)
          .get();
      List snapshotList = querySnapshot.docs;
      Map<String, ListOfLists> listOfLists = HashMap();

      for (var snapshotListOfListsItem in snapshotList){
        if(lolIds.contains(snapshotListOfListsItem.id)){
          listOfLists.addAll({snapshotListOfListsItem.id: snapshotListOfListsItem.data()});
        }
      }
      var sortedKeys = listOfLists.keys.toList(growable: false)
        ..sort((k1, k2) => listOfLists[k1]!.listName.compareTo(listOfLists[k2]!.listName));

      LinkedHashMap<String, ListOfLists> sortedLists = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => listOfLists[k]!,
      );
      return sortedLists;

    } catch (e) {
      print("Error getting listItems: $e");
      rethrow;
    }
  }

  Future<List<ListOfLists>> getListsForCamionType(List<String> listIds) async {
    final listOfLists = <ListOfLists>[];
    try {
      final querySnapshot = await _listRef
          .where(FieldPath.documentId, whereIn: listIds)
          .get();
      for (var doc in querySnapshot.docs) {
        if (doc.exists) {
          listOfLists.add(doc.data() as ListOfLists);
        }
      }
      listOfLists.sort((a, b) => a.listNr.compareTo(b.listNr));
    } catch (e) {
      print("Error getting listItems for this camion type: $e");
    }
    return listOfLists;
  }

  Future<String> addList(ListOfLists listItem) async {
    var returnAdd = await _listRef.add(listItem);
    return returnAdd.id;
  }

  Future<void> updateList(String listItemID, ListOfLists listItem) async {
    final data = listItem.toJson();
    if(listItem.deletedAt == null){
      data['deletedAt'] = FieldValue.delete();
    }
    await _listRef.doc(listItemID).update(data);
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
    try {
      await _listRef.where("listNr", isEqualTo: listNr).get().then((value) => value.docs.forEach((element) async {
        await element.reference.delete();
      }));
    } catch (e) {
      print("Error deleting list item: $e");
      rethrow;
    }
  }

  Future<void> deleteListItemFuture(String listItemID) async {
    await _listRef.doc(listItemID).delete();
  }

  Future<int> findFirstFreeListNr() async {
    try {
      final querySnapshot = await _listRef.get();
      List<int> listNrs = [];

      for (var doc in querySnapshot.docs) {
        ListOfLists list = doc.data() as ListOfLists;
        listNrs.add(list.listNr);
      }
      listNrs.sort();

      int freeNr = 0;
      for (int nr in listNrs) {
        if (nr == freeNr) {
          freeNr++;
        } else {
          break;
        }
      }

      return freeNr;
    } catch (e) {
      print("Error finding first free list number: $e");
      rethrow;
    }
  }
}