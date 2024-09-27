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

  Future<MyUser> getCurrentUserData() async {
    if (userID != null) {
      DocumentSnapshot doc = await _userRef.doc(userID).get();
      return doc.data() as MyUser;
    } else {
      throw Exception("User not logged in");
    }
  }

  Stream<DocumentSnapshot> getOneUserWithID(){
    return _userRef.doc(userID).snapshots();
  }

  Future<MyUser> getUserData(String userID) async {
    DocumentSnapshot doc = await _userRef.doc(userID).get();
    return doc.data() as MyUser;
  }

  Future<void> deleteUser(String username) async {
    try {
      var userDoc = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (userDoc.docs.isNotEmpty) {
        await _firestore.collection('users').doc(userDoc.docs[0].id).delete();

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