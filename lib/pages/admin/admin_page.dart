// ignore_for_file: use_super_parameters, prefer_const_constructors, unused_import
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/UserApprovalPage.dart';
import 'package:flutter_application_1/pages/admin/UserManagementPage.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/checklist/lol_control_page.dart';
import 'package:flutter_application_1/pages/company/company_list.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_view.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:flutter_application_1/pages/welcome_page.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:get/get.dart';

class AdminPage extends StatelessWidget {
  final UserRole userRole;

  const AdminPage({Key? key, required this.userRole}) : super(key: key);

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
