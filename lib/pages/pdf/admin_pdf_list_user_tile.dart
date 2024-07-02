// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/pdf/pdf_download.dart';
import 'package:flutter_application_1/pages/pdf/pdf_open.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:intl/intl.dart';

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
          final userName = user.username; // Assuming MyUser has a 'name' field

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
                return ExpansionTile(
                  title: Text(userName),
                  children: docList.map((docRef) {
                    return FutureBuilder<String>(
                      future: docRef.getDownloadURL(),
                      builder: (context, urlSnapshot) {
                        if (urlSnapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            title: Text(docRef.name),
                            subtitle: Text("Loading URL..."),
                          );
                        } else if (urlSnapshot.hasError) {
                          return ListTile(
                            title: Text(docRef.name),
                            subtitle: Text("Error: ${urlSnapshot.error}"),
                          );
                        } else if (urlSnapshot.hasData) {
                          int timestamp = int.parse(docRef.name);
                          DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                          String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
                          return ListTile(
                            title: Text(formattedDate),
                            // subtitle: Text(urlSnapshot.data!),
                            subtitle: Wrap(
                              alignment: WrapAlignment.spaceEvenly,
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    PDFOpen open = PDFOpen(url: urlSnapshot.data!);
                                    await open.openPDF();
                                  },
                                  label: const Text('Open PDF'),
                                  icon: const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    //Save PDF on url: urlSnapshot.data!).downloadFile() with name: "$userName.$timestamp"
                                    PdfDownload(name: "$userName.$timestamp", url: urlSnapshot.data!).downloadFile();
                                    showDialog(context: context, builder: (context)=>AlertDialog(
                                      title: const Text('PDF downloaded'),
                                      content: Text('Your PDF file has been saved under the name: $userName.$timestamp.pdf'),
                                      actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Ok'))],
                                    ));

                                  },
                                  label: const Text('Download PDF'),
                                  icon: const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return ListTile(
                            title: Text(docRef.name),
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