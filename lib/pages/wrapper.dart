import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/user/login_page.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/pages/checklist/diagrams.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {

    final user = AuthController().auth.currentUser;
    if(user==null){
      return const LoginPage();
    }else {
      return const Diagrams();
    }
  }
}
