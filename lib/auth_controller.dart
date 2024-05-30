  // ignore_for_file: prefer_const_constructors, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';
import 'package:flutter_application_1/welcome_page.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rx<User?> _user;
  FirebaseAuth auth = FirebaseAuth.instance;
  late String _username;
  late String _role;

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
          _username = documentSnapshot.get('username');
          _role = documentSnapshot.get('role');

          print( "username : $_username, role: $_role");
          // Get.offAll(() => WelcomePage(username: username, role: role));
          Get.offAll(() => WelcomePage());
        } else {
          print('Document does not exist on the database');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    }
  }

  Future<void> register(String email, String username, String dob, String password, String confirmPassword, String role) async {
    try {
      print('Password: $password, Confirm Password: $confirmPassword');
      if (password != confirmPassword) {
        throw "Les mots de passe ne correspondent pas";
      }
      if (role != 'user' && role != 'admin'){
        throw "Role invalide";
      }
      int birthYear = DateTime.parse(dob).year;
      int currentYear = DateTime.now().year;
      int minimumBirthYear = currentYear - 14; // Remplacez 14 par l'âge minimum requis

      if (birthYear > minimumBirthYear) {
        throw "you should at least be 14 before creating an account";
      }

      await auth.createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).set({
        'username': username,
        'dob': dob,
        'role': role,
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
    Get.offAll(() => LoginPage());
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

  String? getCurrentUserUID() {
    return _user.value?.uid; // Renvoie l'UID de l'utilisateur actuel ou null si l'utilisateur n'est pas connecté
  }

  String getUserName(){
    return _username;
  }

  String getRole(){
    return _role;
  }

}
