import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String USERS_COLLECTION_REF = "users";

class UserService{
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _userRef;
  final String? userID = AuthController().auth.currentUser?.uid;

  UserService() {
    _userRef = _firestore.collection(USERS_COLLECTION_REF).withConverter<MyUser>(
      fromFirestore: (snapshots, _) => MyUser.fromJson(
        snapshots.data()!,
      ),
      toFirestore: (myuser, _) => myuser.toJson(),
    );
  }

  Stream<QuerySnapshot> getUsersData(){
    return _userRef.snapshots();
  }

  Future<Map<String,String>> getUsersIdAndName() async {
    Map<String, String> users = HashMap();
    try {
      final userSnapshot = await _userRef.get();
      for (var doc in userSnapshot.docs) {
        MyUser user = doc.data() as MyUser;
        users[doc.id] = user.username;
      }
    } catch (error) {
      print("Error retrieving Users list: $error");
    }
    return users;
  }

  Future<Map<String,MyUser>> getAllUsersData() async {
    Map<String, MyUser> users = HashMap();
    try {
      final userSnapshot = await _userRef.get();
      for (var doc in userSnapshot.docs) {
        MyUser user = doc.data() as MyUser;
        users[doc.id] = user;
      }
    } catch (error) {
      print("Error retrieving Users list: $error");
    }
    return users;
  }

  Future<Map<String,MyUser>> getAllUsersDataSinceLastSync(String lastSync) async {
    Map<String, MyUser> users = HashMap();
    Query query = _userRef;
    query = query.where('updatedAt', isGreaterThan: lastSync);
    try {
      QuerySnapshot querySnapshot = await query.get();
      for (var doc in querySnapshot.docs) {
        MyUser user = doc.data() as MyUser;
        users[doc.id] = user;
      }
    } catch (error) {
      print("Error retrieving Users list: $error");
    }
    return users;
  }

  Future<Map<String,MyUser>> getCompanyUsersDataSinceLastSync(String lastSync, String companyName) async {
    Map<String, MyUser> users = HashMap();
    Query query = _userRef;
    query = query.where('updatedAt', isGreaterThan: lastSync);
    query = query.where('company', isEqualTo: companyName);
    try {
      QuerySnapshot querySnapshot = await query.get();
      for (var doc in querySnapshot.docs) {
        MyUser user = doc.data() as MyUser;
        users[doc.id] = user;
      }
    } catch (error) {
      print("Error retrieving Users list: $error");
    }
    return users;
  }

  Future<Map<String,MyUser>> getCurrentUserMapSinceLastSync(String lastSync, String userId) async {
    Map<String, MyUser> users = HashMap();
    try {
      print(" ✳ $userId");
      DocumentSnapshot documentSnapshot = await _userRef.doc(userId).get();
      MyUser user = documentSnapshot.data() as MyUser;
      users[documentSnapshot.id] = user;
      print(" 💻 ${user.role} ${user.name}");
    } catch (error) {
      print("Error retrieving Users list: $error");
    }
    return users;
  }

  Future<MyUser> getCurrentUserData() async {
      DocumentSnapshot doc = await _userRef.doc(userID).get();
      return doc.data() as MyUser;
  }

  Stream<DocumentSnapshot> getOneUserWithID(String userId){
    return _userRef.doc(userId).snapshots();
  }

  Future<MyUser> getUserData(String userId) async {
    DocumentSnapshot doc = await _userRef.doc(userId).get();
    return doc.data() as MyUser;
  }

  Future<void> updateUser(String userId, MyUser user) async {
    final data = user.toJson();
    if(user.deletedAt == null){
      data['deletedAt'] = FieldValue.delete();
    }
    await _userRef.doc(userId).update(data);
  }


  Future<void> deleteUser(String username) async {
    try {
      var userDoc = await _firestore
          .collection(USERS_COLLECTION_REF)
          .where('username', isEqualTo: username)
          .get();

      if (userDoc.docs.isNotEmpty) {
        await _firestore.collection(USERS_COLLECTION_REF).doc(userDoc.docs[0].id).delete();

        Get.snackbar(
          "User deleted",
          "User has been deleted successfully.",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Error!",
          "User not found.",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error while deleting",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> confirmDeleteUser(BuildContext context, String username) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDelete),
          content: Text(AppLocalizations.of(context)!.confirmDeleteText),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.no),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yes),
              onPressed: () {
                Navigator.of(context).pop();
                deleteUser(username);
              },
            ),
          ],
        );
      },
    );
  }
}