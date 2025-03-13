import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/admin_page.dart';
import 'package:flutter_application_1/models/user/user_role.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
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

  _initialScreen(User? user) async {
    if (user == null) {
      try {
        await DatabaseHelper().clearTables([
          "users",
          "updates",
          "camions",
          "camionTypes",
          "equipments",
          "companies",
          "listOfLists",
          "blueprints",
          "validateTasks"
        ]);

        Get.offAll(() => LoginPage());
      } catch (e) {
        print("Error clearing tables: $e");
      }
    } else {
      try {
        FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
            if (documentSnapshot.exists) {
              _username = documentSnapshot.get('username');
              _role = documentSnapshot.get('role');
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
      } catch (error) {
        print('Error getting document: $error');
      }
    }
  }

  Future<void> register(String email, String username, String name, String firstname, String password, String confirmPassword, String role, String company) async {
  try {
    if (password != confirmPassword) {
      
      Get.snackbar(
        "les mots de passe ne correspondent pas", 
        "Veuillez modifier.", 
        backgroundColor: Colors.orange, 
        snackPosition: SnackPosition.BOTTOM, 
        duration: Duration(seconds: 5), 
      );
      
    }

    if (!isValidPassword(password)) {
      Get.snackbar(
        "Le mot de passe doit contenir au moins 8 caractères, y compris une majuscule, une minuscule, un chiffre et un caractère spécial.", 
        "Veuillez en choisir un autre.", 
        backgroundColor: Colors.orange, 
        snackPosition: SnackPosition.BOTTOM, 
        duration: Duration(seconds: 5), 
      );
      return;
    }

    if (role != 'user' && role != 'admin' && role != 'superadmin') {
      throw "Role invalide";
    }
   
    var usersWithSameUsername = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (usersWithSameUsername.docs.isNotEmpty) {
      Get.snackbar(
        "Nom d'utilisateur déjà pris", 
        "Veuillez en choisir un autre.", 
        backgroundColor: Colors.orange, 
        snackPosition: SnackPosition.BOTTOM, 
        duration: Duration(seconds: 5), 
      );
      return;
      
    }
    await auth.createUserWithEmailAndPassword(email: email, password: password);

    await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).set({
      'username': username,
      'name': name,
      'firstname': firstname,
      'email': email,
      'role': role,
      'company': company,
      'isApproved': false,
      'apresFormation': false,
      'apresFormationDoc': "",
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
//augmentation securité mot de passe pour inscription
bool isValidPassword(String password) {
  // La longueur du mot de passe doit être d'au moins 8 caractères
  if (password.length < 8) return false;

  // Doit contenir au moins une majuscule
  if (!RegExp(r'[A-Z]').hasMatch(password)) return false;

  // Doit contenir au moins une minuscule
  if (!RegExp(r'[a-z]').hasMatch(password)) return false;

  // Doit contenir au moins un chiffre
  if (!RegExp(r'\d').hasMatch(password)) return false;

  // Doit contenir au moins un caractère spécial
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;

  return true;
}


Future<void> login(String identifier, String password) async {
  try {
    UserCredential userCredential;

    // Vérifier si l'identifiant est un e-mail ou un nom d'utilisateur
    if (identifier.contains('@')) {
      // Si c'est un e-mail, authentifier directement avec FirebaseAuth
      userCredential = await auth.signInWithEmailAndPassword(email: identifier, password: password);
    } else {
      // Si c'est un nom d'utilisateur, rechercher l'utilisateur dans Firestore
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: identifier)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // Récupérer l'e-mail correspondant
        String email = userSnapshot.docs.first.get('email');

        // Authentifier avec l'e-mail récupéré
        userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        Get.snackbar(
          "Erreur",
          "Nom d'utilisateur introuvable.",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    // Vérifier si l'utilisateur est super admin
    var currentUser = auth.currentUser;
    if (currentUser != null && await isSuperAdmin(currentUser.uid)) {
      Get.snackbar(
        "Connexion réussie",
        "Bienvenue ${currentUser.displayName ?? currentUser.email}",
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );
      // Get.offAll(() => AdminPage(userRole: UserRole.superadmin));
      return;
    }

    // Vérification des données utilisateur dans Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).get();
    if (userDoc.exists) {
      bool isApproved = userDoc.get('isApproved') ?? false;

      if (isApproved) {
        Get.snackbar(
          "Connexion réussie",
          "Bienvenue ${userDoc.get('username')}",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
        // await Get.offAll(() => WelcomePage());
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
    // Gestion des erreurs
    Get.snackbar(
      "Erreur de connexion",
      e is FirebaseAuthException ? e.message ?? "Erreur inconnue" : "Erreur lors de la connexion.",
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
        // 'dob': newDob,
        // 'email': newEmail,
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

  String getCurrentUserUID() {
    if (_user.value?.uid != null) {
      return _user.value!.uid;
    } else {
      throw Exception("User not logged in");
    }
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
