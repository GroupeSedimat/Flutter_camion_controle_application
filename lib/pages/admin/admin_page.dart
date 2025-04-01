import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/admin/user_mnagement_page.dart';
import 'package:flutter_application_1/widgets/base_page.dart';
import 'package:flutter_application_1/pages/camion/camion_list.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/checklist/lol_control_page.dart';
import 'package:flutter_application_1/pages/company/company_list.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_view.dart';
import 'package:flutter_application_1/models/user/user_role.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

/// page de démarrage et page de gestion principale de superAdmin
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
    } else {
      await _loadUserToConnection();
    }
    await _loadUser();
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible");
    }
    {
      await _syncData();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserToConnection() async {
    Map<String, MyUser>? users = await getThisUser(db);
    if (users != null) {
      return;
    }
    try {
      MyUser user = await userService.getCurrentUserData();
      String? userId = await userService.userID;
      final syncService = Provider.of<SyncService>(context, listen: false);
      await syncService.fullSyncTable("users", user: user, userId: userId);
    } catch (e) {
      print("💽 Error loading user: $e");
    }
  }

  Future<void> _loadUser() async {
    try {
      Map<String, MyUser>? users = await getThisUser(db);
      MyUser user = users!.values.first;
      String? userId = users.keys.first;
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
    } else {
      print("✅ Online mode, start sync ✅");
      try {
        final syncService = Provider.of<SyncService>(context, listen: false);
        print("💽 Synchronizing Users...");
        await syncService.fullSyncTable("users", user: _user, userId: _userId);
        print("💽 Synchronizing Camions...");
        await syncService.fullSyncTable("camions",
            user: _user, userId: _userId);
        print("💽 Synchronizing CamionTypess...");
        await syncService.fullSyncTable("camionTypes",
            user: _user, userId: _userId);
        print("💽 Synchronizing Companies...");
        await syncService.fullSyncTable("companies",
            user: _user, userId: _userId);
        print("💽 Synchronizing Equipments...");
        await syncService.fullSyncTable("equipments",
            user: _user, userId: _userId);
        print("💽 Synchronizing LOL...");
        await syncService.fullSyncTable("listOfLists",
            user: _user, userId: _userId);
        print("💽 Synchronizing Blueprints...");
        await syncService.fullSyncTable("blueprints",
            user: _user, userId: _userId);
        print("💽 Synchronizing PDFs...");
        await syncService.fullSyncTable("pdf", user: _user, userId: _userId);
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
      body: _buildModernDashboard(context),
    );
  }

  /// créer un menu en mosaïque
  Widget _buildModernDashboard(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
          childAspectRatio = 1.5;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          childAspectRatio = 1.5;
        } else {
          crossAxisCount = 1;
          childAspectRatio = 1.8;
        }

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildListDelegate([
                  _buildDashboardItem(
                    context,
                    AppLocalizations.of(context)!.manageUsers,
                    Icons.people,
                    Colors.blue,
                    () => Get.to(() => UserManagementPage()),
                  ),
                  _buildDashboardItem(
                    context,
                    AppLocalizations.of(context)!.checkList,
                    Icons.checklist,
                    Colors.green,
                    () => Get.to(() => const CheckList()),
                  ),
                  _buildDashboardItem(
                    context,
                    AppLocalizations.of(context)!.listOfLists,
                    Icons.list_alt,
                    Colors.orange,
                    () => Get.to(() => const ListOfListsControlPage()),
                  ),
                  _buildDashboardItem(
                    context,
                    AppLocalizations.of(context)!.company,
                    Icons.business,
                    Colors.purple,
                    () => Get.to(() => CompanyList()),
                  ),
                  _buildDashboardItem(
                    context,
                    AppLocalizations.of(context)!.camionsList,
                    Icons.local_shipping,
                    Colors.red,
                    () => Get.to(() => CamionList()),
                  ),
                  _buildDashboardItem(
                    context,
                    AppLocalizations.of(context)!.pdfListAdmin,
                    Icons.picture_as_pdf,
                    Colors.teal,
                    () => Get.to(() => AdminPdfListView()),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  /// tuile dans le menu
  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.7), color],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
