import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/admin/UserApprovalPage.dart';
import 'package:flutter_application_1/pages/admin/UserManagementPage.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/camion/camion_list.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/checklist/lol_control_page.dart';
import 'package:flutter_application_1/pages/company/company_list.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_view.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class AdminPage extends StatefulWidget {
  final UserRole userRole;

  const AdminPage({Key? key, required this.userRole}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  late Database db;
  late MyUser _user;
  late String _userId;
  bool _isLoading = true;
  late NetworkService networkService;
  late AuthController authController;
  late UserService userService;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _initDatabase();
    await _initServices();
    if (!networkService.isOnline) {
      print("Offline mode, no user update possible");
    }else{
      await _loadUserToConnection();
    }
    await _loadUser();
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible");
    }{
      await _syncData();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserToConnection() async {
    print("admin_page user_to_connection firebase ☢☢☢☢☢☢☢");
    Map<String, MyUser>? users = await getThisUser(db);
    print("users: $users");
    if(users != null ){
      return;
    }
    try {
      MyUser user = await userService.getCurrentUserData();
      print("user ☢☢☢☢☢☢☢ $user");
      String? userId = await userService.userID;
      print("userId ☢☢☢☢☢☢☢ $userId");
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Users...");
      await syncService.fullSyncTable("users", user: user, userId: userId);
    } catch (e) {
      print("💽 Error loading user: $e");
    }
  }

  Future<void> _loadUser() async {
    print("admin page local ☢☢☢☢☢☢☢");
    try {
      Map<String, MyUser>? users = await getThisUser(db);
      print("connected as  $users");
      MyUser user = users!.values.first;
      print("local user ☢☢☢☢☢☢☢ $user");
      String? userId = users.keys.first;
      print("local userId ☢☢☢☢☢☢☢ $userId");
      _userId = userId;
      _user = user;
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _initServices() async {
    try {
      authController = AuthController();
      userService = UserService();
      networkService = Provider.of<NetworkService>(context, listen: false);
    } catch (e) {
      print("Error loading services: $e");
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _syncData() async {
    if (!networkService.isOnline) {
      print("⛔ Offline mode, no sync possible ⛔");
    }else{
      print("✅ Online mode, start sync ✅");
      try {
        final syncService = Provider.of<SyncService>(context, listen: false);
        print("💽 Synchronizing Users...");
        await syncService.fullSyncTable("users", user:_user, userId: _userId);
        print("💽 Synchronizing Camions...");
        await syncService.fullSyncTable("camions", user: _user, userId: _userId);
        print("💽 Synchronizing CamionTypess...");
        await syncService.fullSyncTable("camionTypes", user: _user, userId: _userId);
        print("💽 Synchronizing Companies...");
        await syncService.fullSyncTable("companies", user: _user, userId: _userId);
        print("💽 Synchronizing Equipments...");
        await syncService.fullSyncTable("equipments", user: _user, userId: _userId);
        print("💽 Synchronizing LOL...");
        await syncService.fullSyncTable("listOfLists", user: _user, userId: _userId);
        print("💽 Synchronizing Blueprints...");
        await syncService.fullSyncTable("blueprints", user: _user, userId: _userId);
        print("💽 Synchronization with SQLite completed.");
      } catch (e) {
        print("💽 Error during synchronization with SQLite: $e");
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
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

    return BasePage(
      title: AppLocalizations.of(context)!.superAdminPage,
      body: _buildDashboard(context),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(20),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        _buildDashboardItem(
          context,
          AppLocalizations.of(context)!.manageUsers,
          Icons.supervised_user_circle,
          () {
            Get.to(() => UserManagementPage());
          },
        ),
        _buildDashboardItem(
          context,
          AppLocalizations.of(context)!.userApprove,
          Icons.approval,
          () {
            Get.to(() => UserApprovalPage());
          },
        ),
        _buildDashboardItem(
          context,
          AppLocalizations.of(context)!.checkList,
          Icons.checklist,
          () {
            Get.to(() => const CheckList());
          },
        ),
        _buildDashboardItem(
          context,
          AppLocalizations.of(context)!.listOfLists,
          Icons.list_alt,
          () {
            Get.to(() => const ListOfListsControlPage());
          },
        ),
        _buildDashboardItem(
          context,
          AppLocalizations.of(context)!.company,
          Icons.home_work,
          () {
            Get.to(() => CompanyList());
          },
        ),
        _buildDashboardItem(
          context,
          AppLocalizations.of(context)!.camionsList,
          Icons.fire_truck,
          () {
            Get.to(() => CamionList());
          },
        ),
        _buildDashboardItem(
          context,
          AppLocalizations.of(context)!.pdfListAdmin,
          Icons.picture_as_pdf,
          () {
            Get.to(() => AdminPdfListView());
          },
        ),
      ],
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
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
                color: Theme.of(context).primaryColor,
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
