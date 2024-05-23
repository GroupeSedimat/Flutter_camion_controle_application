// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/login_page.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'welcome_page.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rx<User?> _user;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());
    ever(_user, _initialScreen);
  }

  _initialScreen(User? user) {
    if (user == null) {
      print("login page");
      Get.offAll(() => LoginPage());
    } else {
      print("User is authenticated: ${user.uid}");
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          String username = documentSnapshot.get('username');
          Get.offAll(() => WelcomePage(username: username));
        } else {
          print('Document does not exist on the database');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    }
  }

  Future<void> register(String email, String username, String dob, String password, String confirmPassword) async {
    try {
      print('Password: $password, Confirm Password: $confirmPassword');
      if (password != confirmPassword) {
        throw "Les mots de passe ne correspondent pas";
      }

      await auth.createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).set({
        'username': username,
        'dob': dob,
      });

      Get.offAll(() => LoginPage());
    } catch (e) {
      Get.snackbar(
        "Erreur lors de la création de compte",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar(
        "Erreur de connexion",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> logOut() async {
    await auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        "E-mail de réinitialisation envoyé",
        "Veuillez vérifier votre boîte de réception pour réinitialiser votre mot de passe.",
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAll(() => LoginPage());
    } catch (e) {
      Get.snackbar(
        "Erreur lors de l'envoi de l'e-mail",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateProfile(String newUsername, String newDob, String newEmail) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).update({
        'username': newUsername,
        'dob': newDob,
        'email': newEmail,
      });

      Get.snackbar(
        "Profil mis à jour",
        "Les modifications ont été enregistrées avec succès.",
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Erreur lors de la mise à jour du profil",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
