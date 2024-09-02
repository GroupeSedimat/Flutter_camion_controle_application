// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/pdf/pdf_show_template.dart';
import 'package:flutter_application_1/services/user_service.dart';


class UserTile extends StatelessWidget {
  final Reference userRef;

  UserTile({required this.userRef});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return FutureBuilder<MyUser>(
      future: userService.getUserData(userRef.name),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text(userRef.name),
            subtitle: Text("Loading user data..."),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text(userRef.name),
            subtitle: Text("Error: ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          final userName = user.username;

          return FutureBuilder<ListResult>(
            future: userRef.listAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  title: Text(userName),
                  subtitle: Text("Loading documents..."),
                );
              } else if (snapshot.hasError) {
                return ListTile(
                  title: Text(userName),
                  subtitle: Text("Error: ${snapshot.error}"),
                );
              } else if (snapshot.hasData) {
                final docList = snapshot.data!.items;
                docList.sort((a, b) => b.name.compareTo(a.name));

                return ExpansionTile(
                  // leading: Icon(Icons.person, color: Colors.black, size: 50),
                  backgroundColor: Colors.lightBlueAccent,
                  collapsedBackgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Text(
                    userName,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  children: docList.map((docRef) {
                    return FutureBuilder<String>(
                      future: docRef.getDownloadURL(),
                      builder: (context, urlSnapshot) {
                        if (urlSnapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            title: Text(
                              docRef.name,
                            ),
                            subtitle: Text("Loading URL..."),
                          );
                        } else if (urlSnapshot.hasError) {
                          return ListTile(
                            title: Text(
                              docRef.name,
                            ),
                            subtitle: Text("Error: ${urlSnapshot.error}"),
                          );
                        } else if (urlSnapshot.hasData) {
                          return PDFShowTemplate(
                            fileName: docRef.name,
                            url: urlSnapshot.data!,
                            userData: user,
                          );
                        } else {
                          return ListTile(
                            title: Text(
                              docRef.name,
                            ),
                            subtitle: Text("No URL available"),
                          );
                        }
                      },
                    );
                  }).toList(),
                );
              } else {
                return ListTile(
                  title: Text(userName),
                  subtitle: Text("No documents available"),
                );
              }
            },
          );
        } else {
          return ListTile(
            title: Text(userRef.name),
            subtitle: Text("No user data available"),
          );
        }
      },
    );
  }
}