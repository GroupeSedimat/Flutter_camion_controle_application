// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_controller.dart';

class ResetPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réinitialiser le mot de passe'),
        backgroundColor:  Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
           color: Colors.white,
          ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 10.0,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Réinitialiser le mot de passe',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color:  Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color:  Theme.of(context).primaryColor,),
                        labelText: 'Adresse e-mail',
                        labelStyle: TextStyle(color:  Theme.of(context).primaryColor,),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color:  Theme.of(context).primaryColor,),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color:  Theme.of(context).primaryColor,),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color:  Theme.of(context).primaryColor,),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        AuthController.instance
                            .resetPassword(emailController.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 15.0),
                      ),
                      child: Text(
                        'Envoyer l\'e-mail de réinitialisation',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
