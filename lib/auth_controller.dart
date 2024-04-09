// ignore_for_file: prefer_const_constructors, unused_element, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/login_page.dart';
import 'package:get/get.dart';

import 'welcome_page.dart';

class AuthController extends GetxController{
  //AuthController.intance..
  static AuthController instance = Get.find();
  //email, password, name...
  late Rx<User?> _user;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override

  void onReady(){
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    // our user will be notified
    _user.bindStream(auth.userChanges());
    ever(_user, _initialScreen);
  }
  _initialScreen(User? user){
    if(user==null){
      print("login page");
      Get.offAll(()=>LoginPage());
    }else{
      Get.offAll(()=>WelcomePage(email:user.email!));
    }
  }
Future<void> register(String email, password) async {
  try{
   await auth.createUserWithEmailAndPassword(email: email, password: password);
  }catch(e){
    Get.snackbar("about user", "user message",
    backgroundColor: Colors.redAccent,
    snackPosition: SnackPosition.BOTTOM,
      titleText: Text(
        "account creation failed",
        style: TextStyle(
          color: Colors.white
        ),
      ),
      messageText: Text(
        e.toString(),
          style: TextStyle(
            color: Colors.white
          )
      )
    );
  }
}
Future<void> login(String email, password) async {
  try{
   await auth.signInWithEmailAndPassword(email: email, password: password);
  }catch(e){
    Get.snackbar("about login", "login message",
    backgroundColor: Colors.redAccent,
    snackPosition: SnackPosition.BOTTOM,
      titleText: Text(
        "login failed",
        style: TextStyle(
          color: Colors.white
        ),
      ),
      messageText: Text(
        e.toString(),
          style: TextStyle(
            color: Colors.white
          )
      )
    );
  }
}
Future<void> logOut() async {
  await auth.signOut();
}
}