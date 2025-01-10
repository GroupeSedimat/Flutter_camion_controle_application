import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/UserApprovalPage.dart';
import 'package:flutter_application_1/pages/admin/UserManagementPage.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/camion/camion_list.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/checklist/lol_control_page.dart';
import 'package:flutter_application_1/pages/company/company_list.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_view.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _initDatabase();
    await _syncDatas();
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _syncDatas() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("++++ Synchronizing Users...");
      await syncService.fullSyncTable("users");//, user:user, userId: userId
      print("++++ Synchronizing Camions...");
      await syncService.fullSyncTable("camions");
      print("++++ Synchronizing CamionTypess...");
      await syncService.fullSyncTable("camionTypes");
      print("++++ Synchronizing Companies...");
      await syncService.fullSyncTable("companies");
      print("++++ Synchronizing Equipments...");
      await syncService.fullSyncTable("equipments");
      print("++++ Synchronizing LOL...");
      await syncService.fullSyncTable("listOfLists");
      print("++++ Synchronizing Blueprints...");
      await syncService.fullSyncTable("blueprints");
      print("++++ Synchronization with SQLite completed.");
    } catch (e) {
      print("++++ Error during synchronization with SQLite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
    BuildContext context, // Ajouter le BuildContext en paramètre
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
