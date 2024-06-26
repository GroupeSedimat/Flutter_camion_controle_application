  // ignore_for_file: prefer_const_constructors, avoid_print
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/admin_page.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/pages/user/login_page.dart';
import 'package:flutter_application_1/pages/welcome_page.dart';

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
          //Get.offAll(() => WelcomePage());
           if (_role == 'superadmin') {
              Get.offAll(() => AdminPage(userRole: UserRole.superadmin,));
            } else {
              Get.offAll(() => WelcomePage());
            }
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
      if (role != 'user' && role != 'admin' && role != 'superadmin'){
        throw "Role invalide";
      }

      await auth.createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).set({
        'username': username,
        'dob': dob,
        'role': role,
        'isApproved': false,
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
    
    UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).get();
    var currentUser = auth.currentUser;
    if (currentUser != null && await isSuperAdmin(currentUser.uid)) {
      Get.snackbar(
        "Connexion réussie",
        "Bienvenue ${currentUser.displayName ?? currentUser.email}",
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAll(() => AdminPage(userRole: UserRole.superadmin,));
      return;
    }

    if (userDoc.exists) {
      bool isApproved = userDoc.get('isApproved') ?? false; 

      if (isApproved) {
        Get.snackbar(
          "Connexion réussie",
          "Bienvenue ${userDoc.get('username')}",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.offAll(() => WelcomePage());
      } else {
        Get.snackbar(
          "Compte non approuvé",
          "Votre compte doit être approuvé par un administrateur.",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.TOP,
        );
       await FirebaseAuth.instance.signOut();
      }
    } else {
      Get.snackbar(
        "Erreur",
        "Les informations de l'utilisateur sont introuvables.",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );

      await FirebaseAuth.instance.signOut();
    }
  } catch (e) {
        if (e is FirebaseAuthException) {
            Get.snackbar(
                "Erreur de connexion",
                e.message ?? "Erreur inconnue",
                backgroundColor: Colors.red,
                snackPosition: SnackPosition.BOTTOM,
            );
        } else if (e is FirebaseException) {
            Get.snackbar(
                "Erreur Firestore",
                e.message ?? "Erreur de permission Firestore",
                backgroundColor: Colors.red,
                snackPosition: SnackPosition.BOTTOM,
            );
        } else {
            Get.snackbar(
                "Erreur",
                "Votre compte est en attente de validation par un administrateur.",
                backgroundColor: Colors.yellow, 
                snackPosition: SnackPosition.BOTTOM,
            );
  } 
  } 
}


  Future<void> logOut() async {
    await auth.signOut();
    Get.offAll(() => LoginPage());
  }

  Future<void> resetPassword(String email) async {
    print("Reset password for: $email");
    if (email.isEmpty){
      Get.snackbar(
   "Erreur",
   "l'adresse e-mail est vide.",
   backgroundColor: Colors.red,
   snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
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
    return _user.value?.uid; 
  }

  String getUserName(){
    return _username;
  }

  String getRole(){
    return _role;
  }
  
Future<bool> isSuperAdmin(String userId) async {
  try {
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      var role = userDoc.get('role');
      return role == 'superadmin';
    }
  } catch (e) {
    print('Erreur lors de la vérification du rôle de superadministrateur: $e');
  }
  return false;
}


}
