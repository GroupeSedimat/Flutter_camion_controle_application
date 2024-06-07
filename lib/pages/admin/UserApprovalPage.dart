// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class UserApprovalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approuver les utilisateurs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('isApproved', isEqualTo: false).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var users = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, Object?>;
            return MyUser.fromJson(data);
          }).toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                title: Text(user.username),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        _approveUser(user);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        _disapproveUser(user);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _approveUser(MyUser user) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: user.username)
          .get();

      if (userDoc.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.docs[0].id)
            .update({'isApproved': true});

        Get.snackbar(
          "Utilisateur approuvé",
          "L'utilisateur ${user.username} a été approuvé.",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Erreur",
          "Utilisateur non trouvé.",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Erreur lors de l'approbation",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _disapproveUser(MyUser user) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: user.username)
          .get();

      if (userDoc.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.docs[0].id)
            .update({'isApproved': false});

        Get.snackbar(
          "Utilisateur désapprouvé",
          "L'utilisateur ${user.username} a été désapprouvé.",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Erreur",
          "Utilisateur non trouvé.",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Erreur lors de la désapprobation",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
