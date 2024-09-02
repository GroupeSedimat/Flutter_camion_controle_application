// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/admin/UserManagementAdmin.dart';
import 'package:flutter_application_1/pages/admin/admin_page.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/checklist/lol_control_page.dart';
import 'package:flutter_application_1/pages/user/messaging_page.dart';
import 'package:flutter_application_1/pages/company/company_list.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_view.dart';
import 'package:flutter_application_1/pages/pdf/pdf_show_list.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:flutter_application_1/pages/welcome_page.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
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

  Widget buildHeader(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            Get.to(() => WelcomePage());
          },
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 24,
            ),
            child: Column(
              children: [
                
                SizedBox(height: 12),
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Role: $role',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildMenuItems(BuildContext context) => Column(
        children: [
          buildMenuItem(
            context,
            icon: Icons.checklist_outlined,
            text: 'Go to checklist',
            onClicked: () => Get.to(() => const CheckList()),
          ),
          if (role == 'user')
            buildMenuItem(
              context,
              icon: Icons.picture_as_pdf_outlined,
              text: 'Go to PDF list',
              onClicked: () => Get.to(() => const PDFShowList()),
            ),
          if (role == 'superadmin')
            buildMenuItem(
              context,
              icon: Icons.lock_outline,
              text: 'List of lists',
              onClicked: () => Get.to(() => ListOfListsControlPage()),
            ),
          if (role == 'admin' || role == 'superadmin')
            buildMenuItem(
              context,
              icon: Icons.picture_as_pdf_outlined,
              text: 'Go to admins PDF list new',
              onClicked: () => Get.to(() => AdminPdfListView()),
            ),
          if (role == 'admin' || role == 'superadmin')
            buildMenuItem(
              context,
              icon: Icons.business_outlined,
              text: 'Go to admins Company list',
              onClicked: () => Get.to(() => CompanyList()),
            ),
          const Divider(color: Colors.white54, thickness: 1),
          buildMenuItem(
            context,
            icon: Icons.mail_outline,
            text: 'Messagerie',
            onClicked: () => Get.to(() => MessagingPage()),
          ),
          if (role == 'admin')
            buildMenuItem(
              context,
              icon: Icons.manage_accounts_outlined,
              text: 'Gestion des utilisateurs',
              onClicked: () => Get.to(() => UserManagementAdmin()),
            ),
          if (role == 'superadmin')
            buildMenuItem(
              context,
              icon: Icons.admin_panel_settings_outlined,
              text: 'Page du super admin',
              onClicked: () =>
                  Get.to(() => AdminPage(userRole: UserRole.superadmin)),
            ),
          const Divider(color: Colors.white54, thickness: 1),
          buildMenuItem(
            context,
            icon: Icons.logout,
            text: 'Déconnexion',
            onClicked: () {
              AuthController.instance.logOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vous avez été déconnecté'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      );

  Widget buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onClicked,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      hoverColor: const Color.fromARGB(255, 184, 209, 229),
      onTap: onClicked,
    );
  }
}
