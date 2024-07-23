// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/admin/UserManagementPage.dart';
import 'package:flutter_application_1/pages/admin/admin_page.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/user/messaging_page.dart';
import 'package:flutter_application_1/pages/company/company_list.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_view.dart';
import 'package:flutter_application_1/pages/pdf/pdf_show_list.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:flutter_application_1/pages/welcome_page.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:get/get.dart';

class MenuWidget extends StatelessWidget {
  String username = "";
  String role = "";
  MenuWidget({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<MyUser>(
    future: UserService().getCurrentUserData(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      } else if (snapshot.hasData) {
        final MyUser userData = snapshot.data!;
        username = userData.username;
        role = userData.role;
        return Drawer(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget> [
                buildHeader(context),
                buildMenuItems(context),
              ],
            ),
          ),
        );
      } else {
        return const Center(child: Text("No data available"));
      }
    },
  );

  Widget buildHeader(BuildContext context) => Material(
    color: Colors.deepPurple,
    child: InkWell(
      onTap: () {
        Navigator.pop(context);
        Get.to(() => WelcomePage());
      },
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: 24,
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage("assets/images/836.jpg"),
            ),
            const SizedBox(height: 12),
            Text(
              username,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.black,
              ),
            ),
            Text(
              'Role: $role',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget buildMenuItems(BuildContext context) => Wrap(
    runSpacing: 16, // vertical spacing
    children: [
      /**   ListTile(
          leading: Icon(Icons.slideshow, color: Colors.purple),
          title: Text('Voir mes informations'),
          onTap: () {
          Navigator.pop(context);
          Get.to(() => ProfileInfoPage(
          username: 'NomUtilisateur',
          dob: 'DateDeNaissance',
          email: 'adresse@example.com',
          ));
          },
          ), */

      // ListTile(
      //   leading: const Icon(Icons.data_exploration, color: Colors.purple),
      //   title: const Text('Get datas'),
      //   onTap: () {
      //     Navigator.pop(context);
      //     Get.to(() => const LoadingData());
      //   },
      // ),
      ListTile(
        leading: const Icon(Icons.view_list, color: Colors.deepPurple),
        title: const Text('Go to checklist'),
        onTap: () {
          Navigator.pop(context);
          Get.to(() => const CheckList());
        },
      ),
      if (role == 'user')
      ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.deepPurple),
        title: const Text('Go to PDF list'),
        onTap: () {
          Navigator.pop(context);
          Get.to(() => const PDFShowList());
        },
      ),
      if (role == 'admin' || role == 'superadmin' )
      ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.deepPurple),
        title: const Text('Go to admins PDF list new'),
        onTap: () {
          Navigator.pop(context);
          Get.to(() => AdminPdfListView());
        },
      ),
      if (role == 'admin' || role == 'superadmin' )
      ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.deepPurple),
        title: const Text('Go to admins Company list'),
        onTap: () {
          Navigator.pop(context);
          Get.to(() => CompanyList());
        },
      ),

      const Divider(color: Colors.deepPurple),

      /*ListTile(
        leading: const Icon(Icons.edit, color: Colors.deepPurple),
        title: const Text('Modifier vos informations'),
        onTap: () {
          Navigator.pop(context);
          Get.to(() => ModifyProfilePage());
        },
      ),*/
      ListTile(
        leading: const Icon(Icons.mail, color: Colors.deepPurple),
        title: const Text('Messagerie'),
        onTap: () {
          Navigator.pop(context);
          Get.to(() =>  MessagingPage ());
        },
      ),
      /*ListTile(
        leading: const Icon(Icons.shopping_cart, color: Colors.deepPurple),
        title: const Text('Accéder au shop'),
        onTap: () {
          Navigator.pop(context);
        },
      ),*/
      
      if (role == 'admin')
        ListTile(
          leading: const Icon(Icons.manage_accounts, color: Colors.purple),
          title: const Text('Gestion des utilisateurs'),
          onTap: () {
            Navigator.pop(context);
            Get.to(() => UserManagementPage());
          },
        ),
      if (role == 'superadmin' )
        ListTile(
          leading: const Icon(Icons.man_3_outlined, color: Colors.deepPurple),
          title: const Text('Page du super admin'),
          onTap: () {
            Navigator.pop(context);
            Get.to(() => AdminPage(userRole: UserRole.superadmin,));
          },
        ),

    ]
  );
}