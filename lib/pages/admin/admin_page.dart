// ignore_for_file: use_super_parameters, prefer_const_constructors, unused_import
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/UserApprovalPage.dart';
import 'package:flutter_application_1/pages/admin/UserManagementPage.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:flutter_application_1/pages/welcome_page.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/settings_page.dart';

import 'package:get/get.dart';

class AdminPage extends StatelessWidget {
  final UserRole userRole;

  const AdminPage({Key? key, required this.userRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page d\'administration'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
          Get.to(() => SettingsPage());
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _buildDashboard(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.deepPurple,
          ),
          child: Center(
            child: Icon(
              Icons.account_circle,
              size: 100,
              color: Colors.white,
            ),
          ),
        ),
        _buildListTile(
          context,
          'Welcome Page',
          Icons.home,
          () {
            Get.to(() => WelcomePage());
          },
        ),
        if (userRole == UserRole.superadmin) ...[
          _buildListTile(
            context,
            'Gestion des utilisateurs',
            Icons.supervised_user_circle,
            () {
              Get.to(() => UserManagementPage());
            },
          ),
          _buildListTile(
            context,
            'Approuver un compte',
            Icons.approval,
            () {
              Get.to(() => UserApprovalPage());
            },
          ),
        ],
        _buildListTile(
          context,
          'Checklist',
          Icons.checklist,
          () {
           Get.to(() => const CheckList());
          },
        ),
        ListTile(
          title: Text('Déconnexion'),
          leading: Icon(Icons.exit_to_app),
          onTap: () {
            AuthController.instance.logOut();
          },
        ),
      ],
    ),
  );
}

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap,
    );
  }

  Widget _buildDashboard() {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(20),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        _buildDashboardItem(
          'Gestion des utilisateurs',
          Icons.supervised_user_circle,
          () {
            Get.to(() => UserManagementPage());
          },
        ),
        _buildDashboardItem(
          'Approuver un compte',
          Icons.approval,
          () {
            Get.to(() => UserApprovalPage());
          },
        ),
        _buildDashboardItem(
          'Checklist',
          Icons.checklist,
          () {
            Get.to(() => const CheckList());
          },
        ),
        _buildDashboardItem(
          'Welcome Page',
          Icons.home,
          () {
            Get.to(() => WelcomePage());
          },
        ),
      ],
    );
  }

  Widget _buildDashboardItem(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.deepPurple, // Couleur de l'icône
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
