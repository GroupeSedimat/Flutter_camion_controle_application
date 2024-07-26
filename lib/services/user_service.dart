// ignore_for_file: constant_identifier_names
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/models/user/my_user.dart';

const String USERS_COLLECTION_REF = "users";

class UserService{
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _userRef;
  final User? user = AuthController().auth.currentUser;
  final String? userID = AuthController().auth.currentUser?.uid;

  UserService(){
    _userRef = _firestore.collection(USERS_COLLECTION_REF)
        .withConverter<MyUser>(
        fromFirestore: (snapshots, _)=> MyUser.fromJson(
          snapshots.data()!,
        ),
        toFirestore: (myuser, _) => myuser.toJson()
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
      // Gérez l’erreur
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

}