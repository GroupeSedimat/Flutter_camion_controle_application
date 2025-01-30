import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/admin/UserManagementAdmin.dart';
import 'package:flutter_application_1/pages/admin/admin_page.dart';
import 'package:flutter_application_1/pages/camion/camion_list.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/checklist/lol_control_page.dart';
import 'package:flutter_application_1/pages/user/messaging_page.dart';
import 'package:flutter_application_1/pages/company/company_list.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_view.dart';
import 'package:flutter_application_1/pages/pdf/pdf_show_list.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:flutter_application_1/pages/welcome_page.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class MenuWidget extends StatefulWidget {

  MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  String _username = "";
  late Database db;
  String _role = "";
  late AuthController authController;
  late UserService userService;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }
  
  Future<void> _loadData() async {
    await _initServices();
    await _initDatabase();
    await _loadUserLocalDB();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initServices() async {
    try {
      authController = AuthController();
      userService = UserService();
    } catch (e) {
      print("Error loading services: $e");
    }
  }
  
  Future<void> _loadUserLocalDB() async {
    print("menu local ☢☢☢☢☢☢☢");
    try {
      Map<String, MyUser>? users = await getThisUser(db);
      MyUser user = users!.values.first;
      _username = user.username;
      print("local username ☢☢☢☢☢☢☢ $_username");
      _role = user.role;
      print("local role ☢☢☢☢☢☢☢ $_role");
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  @override
  Widget build(BuildContext context){
    if(_username == "" || _role == ""){
      return Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8), // Teinte plus foncée
                Theme.of(context).primaryColor.withOpacity(0.4),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8), // Teinte plus foncée
              Theme.of(context).primaryColor.withOpacity(0.4),
            ],
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
  }

  Widget buildHeader(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor.withOpacity(0.8),
        Theme.of(context).primaryColor.withOpacity(0.4),],
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
                  _username,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if(_role!="user")
                Text(
                  AppLocalizations.of(context)!.role(_role),
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
            text: AppLocalizations.of(context)!.checkList,
            onClicked: () => Get.to(() => const CheckList()),
          ),
          if (_role == 'user')
            buildMenuItem(
              context,
              icon: Icons.picture_as_pdf_outlined,
              text: AppLocalizations.of(context)!.pdfList,
              onClicked: () => Get.to(() => const PDFShowList()),
            ),
          if (_role == 'superadmin')
            buildMenuItem(
              context,
              icon: Icons.lock_outline,
              text: AppLocalizations.of(context)!.listOfLists,
              onClicked: () => Get.to(() => ListOfListsControlPage()),
            ),
          if (_role == 'admin' || _role == 'superadmin')
            buildMenuItem(
              context,
              icon: Icons.picture_as_pdf_outlined,
              text: AppLocalizations.of(context)!.pdfListAdmin,
              onClicked: () => Get.to(() => AdminPdfListView()),
            ),
          if (_role == 'admin' || _role == 'superadmin')
            buildMenuItem(
              context,
              icon: Icons.business_outlined,
              text: AppLocalizations.of(context)!.company,
              onClicked: () => Get.to(() => CompanyList()),
            ),
          const Divider(color: Colors.white54, thickness: 1),
          buildMenuItem(
            context,
            icon: Icons.mail_outline,
            text: AppLocalizations.of(context)!.messenger,
            onClicked: () => Get.to(() => MessagingPage()),
          ),
          if (_role == 'admin')
            buildMenuItem(
              context,
              icon: Icons.manage_accounts_outlined,
              text: AppLocalizations.of(context)!.manageUsers,
              onClicked: () => Get.to(() => UserManagementAdmin()),
            ),
          if (_role == 'admin')
            buildMenuItem(
              context,
              icon: Icons.fire_truck,
              text: AppLocalizations.of(context)!.camionsList,
              onClicked: () => Get.to(() => CamionList()),
            ),
          if (_role == 'superadmin')
            buildMenuItem(
              context,
              icon: Icons.admin_panel_settings_outlined,
              text: AppLocalizations.of(context)!.superAdminPage,
              onClicked: () =>
                  Get.to(() => AdminPage(userRole: UserRole.superadmin)),
            ),
          const Divider(color: Colors.white54, thickness: 1),
          buildMenuItem(
            context,
            icon: Icons.logout,
            text: AppLocalizations.of(context)!.logOut,
            onClicked: () {
              AuthController.instance.logOut();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.logOutText),
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